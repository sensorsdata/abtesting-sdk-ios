//
//  SABRequest.h
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

#import <Foundation/Foundation.h>
#import "SABFetchResultResponse.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SABRequestProtocol <NSObject>

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@property (nonatomic, copy, readonly) NSURLRequest *request;

@end

@interface SABExperimentRequest : NSObject <SABRequestProtocol>

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/// 请求时刻的用户标识
@property (nonatomic, strong) SABUserIdenty *userIdenty;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithBaseURL:(NSURL *)url projectKey:(NSString *)key NS_DESIGNATED_INITIALIZER;

/// 增加请求参数
/// @param body 需要增加的参数 body
- (void)appendRequestBody:(NSDictionary *)body;

/**
 * @abstract
 * 比较两个请求是否相同
 *
 * @discussion
 * 当前比较内容只包含 body 中的 login_id/anonymous_id/param_name/custom_properties 和 timeoutInterval
 *
 * @param request 进行比较的实例对象
*/
- (BOOL)isEqualToRequest:(SABExperimentRequest *)request;

@end

@interface SABWhiteListRequest : NSObject <SABRequestProtocol>

@property (nonatomic, copy) NSURL *openURL;

@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@property (nonatomic, copy) NSDictionary *body;

- (instancetype)initWithOpenURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
