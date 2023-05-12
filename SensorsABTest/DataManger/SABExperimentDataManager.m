//
// SABExperimentDataManager.m
// SensorsABTest
//
// Created by 储强盛 on 2020/10/11.
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

#import "SABExperimentDataManager.h"
#import "SABNetwork.h"
#import "SABLogBridge.h"
#import "SABValidUtils.h"
#import "SABBridge.h"
#import "SABStoreManager.h"
#import "SABFileStorePlugin.h"
#import "SABTestGlobalPropertyPlugin.h"
#import "SABHitExperimentRecordsManager.h"

/// 所有分流试验记录属性 key
static NSString * const kSABAllResultsResultIdSourcesKey = @"abtest_dispatch_result";

/// 所有命中试验记录属性 key
static NSString * const kSABAllHitExperimentResultIdSourcesKey = @"abtest_result";

@interface SABExperimentDataManager() {
    __block SABFetchResultResponse *_resultResponse;
}

/// 试验结果
@property (nonatomic, strong) SABFetchResultResponse *resultResponse;

/// 试验参数白名单
///
/// 表示当前时刻无法确认状态的试验参数集合。
/// 后续 Fast 请求，当列表不存在时直接发送请求;
/// 当列表存在，且试验参数在列表内时则发送请求，否则表示试验已下线或未上线，则直接返回默认值。
@property (atomic, strong, readwrite) NSArray <NSString *> *fuzzyExperiments;
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@property (atomic, strong, readwrite) SABTestTrackConfig *trackConfig;
@property (atomic, strong, readwrite) SABUserIdenty *currentUserIndenty;

@property (nonatomic, strong) SABTestGlobalPropertyPlugin *globalPropertyPlugin;

/// 用户命中记录数据
@property (nonatomic, strong) SABHitExperimentRecordsManager *hitRecordsManager;

@end

@implementation SABExperimentDataManager

- (instancetype)initWithSerialQueue:(dispatch_queue_t)serialQueue {
    self = [super init];
    if (self) {
        [self resgisterStorePlugins];

        _serialQueue = serialQueue;
        _hitRecordsManager = [[SABHitExperimentRecordsManager alloc] initWithSerialQueue:serialQueue];

        [self buildUserIdenty];

        // 解析事件触发配置
        [self unarchiveTriggerConfig];
        if (self.trackConfig.propertySwitch) {
            [self resgisterPropertyPlugins];
        }

        // 读取本地分流缓存
        [self unarchiveExperimentResult];

        dispatch_async(_serialQueue, ^{
            /*更新命中记录属性
             本地命中记录在队列中读取，更新也需要放在队列中排队
             */
            [self refreshHitExperimentResultIdSources];
        });
    }
    return self;
}

- (void)buildUserIdenty {
    NSString *distinctId = [SABBridge distinctId];
    NSString *loginId = [SABBridge loginId];
    NSString *anonymousId = [SABBridge anonymousId];
    SABUserIdenty *userIdenty = [[SABUserIdenty alloc] initWithDistinctId:distinctId loginId:loginId anonymousId:anonymousId];

    // 读取本地缓存前，需要先读取自定义主体 ID
    NSDictionary *customIDs = [SABStoreManager.sharedInstance dictionaryForKey:kSABCustomIDsFileName];
    if (customIDs.count > 0) {
        userIdenty.customIDs = customIDs;
    }

    self.currentUserIndenty = userIdenty;
}

- (void)updateCustomIDs:(NSDictionary<NSString *,NSString *> *)customIDs {
    self.currentUserIndenty.customIDs = customIDs;
    [SABStoreManager.sharedInstance setObject:customIDs forKey:kSABCustomIDsFileName];
}

- (void)updateUserIdenty {
    self.currentUserIndenty.distinctId = [SABBridge distinctId];
    self.currentUserIndenty.loginId = [SABBridge loginId];
    self.currentUserIndenty.anonymousId = [SABBridge anonymousId];
}

