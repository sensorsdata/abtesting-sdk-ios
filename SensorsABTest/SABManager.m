//
// SABManager.m
// SensorsABTest
//
// Created by 储强盛 on 2020/9/29.
// Copyright © 2020-2022 Sensors Data Co., Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import <WebKit/WebKit.h>
#import "SABManager.h"
#import "SABLogBridge.h"
#import "SABBridge.h"
#import "NSString+SABHelper.h"
#import "SABConstants.h"
#import "SABFetchResultResponse.h"
#import "SABExperimentDataManager.h"
#import "SABValidUtils.h"
#import "SensorsABTestConfigOptions+Private.h"
#import "SABRequest.h"
#import "SABJSONUtils.h"
#import "SABPropertyValidator.h"
#import "SensorsABTestExperiment+Private.h"
#import "SABRequestManager.h"
#import "SABTestTriggerIdentifier.h"

/// 调用 js 方法名
static NSString * const kSABAppCallJSMethodName = @"window.sensorsdata_app_call_js";

/// 最大请求次数，失败进行重试
static NSInteger const kSABAsyncFetchExperimentMaxTimes = 3;

/// 重试请求时间间隔，单位 秒
static NSTimeInterval const kSABAsyncFetchExperimentRetryIntervalTime = 30;

/**
 * @abstract
 * SDK 生命周期状态
 *
 * @discussion
 * 具体详见 SensorsAnalyticsSDK 中 SAAppLifecycle 的相关实现和通知
 */
typedef NS_ENUM(NSUInteger, SABAppLifecycleState) {
    /// App 启动
    SABAppLifecycleStateStart = 2,
    /// App 退出
    SABAppLifecycleStateEnd = 4
};

@interface SABManager()

// 初始化配置
@property (nonatomic, strong) SensorsABTestConfigOptions *configOptions;

@property (nonatomic, strong) SABExperimentDataManager *dataManager;

/// 触发过的事件标识
@property (nonatomic, strong) NSMutableArray<SABTestTriggerIdentifier *> *trackedIdentifiers;

@property (nonatomic, strong) NSTimer *timer;
// 暂停时刻时间
@property (nonatomic, strong) NSDate *pauseStartTime;
// 上次执行时间
@property (nonatomic, strong) NSDate *previousFireTime;

@property (nonatomic, strong) SABRequestManager *requestManager;

@end

@implementation SABManager

#pragma mark - initialize
- (instancetype)initWithConfigOptions:(nonnull SensorsABTestConfigOptions *)configOptions {
    self = [super init];
    if (self) {
        _configOptions = [configOptions copy];
        _trackedIdentifiers = [NSMutableArray array];
        
        // 数据存储和解析
        _dataManager = [[SABExperimentDataManager alloc] init];

        _requestManager = [[SABRequestManager alloc] init];
        
        // 注册监听
        [self setupListeners];
        
        // 获取所有最新试验结果
        [self fetchAllABTestResultWithTimes:kSABAsyncFetchExperimentMaxTimes];
    }
    return self;
};

- (void)setupListeners {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    // 监听 SDK 生命周期
    [notificationCenter addObserver:self selector:@selector(appLifecycleStateDidChange:) name:kSABSAAppLifecycleStateDidChangeNotification object:nil];
    
    // App 与 H5 打通相关通知
    [notificationCenter addObserver:self selector:@selector(registerSAJSBridge:) name:kSABSARegisterSAJSBridgeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(messageFromH5:) name:kSABSAMessageFromH5Notification object:nil];
    
    // 用户 id 变化相关通知
    [notificationCenter addObserver:self selector:@selector(reloadAllABTestResult:) name:kSABSALoginNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(reloadAllABTestResult:) name:kSABSALogoutNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(reloadAllABTestResult:) name:kSABSAIdentifyNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(reloadAllABTestResult:) name:kSABSAResetAnonymousIdNotification object:nil];
}

#pragma mark - notification Action
// 状态变化通知
- (void)appLifecycleStateDidChange:(NSNotification *)sender {
    NSDictionary *userInfo = sender.userInfo;
    SABAppLifecycleState newState = [userInfo[@"new"] integerValue];
    switch (newState) {
        case SABAppLifecycleStateStart:
            // 开启定时更新计时
            [self startReloadTimer];
            break;
        case SABAppLifecycleStateEnd:
            // 关闭定时更新计时
            [self stopReloadTimer];
            break;
    }
}

