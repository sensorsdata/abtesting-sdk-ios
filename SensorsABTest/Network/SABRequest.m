//
//  SABRequest.m
//  SensorsABTest
//
//  Created by 张敏超🍎 on 2020/10/16.
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

#import "SABRequest.h"
#import "SABLogBridge.h"
#import "SABURLUtils.h"
#import "SABBridge.h"
#import "SABJSONUtils.h"
#import "SABConstants.h"

/// timeoutInterval 最小值保护
static NSTimeInterval kFetchABTestResultMinTimeoutInterval = 1;

@implementation SABExperimentRequest

- (instancetype)initWithBaseURL:(NSURL *)url projectKey:(NSString *)key {
    self = [super init];
    if (self) {
        _baseURL = url;
        _projectKey = key;
        _timeoutInterval = kSABFetchABTestResultDefaultTimeoutInterval;

        NSMutableDictionary *parametersBody = [NSMutableDictionary dictionary];
        parametersBody[@"platform"] = @"iOS";
        parametersBody[@"login_id"] = [SABBridge loginId];
        parametersBody[@"anonymous_id"] = [SABBridge anonymousId];
        // abtest sdk 版本号
        parametersBody[@"abtest_lib_version"] = kSABLibVersion;

        NSDictionary *presetProperties = [SABBridge presetProperties];
        if (presetProperties) {
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            properties[@"$app_version"] = presetProperties[@"$app_version"];
            properties[@"$os"] = presetProperties[@"$os"];
            properties[@"$os_version"] = presetProperties[@"$os_version"];
            properties[@"$model"] = presetProperties[@"$model"];
            properties[@"$manufacturer"] = presetProperties[@"$manufacturer"];
            // 运营商
            properties[@"$carrier"] = presetProperties[@"$carrier"];
            properties[@"$device_id"] = presetProperties[@"$device_id"];
            // 是否首日
            properties[@"$is_first_day"] = presetProperties[@"$is_first_day"];
            parametersBody[@"properties"] = properties;
        }
        _body = [parametersBody copy];
    }
    return self;
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

    request.HTTPBody = [SABJSONUtils JSONSerializeObject:self.body];
    
    return request;
}

@end
