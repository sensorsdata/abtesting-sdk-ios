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

NS_ASSUME_NONNULL_BEGIN

@protocol SABRequestProtocol <NSObject>

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@property (nonatomic, copy, readonly) NSURLRequest *request;

@end

@interface SABExperimentRequest : NSObject <SABRequestProtocol>

@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, copy) NSString *projectKey;

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@property (nonatomic, copy) NSDictionary *body;

/// 更新用户标识信息
- (void)refreshUserIdenty;

- (instancetype)initWithBaseURL:(NSURL *)url projectKey:(NSString *)key;

@end

@interface SABWhiteListRequest : NSObject <SABRequestProtocol>

@property (nonatomic, copy) NSURL *openURL;

@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@property (nonatomic, copy) NSDictionary *body;

- (instancetype)initWithOpenURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