/// 注入 App 与 H5 打通标识
- (void)registerSAJSBridge:(NSNotification *)notification {
    WKWebView *webView = notification.object;
    if (![webView isKindOfClass:WKWebView.class]) {
        SABLogError(@"notification object is invalid webView from SensorsAnalyticsSDK");
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        // 注入 sensorsdata_abtest_module 标记，表示当前已集成 A/B Test iOS SDK
        NSString *javaScriptSource = @"window.SensorsData_iOS_JS_Bridge.sensorsdata_abtest_module = true;";
        WKUserScript *userScript = [[WKUserScript alloc] initWithSource:javaScriptSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [webView.configuration.userContentController addUserScript:userScript];
    });
}

/// js 发送的请求数据
- (void)messageFromH5:(NSNotification *)notification {
    WKScriptMessage *message = notification.object;
    WKWebView *webView = message.webView;
    if (![webView isKindOfClass:WKWebView.class]) {
        SABLogError(@"Message webview is invalid from SensorsAnalyticsSDK");
        return;
    }

    NSDictionary *messageDic = [SABJSONUtils JSONObjectWithString:message.body];
    if (![messageDic isKindOfClass:[NSDictionary class]]) {
        SABLogError(@"Message body is formatted failure from JS SDK");
        return;
    }

    BOOL isCallType = [messageDic[@"callType"] isEqualToString:@"abtest"];
    if (!isCallType) {
        return;
    }
    NSDictionary *dataDic = messageDic[@"data"];
    if (![dataDic isKindOfClass:NSDictionary.class]) {
        SABLogError(@"Message data is invalid from JS SDK");
        return;
    }

    /* 拼接回传 js 的数据结构
     sensorsdata_app_call_js('abtest',"{
     "data":{       //分流请求响应数据
        "message_id":1598947194957, //唯一标识，H5 发起的请求信息中获取
        "timeout":XXXXX     //H5 的 timeout
        "properties":{},    //App 端 A/B Testing 特定的属性，暂未添加
        "request_body": {   // H5 请求需要增加的参数
                  "origin_platform": 'H5'
               }
        }
     }")
     */
    SABExperimentRequest *requestData = [[SABExperimentRequest alloc] initWithBaseURL:self.configOptions.baseURL projectKey:self.configOptions.projectKey];

    requestData.timeoutInterval = [dataDic[@"timeout"] integerValue] / 1000.0;
    // 拼接 H5 请求参数
    [requestData appendRequestBody:dataDic[@"request_body"]];

    // 拼接自定义主体 ID
    [requestData appendCustomIDs:self.dataManager.customIDs];

    [self.dataManager asyncFetchAllExperimentWithRequest:requestData completionHandler:^(SABFetchResultResponse * _Nullable responseData, NSError * _Nullable error) {
        
        // JS 数据拼接
        NSMutableDictionary *callJSDataDic = [NSMutableDictionary dictionary];
        callJSDataDic[@"message_id"] = dataDic[@"message_id"];
        if (responseData.responseObject) {
            callJSDataDic[@"data"] = responseData.responseObject;

        }
        NSData *callJSData = [SABJSONUtils JSONSerializeObject:callJSDataDic];

        // base64 编码，避免转义字符丢失的问题
        NSString *callJSJsonString = [callJSData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];

        // 请求结果，直接发到 js
        NSMutableString *javaScriptSource = [NSMutableString stringWithString:kSABAppCallJSMethodName];
        [javaScriptSource appendFormat:@"('abtest', '%@')", callJSJsonString];
        dispatch_async(dispatch_get_main_queue(), ^{
            [webView evaluateJavaScript:javaScriptSource completionHandler:^(id _Nullable response, NSError *_Nullable error) {
                if (error) {
                    // 可能方法不存在；
                    SABLogError(@"window.sensorsdata_app_call_js abtest error：%@", error);
                } else {
                    SABLogInfo(@"window.sensorsdata_app_call_js abtest success");
                }
            }];
        });
    }];
}

- (void)reloadAllABTestResult:(NSNotification *)notification {
    SABLogDebug(@"Receive notification: %@ and reload ABTest results", notification.name);
    [self reloadAllABTestResult];
}

- (void)reloadAllABTestResult {
    // 用户 ID 信息发生变化，清除试验缓存
    [self.dataManager clearExperiment];

    // 重新请求试验
    [self fetchAllABTestResult];
}

