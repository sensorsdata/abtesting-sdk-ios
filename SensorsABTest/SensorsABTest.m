//
//  SensorsABTest.m
//  SensorsABTest
//
//  Created by 储强盛 on 2020/8/20.
//  Copyright © 2020 Sensors Data Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import <UIKit/UIApplication.h>
#import <WebKit/WebKit.h>
#import "SensorsABTest.h"
#import "SABLogBridge.h"
#import "SABBridge.h"
#import "NSString+SABHelper.h"
#import "SABManager.h"
#import "SABConstants.h"
#import "SABNetwork.h"
#import "SensorsABTestConfigOptions+Private.h"
#import "SABRequest.h"

static SensorsABTest *sharedABTest = nil;

@interface SensorsABTest()
@property (nonatomic, strong) SABManager *manager;
@end

@implementation SensorsABTest

/// 通过配置参数，配置神策 A/B Testing SDK
/// @param configOptions 参数配置
+ (void)startWithConfigOptions:(SensorsABTestConfigOptions *)configOptions {

    if (sharedABTest) {
        SABLogWarn(@"A/B Testing SDK repeat initialization! Only the first initialization valid!");
        return;
    }

    // 判断 configOptions 有效性
    NSAssert(configOptions.projectKey && configOptions.baseURL, @"请通过正确 url 初始化 SABConfigOptions 对象");
    if (!configOptions.projectKey || !configOptions.baseURL) {
        SABLogError(@"Initialize the SABConfigOptions object with the valid URL");
        return;
    }

    // 判断 SensorsAnalyticsSDK 有效性
    NSAssert([SABBridge sensorsAnalyticsInstance], @"SensorsABTest SDK 依赖 SensorsAnalyticsSDK, 请先初始化 SensorsAnalyticsSDK");
    NSAssert([SensorsABTest isSupportedSAVersion], @"SensorsABTest SDK 依赖 SensorsAnalyticsSDK, SensorsAnalyticsSDK 最低要求版本为： %@", kSABMinSupportedSALibVersion);
    if (![SABBridge sensorsAnalyticsInstance] || ![SensorsABTest isSupportedSAVersion]) {
        SABLogError(@"SensorsABTest SDK depend SensorsAnalyticsSDK initialization, SensorsAnalyticsSDK required minimum version is %@", kSABMinSupportedSALibVersion);
        return;
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedABTest = [[SensorsABTest alloc] initWithConfigOptions:configOptions];
    });
    SABLogInfo(@"start SensorsABTest success");
}

/// 返回 神策 A/B Testing SDK 单例
+ (SensorsABTest *)sharedInstance {
    NSAssert(sharedABTest, @"请先使用 startWithConfigOptions: 初始化 SDK");
    return sharedABTest;
}

#pragma mark - initialize
- (instancetype)initWithConfigOptions:(nonnull SensorsABTestConfigOptions *)configOptions {
    self = [super init];
    if (self) {
        self.manager = [[SABManager alloc] initWithConfigOptions:configOptions];
    }
    return self;
}

#pragma mark - fetch ABTest API
- (nullable id)fetchCacheABTestWithParamName:(NSString *)paramName defaultValue:(id)defaultValue {
    __block id resultValue = defaultValue;
    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeCache paramName:paramName defaultValue:defaultValue timeoutInterval:kSABFetchABTestResultDefaultTimeoutInterval completionHandler:^(id  _Nullable result) {
        resultValue = result;
    }];
    return resultValue;
}

- (void)asyncFetchABTestWithParamName:(NSString *)paramName defaultValue:(id)defaultValue completionHandler:(void (^)(id _Nullable result))completionHandler {
    [self asyncFetchABTestWithParamName:paramName defaultValue:defaultValue timeoutInterval:kSABFetchABTestResultDefaultTimeoutInterval completionHandler:completionHandler];
}

- (void)asyncFetchABTestWithParamName:(NSString *)paramName defaultValue:(id)defaultValue timeoutInterval:(NSTimeInterval)timeoutInterval completionHandler:(void (^)(id _Nullable result))completionHandler {
    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeAsync paramName:paramName defaultValue:defaultValue timeoutInterval:timeoutInterval completionHandler:completionHandler];
}

- (void)fastFetchABTestWithParamName:(NSString *)paramName defaultValue:(id)defaultValue completionHandler:(void (^)(id _Nullable result))completionHandler {
    [self fastFetchABTestWithParamName:paramName defaultValue:defaultValue timeoutInterval:kSABFetchABTestResultDefaultTimeoutInterval completionHandler:completionHandler];
}

- (void)fastFetchABTestWithParamName:(NSString *)paramName defaultValue:(id)defaultValue timeoutInterval:(NSTimeInterval)timeoutInterval completionHandler:(void (^)(id _Nullable result))completionHandler {
    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeFast paramName:paramName defaultValue:defaultValue timeoutInterval:timeoutInterval completionHandler:completionHandler];
}

#pragma mark action
- (BOOL)handleOpenURL:(NSURL *)url {
    if (![url isKindOfClass:NSURL.class] || ![url.host isEqualToString:@"abtest"]) {
        return NO;
    }
    SABWhiteListRequest *requestData = [[SABWhiteListRequest alloc] initWithOpenURL:url];
    [SABNetwork dataTaskWithRequest:requestData.request completionHandler:^(id  _Nullable jsonObject, NSError * _Nullable error) {
        
        if (error) {
            SABLogWarn(@"upload distinctId failure，error:%@", error);
        } else {
            SABLogInfo(@"upload distinctId success，jsonObject：%@", jsonObject);
        }
    }];
    return YES;
}

+ (BOOL)isSupportedSAVersion {
    return [SABBridge.libVersion sensorsabtest_compareVersion:kSABMinSupportedSALibVersion] != NSOrderedAscending ;
}

@end