- (void)asyncFetchAllExperimentWithRequest:(SABExperimentRequest *)requestData completionHandler:(SABFetchResultResponseCompletionHandler)completionHandler {

    [SABNetwork dataTaskWithRequest:requestData.request completionHandler:^(id _Nullable jsonObject, NSError *_Nullable error) {

        // 数据格式错误
        if (!jsonObject || ![jsonObject isKindOfClass:NSDictionary.class]) {
            SABLogWarn(@"asyncFetchAllABTest invalid %@", jsonObject);
            NSError *error = [[NSError alloc] initWithDomain:@"SABResponseInvalidError" code:-1011 userInfo:@{NSLocalizedDescriptionKey: @"JSON parse error"}];
            completionHandler(nil, error);
            return;
        }

        // 数据解析
        SABFetchResultResponse *responseData = [[SABFetchResultResponse alloc] initWithDictionary:jsonObject];
        // 获取试验成功，更新缓存
        if (responseData.status == SABFetchResultResponseStatusSuccess) {
            SABLogInfo(@"asyncFetchAllExperiment success jsonObject %@", jsonObject);

            // 缓存请求时刻的用户信息
            responseData.userIdenty = requestData.userIdenty;

            self.resultResponse = responseData;

            // 只有在请求成功后才可以更新白名单
            self.fuzzyExperiments = responseData.responseObject[@"fuzzy_experiments"];

            // 存储到本地
            [self archiveExperimentResult:responseData];

            // 更新事件触发配置
            [self updateTriggerConfig:responseData.responseObject[@"track_config"]];

            // 更新试验分流记录
            [self refreshResultsResultIdSourcesProperties];
        } else {
            SABLogWarn(@"asyncFetchAllExperiment fail，request： %@，jsonObject %@", requestData.request, jsonObject);
        }
        completionHandler(responseData, nil);
    }];
}

#pragma mark - readWrite
// 增加读写锁，保证数据的线程安全
- (SABFetchResultResponse *)resultResponse {
    __block SABFetchResultResponse *response;
    sabtest_dispatch_safe_sync(self.serialQueue, ^{
        response = _resultResponse;
    });
    return response;
}

- (void)setResultResponse:(SABFetchResultResponse *)resultResponse {
    sabtest_dispatch_safe_async(self.serialQueue, ^{
        _resultResponse = resultResponse;
    });
}


#pragma mark - query
/// 查询扩展试验信息属性，作为预置属性采集
- (NSDictionary *)queryExtendedPropertiesWithExperimentResult:(SABExperimentResult *)resultData {
    NSMutableDictionary *extendedProperties = [NSMutableDictionary dictionary];
    for (NSString *key in self.trackConfig.extendedPropertyKeys) {
        // 作为预置属性上报，需要拼接 $
        NSString *propertyKey = [@"$" stringByAppendingString:key];
        extendedProperties[propertyKey] = resultData.extendedInfo[key];
    }
    return [extendedProperties copy];
}

#pragma mark - ExperimentResult
/// 读取本地缓存试验
- (void)unarchiveExperimentResult {
    dispatch_async(self.serialQueue, ^{

        NSData *data = [SABStoreManager.sharedInstance objectForKey:kSABExperimentResultFileName];
        if (![data isKindOfClass:NSData.class]) {
            SABLogDebug(@"unarchiveExperimentResult objectForKey failure %@", data);
            return;
        }
        SABFetchResultResponse *result = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        // 解析缓存
        if (![result isKindOfClass:SABFetchResultResponse.class]) {
            SABLogDebug(@"unarchiveExperimentResult unarchiveObjectWithData failure %@", result);
            return;
        }
        
        SABFetchResultResponse *resultResponse = (SABFetchResultResponse *)result;
        // 校验用户信息
        if ([resultResponse.userIdenty isEqualUserIdenty:self.currentUserIndenty]) {
            self.resultResponse = resultResponse;
            SABLogInfo(@"unarchiveExperimentResult success jsonObject %@", resultResponse.responseObject);

            // 更新分流记录属性
            [self refreshResultsResultIdSourcesProperties];
        } else {
            SABLogWarn(@"userIdenty changed，unarchiveExperimentResult failure");
        }
    });
}

/// 写入本地缓存
- (void)archiveExperimentResult:(SABFetchResultResponse *)resultResponse {
    // 存储到本地
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:resultResponse];
    dispatch_async(self.serialQueue, ^{
        [SABStoreManager.sharedInstance setObject:data forKey:kSABExperimentResultFileName];
    });
}

/// 获取缓存试验结果
/// @param paramName 试验参数名
- (SABExperimentResult *)cachedExperimentResultWithParamName:(NSString *)paramName {
    if (![SABValidUtils isValidString:paramName]) {
        return nil;
    }

    __block SABExperimentResult *result = nil;
    dispatch_sync(self.serialQueue, ^{
        result = self.resultResponse.results[paramName];
    });
    return result;
}

/// 查询出组试验结果
- (SABExperimentResult *)queryOutResultWithParamName:(NSString *)paramName {
    if (![SABValidUtils isValidString:paramName]) {
        return nil;
    }

    __block SABExperimentResult *result = nil;
    dispatch_sync(self.serialQueue, ^{
        result = self.resultResponse.outResults[paramName];
    });
    return result;
}

- (void)clearExperimentResults {
    // 刷新内存中的命中记录属性
    [self refreshHitExperimentResultIdSources];

    self.resultResponse = nil;
    // 清除试验时也需要清除当前白名单
    self.fuzzyExperiments = nil;
    dispatch_async(self.serialQueue, ^{
        // 删除本地缓存
        [SABStoreManager.sharedInstance removeObjectForKey:kSABExperimentResultFileName];
    });
}