#pragma mark - fetch ABTest Action
- (void)fetchABTestWithExperiment:(SensorsABTestExperiment *)experiment {
    if (!experiment.handler) {
        SABLogWarn(@"Please use a valid completionHandler");
        return;
    }

    if (![SABValidUtils isValidString:experiment.paramName]) {
        if (experiment.modeType == SABFetchABTestModeTypeCache) {
            experiment.handler(experiment.defaultValue);
        } else {
            // fast 和 async 异步接口，统一主线程回调结果
            dispatch_async(dispatch_get_main_queue(), ^{
                experiment.handler(experiment.defaultValue);
            });
        }
        SABLogError(@"paramName: %@ error，paramName must be a valid string!", experiment.paramName);
        return;
    }
    
    switch (experiment.modeType) {
        case SABFetchABTestModeTypeCache: {
            // 从缓存读取
            id cacheValue = [self fetchCacheABTestWithExperiment:experiment];
            return experiment.handler(cacheValue ? : experiment.defaultValue);
        }
        case SABFetchABTestModeTypeFast: {
            id cacheValue = [self fetchCacheABTestWithExperiment:experiment];
            if (cacheValue) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    experiment.handler(cacheValue);
                });
                return;
            }

            NSArray<NSString *> *fuzzyExperiments = self.dataManager.fuzzyExperiments;
            if (fuzzyExperiments && ![fuzzyExperiments containsObject:experiment.paramName]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    experiment.handler(experiment.defaultValue);
                });
                return;
            }
            return [self fetchAsyncABTestWithExperiment:experiment];
        }
        case SABFetchABTestModeTypeAsync: {
            return [self fetchAsyncABTestWithExperiment:experiment];
        }
    }
}

/// 获取缓存试验
- (nullable id)fetchCacheABTestWithExperiment:(SensorsABTestExperiment *)experiment {
    if (![SABValidUtils isValidString:experiment.paramName]) {
        SABLogError(@"paramName: %@ error，paramName must be a valid string!", experiment.paramName);
        return nil;
    }
    SABExperimentResult *resultData = [self.dataManager cachedExperimentResultWithParamName:experiment.paramName];

    if (!resultData) {
        SABLogWarn(@"The cache experiment result is empty, paramName: %@", experiment.paramName);
        return nil;
    }
    // 判断和默认值类型是否一致
    if (![resultData isSameTypeWithDefaultValue:experiment.defaultValue]) {
        NSString *resulTypeString = [SABExperimentResult descriptionWithExperimentResultType:resultData.variable.type];
        NSString *defaultValueTypeString = [SABExperimentResult descriptionWithExperimentResultType:[SABExperimentResult experimentResultTypeWithValue:experiment.defaultValue]];
        SABLogWarn(@"The experiment result type is inconsistent with the defaultValue type of the interface setting, paramName: %@, experiment result type: %@, defaultValue type: %@", experiment.paramName, resulTypeString, defaultValueTypeString);
        return nil;
    }

    if (!resultData.isWhiteList) {
        // 埋点
        [self trackABTestWithData:resultData];
    }
    return resultData.variable.value;
}

/// 异步请求获取试验
- (void)fetchAsyncABTestWithExperiment:(SensorsABTestExperiment *)experiment {
    NSError *error;
    // 验证自定义属性合法性，并统一修改自定义属性值为 String 类型
    NSDictionary *properties = [SABPropertyValidator validateProperties:experiment.properties error:&error];
    if (error) {
        SABLogError(@"%@", error.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^{
            experiment.handler(experiment.defaultValue);
        });
        return;
    }

    // 异步请求
    SABExperimentRequest *requestData = [[SABExperimentRequest alloc] initWithBaseURL:self.configOptions.baseURL projectKey:self.configOptions.projectKey];
    requestData.timeoutInterval = experiment.timeoutInterval;
    if (properties.count > 0 && experiment.paramName) {
        [requestData appendRequestBody:@{kSABRequestBodyCustomProperties: properties, kSABRequestBodyParamName: experiment.paramName}];
    }
    // 拼接自定义主体 ID
    [requestData appendCustomIDs:self.dataManager.customIDs];

    // 检查当前请求是否已存在相同的请求任务，当前只针对 Fast 模式下的请求生效
    if (experiment.modeType == SABFetchABTestModeTypeFast && [self.requestManager containsRequest:requestData]) {
        [self.requestManager mergeExperimentWithRequest:requestData experiment:experiment];
        return;
    }

    [self.requestManager addRequestTask:requestData experiment:experiment];

    __weak typeof(self) weakSelf = self;
    [self.dataManager asyncFetchAllExperimentWithRequest:requestData completionHandler:^(SABFetchResultResponse *_Nullable responseData, NSError *_Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        if (error || !responseData) {
            SABLogError(@"asyncFetchAllExperimentWithRequest failure，error: %@", error);
            // 请求失败，主线程回调结果
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.requestManager excuteExperimentsWithRequest:requestData completion:^(SensorsABTestExperiment *obj) {
                    obj.handler(obj.defaultValue);
                }];
            });
            return;
        }

        // 通过请求管理器统一回调试验结果，切到主线程回调结果
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.requestManager excuteExperimentsWithRequest:requestData completion:^(SensorsABTestExperiment *obj) {
                // 获取缓存并触发 $ABTestTrigger 事件
                id cacheValue = [strongSelf fetchCacheABTestWithExperiment:obj];
                obj.handler(cacheValue ? : obj.defaultValue);
            }];
        });
    }];
}

