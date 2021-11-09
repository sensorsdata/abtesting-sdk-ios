//
//  SensorsABTest.h
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

#import <Foundation/Foundation.h>
#import "SensorsABTestConfigOptions.h"
#import "SensorsABTestExperiment.h"

NS_ASSUME_NONNULL_BEGIN

@interface SensorsABTest : NSObject

/// 返回神策 A/B Testing SDK 单例
@property (class, nonatomic, readonly) SensorsABTest* sharedInstance NS_SWIFT_NAME(shared);

/// 通过参数配置，开启神策 A/B Testing SDK
/// @param configOptions 参数配置
+ (void)startWithConfigOptions:(SensorsABTestConfigOptions *)configOptions NS_SWIFT_NAME(start(configOptions:));

/// 总是从缓存获取试验
/// @param paramName 试验参数名
/// @param defaultValue 默认结果
/// @return 试验值
- (nullable id)fetchCacheABTestWithParamName:(NSString *)paramName defaultValue:(id)defaultValue;

/// 异步从服务端获取最新试验结果，默认 timeout 为 30 秒
/// @param paramName 试验参数名
/// @param defaultValue 默认结果
/// @param completionHandler 主线程回调，返回试验结果
- (void)asyncFetchABTestWithParamName:(NSString *)paramName defaultValue:(id)defaultValue completionHandler:(void (^)(id _Nullable result))completionHandler;

/// 异步从服务端获取最新试验结果
/// @param paramName 试验参数名
/// @param defaultValue 默认结果
/// @param timeoutInterval 超时时间，单位为秒
/// @param completionHandler 主线程回调，返回试验结果
- (void)asyncFetchABTestWithParamName:(NSString *)paramName defaultValue:(id)defaultValue timeoutInterval:(NSTimeInterval)timeoutInterval completionHandler:(void (^)(id _Nullable result))completionHandler;

/// 异步从服务端获取最新试验结果
/// @param experiment 获取试验参数
/// @param completionHandler 主线程回调，返回试验结果
- (void)asyncFetchABTestWithExperiment:(SensorsABTestExperiment *)experiment completionHandler:(void (^)(id _Nullable result))completionHandler;

/// 优先从缓存获取试验结果，如果无缓存试验，则异步从网络请求
/// @param paramName 试验参数名
/// @param defaultValue 默认值
/// @param completionHandler 主线程回调，返回试验结果
- (void)fastFetchABTestWithParamName:(NSString *)paramName defaultValue:(id)defaultValue completionHandler:(void (^)(id _Nullable result))completionHandler;

/// 优先从缓存获取试验结果，如果无缓存试验，则异步从网络请求
/// @param paramName 试验参数名
/// @param defaultValue 默认值
/// @param timeoutInterval 超时时间，单位为秒
/// @param completionHandler 主线程回调，返回试验结果
- (void)fastFetchABTestWithParamName:(NSString *)paramName defaultValue:(id)defaultValue timeoutInterval:(NSTimeInterval)timeoutInterval completionHandler:(void (^)(id _Nullable result))completionHandler;

/// 优先从缓存获取试验结果，如果无缓存试验，则异步从网络请求
/// @param experiment 获取试验参数
/// @param completionHandler 主线程回调，返回试验结果
- (void)fastFetchABTestWithExperiment:(SensorsABTestExperiment *)experiment completionHandler:(void (^)(id _Nullable result))completionHandler;

/// 处理 url scheme 跳转打开 App
/// @param url URL 参数
/// @return YES/NO 是否为本业务的合法 url
- (BOOL)handleOpenURL:(NSURL *)url NS_SWIFT_NAME(handle(openURL:));

@end

NS_ASSUME_NONNULL_END
