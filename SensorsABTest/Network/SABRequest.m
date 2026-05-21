//
// SABRequest.m
// SensorsABTest
//
// Created by 张敏超🍎 on 2020/10/16.
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

#import "SABRequest.h"
#import "SABLogBridge.h"
#import "SABURLUtils.h"
#import "SABBridge.h"
#import "SABJSONUtils.h"
#import "SABConstants.h"
#import "SABValidUtils.h"
#import "NSString+SABHelper.h"

/// timeoutInterval 最小值保护
static NSTimeInterval kFetchABTestResultMinTimeoutInterval = 1;

NSString *const kSABRequestBodyCustomIDs = @"custom_ids";
NSString *const kSABRequestBodyCustomProperties = @"custom_properties";
NSString *const kSABRequestBodyLoginID = @"login_id";
NSString *const kSABRequestBodyAnonymousID = @"anonymous_id";
NSString *const kSABRequestBodyTimeoutInterval = @"timeout_interval";

@interface SABExperimentRequest()

@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, copy) NSString *projectKey;
@property (nonatomic, strong) NSMutableDictionary *body;

@end

@implementation SABExperimentRequest

// 初始化 App 原生分流请求
- (instancetype)initAppRequestWithBaseURL:(NSURL *)url projectKey:(NSString *)key userIdenty:(SABUserIdenty *)userIdenty {
    self = [[SABExperimentRequest alloc] initRequestWithBaseURL:url projectKey:key userIdenty:userIdenty];
    if (self) {
        // 拼接自定义主体 ID
        [self appendCustomIDs:self.userIdenty.customIDs];
    }
    return self;
}

// 初始化公共基础分流请求
// App 内嵌 H5 分流请求直接使用
- (instancetype)initRequestWithBaseURL:(NSURL *)url projectKey:(NSString *)key userIdenty:(SABUserIdenty *)userIdenty {
    self = [super init];
    if (self) {
        _baseURL = url;
        _projectKey = key;
        _timeoutInterval = kSABFetchABTestResultDefaultTimeoutInterval;

        _userIdenty = [userIdenty copy];

        NSMutableDictionary *parametersBody = [NSMutableDictionary dictionary];

#if TARGET_OS_OSX
        parametersBody[@"platform"] = @"macOS";
#else
        parametersBody[@"platform"] = @"iOS";
#endif
        parametersBody[kSABRequestBodyLoginID] = _userIdenty.loginId;
        parametersBody[kSABRequestBodyAnonymousID] = _userIdenty.anonymousId;
        // abtest sdk 版本号
        parametersBody[@"abtest_lib_version"] = kSABLibVersion;

        NSDictionary *presetProperties = [SABBridge presetProperties];
        // 需要的部分 App 预置属性
        if (presetProperties) {
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            properties[@"$app_version"] = presetProperties[@"$app_version"];
            properties[@"$os"] = presetProperties[@"$os"];
            properties[@"$os_version"] = presetProperties[@"$os_version"];
            properties[@"$model"] = presetProperties[@"$model"];
            properties[@"$manufacturer"] = presetProperties[@"$manufacturer"];
            // 运营商
            properties[@"$carrier"] = presetProperties[@"$carrier"];
            // 是否首日
            properties[@"$is_first_day"] = presetProperties[@"$is_first_day"];
            parametersBody[@"properties"] = properties;
        }
        _body = parametersBody;

    }
    return self;
}

- (void)appendCustomIDs:(NSDictionary *)customIDs {
    if (customIDs.count == 0) {
        return;
    }
    [self appendRequestBody:@{kSABRequestBodyCustomIDs: customIDs}];
}

- (void)appendRequestBody:(NSDictionary *)body {
    if (![SABValidUtils isValidDictionary:body]) {
        return;
    }
    [self.body addEntriesFromDictionary:body];
}

- (NSDictionary *)compareParams {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[kSABRequestBodyLoginID] = self.body[kSABRequestBodyLoginID];
    params[kSABRequestBodyAnonymousID] = self.body[kSABRequestBodyAnonymousID];
    params[kSABRequestBodyTimeoutInterval] = @(self.timeoutInterval);
    params[kSABRequestBodyCustomProperties] = self.body[kSABRequestBodyCustomProperties];
    params[kSABRequestBodyCustomIDs] = self.body[kSABRequestBodyCustomIDs];
    return params;
}

- (BOOL)isEqualToRequest:(SABExperimentRequest *)request {
    return [[request compareParams] isEqualToDictionary:[self compareParams]];
}

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval {
    // timeoutInterval 合法性校验
    if (timeoutInterval <= 0) {
        SABLogWarn(@"setup timeoutInterval invalid，%f", timeoutInterval);
        _timeoutInterval = kSABFetchABTestResultDefaultTimeoutInterval;
    } else if (timeoutInterval < kFetchABTestResultMinTimeoutInterval) {
        SABLogWarn(@"setup timeoutInterval invalid，%f", timeoutInterval);
        _timeoutInterval = kFetchABTestResultMinTimeoutInterval;
    } else {
        _timeoutInterval = timeoutInterval;
    }
}

- (NSURLRequest *)request {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_baseURL];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = _timeoutInterval;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    // 设置 HTTPHeader
    [request setValue:self.projectKey forHTTPHeaderField:@"project-key"];

    // 设置 HTTPBody
    request.HTTPBody = [SABJSONUtils JSONSerializeObject:self.body];

    return request;
}

@end

@implementation SABWhiteListRequest

- (instancetype)initWithOpenURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _openURL = url;
        _timeoutInterval = 30;

        NSDictionary<NSString *, NSString *> *queryItemsDic = [SABURLUtils queryItemsWithURL:self.openURL];
        _baseURL = [NSURL URLWithString:queryItemsDic[@"sensors_abtest_url"]];

        NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
        paramsDic[@"feature_code"] = queryItemsDic[@"feature_code"];
        paramsDic[@"account_id"] = queryItemsDic[@"account_id"];
        paramsDic[@"distinct_id"] = [SABBridge distinctId];
        _body = [paramsDic copy];
    }
    return self;
}

- (NSURLRequest *)request {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_baseURL];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = _timeoutInterval;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    /* 关闭 Keep-Alive，
     此处设置关闭 Keep-Alive，防止频繁连续扫码，后端 TCP 连接可能断开，并且扫码打开 App 此时尚未完全进入前台，NSURLSession 没有自动重试，导致扫码上传白名单可能失败
     */
    [request setValue:@"close" forHTTPHeaderField:@"Connection"];
    request.HTTPBody = [SABJSONUtils JSONSerializeObject:self.body];
    
    return request;
}

@end