#pragma mark - TriggerConfig
- (void)unarchiveTriggerConfig {
    id result = [SABStoreManager.sharedInstance objectForKey:kSABTestTrackConfigFileName];
    // 解析缓存
    if (![result isKindOfClass:SABTestTrackConfig.class]) {
        SABLogDebug(@"unarchiveTriggerConfig failure %@", result);

        // 构建默认配置
        self.trackConfig = [[SABTestTrackConfig alloc] init];
        return;
    }

    self.trackConfig = result;
}

/// 更新触发配置
-(void)updateTriggerConfig:(NSDictionary *)triggerConfigDic {
    if (![SABValidUtils isValidDictionary:triggerConfigDic]) {
        // 判断是否为远程下发配置
        if (!self.trackConfig.isRemoteConfig) {
            return;
        }

        // 没有返回有效配置，清除本地配置文件
        dispatch_async(self.serialQueue, ^{
            [SABStoreManager.sharedInstance removeObjectForKey:kSABTestTrackConfigFileName];
        });

        // 恢复默认配置，如已注销属性插件，则注销
        self.trackConfig = [[SABTestTrackConfig alloc] init];
        if (!self.trackConfig.propertySwitch && self.globalPropertyPlugin) {
            [self unresgisterPropertyPlugins];
        }
        return;
    }

    SABTestTrackConfig *trackConfig = [[SABTestTrackConfig alloc] initWithDictionary:triggerConfigDic];
    self.trackConfig = trackConfig;

    // 需注册属性插件
    if (!self.globalPropertyPlugin && trackConfig.propertySwitch) {
        [self resgisterPropertyPlugins];

        // 刷新属性内容
        [self refreshHitExperimentResultIdSources];
        [self refreshResultsResultIdSourcesProperties];
    }

    // 需注销属性插件
    if (!trackConfig.propertySwitch && self.globalPropertyPlugin) {
        [self unresgisterPropertyPlugins];
    }

    // 本地缓存更新
    dispatch_async(self.serialQueue, ^{
        [SABStoreManager.sharedInstance setObject:trackConfig forKey:kSABTestTrackConfigFileName];
    });
}

#pragma mark - handle HitExperimentRecords
- (BOOL)enableTrackWithHitExperiment:(SABExperimentResult *)resultData {

    BOOL enableTrack = [self.hitRecordsManager enableTrackWithHitExperiment:resultData];

    if (!enableTrack) {
        return enableTrack;
    }

    [self refreshHitExperimentResultIdSources];

    return YES;
}


#pragma mark - StorePlugins
/// 注册合规存储插件
- (void)resgisterStorePlugins {
    // 文件明文存储，兼容历史本地数据
    SABFileStorePlugin *filePlugin = [[SABFileStorePlugin alloc] init];
    [SABStoreManager.sharedInstance registerStorePlugin:filePlugin];
    
    // 注册 SA 的自定义插件
    for (id<SAStorePlugin> plugin in SABBridge.storePlugins) {
        [SABStoreManager.sharedInstance registerStorePlugin:plugin];
    }
}


#pragma mark - PropertyPlugins
/// 注册属性插件
- (void)resgisterPropertyPlugins {
    self.globalPropertyPlugin = [[SABTestGlobalPropertyPlugin alloc] init];
    [SABBridge registerABTestPropertyPlugin:self.globalPropertyPlugin];
}

/// 注销属性插件
- (void)unresgisterPropertyPlugins {
    [SABBridge unregisterWithPropertyPluginClass:SABTestGlobalPropertyPlugin.class];
    self.globalPropertyPlugin = nil;
}

/// 更新试验分流记录属性
- (void)refreshResultsResultIdSourcesProperties {
    NSArray *allResultIdOfResults = self.resultResponse.allResultIdOfResults;
    if (!self.trackConfig.propertySwitch || !allResultIdOfResults) {
        return;
    }

    [self refreshGlobalProperty:@{kSABAllResultsResultIdSourcesKey: allResultIdOfResults}];
}

/// 刷新试验命中记录属性
- (void)refreshHitExperimentResultIdSources {
    if (!self.trackConfig.propertySwitch) {
        return;
    }

    NSArray *resultIdSources = [self.hitRecordsManager queryAllResultIdOfHitRecordsWithUser:self.currentUserIndenty];
    if (!resultIdSources) {
        return;
    }

    [self refreshGlobalProperty:@{kSABAllHitExperimentResultIdSourcesKey: resultIdSources}];
}

/// 刷新插件采集属性
- (void)refreshGlobalProperty:(NSDictionary *)properties {
    if (!properties) {
        return;
    }
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(self.serialQueue)) {
        [self.globalPropertyPlugin refreshGlobalProperties:properties];
    } else {
        dispatch_async(self.serialQueue, ^{
            [self.globalPropertyPlugin refreshGlobalProperties:properties];
        });
    }
}
@end