/// 获取所有试验结果
- (void)fetchAllABTestResult {
    [self fetchAllABTestResultWithTimes:1];
}

/// 获取所有试验结果
/// @param times 最大次数
- (void)fetchAllABTestResultWithTimes:(NSInteger)times {
    NSInteger fetchIndex = times - 1;

    SABExperimentRequest *requestData = [[SABExperimentRequest alloc] initWithBaseURL:self.configOptions.baseURL projectKey:self.configOptions.projectKey];
    // 拼接自定义主体 ID
    [requestData appendCustomIDs:self.dataManager.customIDs];

    [self.dataManager asyncFetchAllExperimentWithRequest:requestData completionHandler:^(SABFetchResultResponse *_Nullable responseData, NSError *_Nullable error) {
        if (fetchIndex <= 0 || !error) {
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSABAsyncFetchExperimentRetryIntervalTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self fetchAllABTestResultWithTimes:fetchIndex];
        });
    }];
}

#pragma mark - action
/// track $ABTestTrigger
- (void)trackABTestWithData:(SABExperimentResult *)resultData {
    if (!resultData) {
        return;
    }

    // 获取 userIdenty，用于判断当前用户是否触发过该试验
    SABUserIdenty *userIdenty = resultData.userIdenty;
    NSString *distinctId = userIdenty.distinctId;
    if (!distinctId) {
        return;
    }

    // 构建触发事件标识
    SABTestTriggerIdentifier *eventIdentify = [[SABTestTriggerIdentifier alloc] initWithExperimentId:resultData.experimentId distinctId:distinctId];
    eventIdentify.customIDs = self.dataManager.customIDs;
    // 是否已经触发事件
    if ([self.trackedIdentifiers containsObject:eventIdentify]) {
        return;
    }
    // 记录当前试验触发事件
    [self.trackedIdentifiers addObject:eventIdentify];

    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    properties[kSABTriggerExperimentId] = resultData.experimentId;
    properties[kSABTriggerExperimentGroupId] = resultData.experimentGroupId;

    // 记录用户信息
    properties[kSABLoginId] = userIdenty.loginId;
    properties[kSABDistinctId] = userIdenty.distinctId;
    properties[kSABAnonymousId] = userIdenty.anonymousId;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 首次触发事件，添加版本号
        NSString *libVersion = [NSString stringWithFormat:@"%@:%@", kSABLibPrefix, kSABLibVersion];
        properties[kSABLibPluginVersion] = @[libVersion];
    });

    [SABBridge track:kSABTriggerEventName properties:properties];
}

/// 开始更新计时
- (void)startReloadTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 在启动弹框中 applicationDidBecomeActive 可能重复调用
        if (self.timer.isValid && !self.pauseStartTime) {
            return;
        }

        SABLogDebug(@"start reload timer.");
        if (self.timer.isValid) {
            // 恢复
            float pauseTime = -1 * [self.pauseStartTime  timeIntervalSinceNow];
            [self.timer setFireDate:[NSDate dateWithTimeInterval:pauseTime sinceDate:self.previousFireTime]];
            self.pauseStartTime = nil;
            self.previousFireTime = nil;
            return;
        }

        // 默认 10 分钟更新数据
        NSTimeInterval interval = 10 * 60;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(fetchAllABTestResult) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    });
}

/// 暂停更新计时
- (void)stopReloadTimer {
    SABLogDebug(@"stop reload timer.");
    dispatch_async(dispatch_get_main_queue(), ^{
        // 暂停计时
        self.pauseStartTime = [NSDate dateWithTimeIntervalSinceNow:0];
        self.previousFireTime = [self.timer fireDate];
        [self.timer setFireDate:[NSDate distantFuture]];
    });
}

- (void)setCustomIDs:(NSDictionary <NSString*, NSString*> *)customIDs {
    NSDictionary *tempCustomIDs = [SABPropertyValidator validateCustomIDs:customIDs];
    // 内容都为空时，不需要更新 customIDs 信息
    if (tempCustomIDs.count == 0 && self.dataManager.customIDs.count == 0) {
        return;
    }
    // 自定义主体 ID 未发生变化，不需要更新
    if ([tempCustomIDs isEqualToDictionary:self.dataManager.customIDs]) {
        return;
    }
    [self.dataManager updateCustomIDs:tempCustomIDs];
    [self reloadAllABTestResult];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
