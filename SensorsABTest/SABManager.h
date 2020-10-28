//
//  SABManager.h
//  SensorsABTest
//
//  Created by 储强盛 on 2020/9/29.
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

/**
 * @abstract
 * 获取试验结果方式类型
 *
 * @discussion
 * 获取试验结果方式类型
 *   SABFetchABTestModeType - 从缓存获取
 *   SABFetchABTestModeTypeAsync - 异步请求获取
 *   SABFetchABTestModeTypeFast - 快速获取
 */
typedef NS_OPTIONS(NSInteger, SABFetchABTestModeType) {
    SABFetchABTestModeTypeCache,
    SABFetchABTestModeTypeAsync,
    SABFetchABTestModeTypeFast
};


NS_ASSUME_NONNULL_BEGIN

/// 试验结果数据管理
@interface SABManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// SABManager 初始化
/// @param configOptions configOptions 参数配置
/// @return SABManager 实例对象
- (instancetype)initWithConfigOptions:(SensorsABTestConfigOptions *)configOptions NS_DESIGNATED_INITIALIZER;

/// 获取试验结果
/// @param type 获取试验结果方式
/// @param experimentId 试验 Id
/// @param defaultValue 默认结果
/// @param timeoutInterval 超时时间，单位为秒
/// @param completionHandler 回调返回试验结果
- (void)fetchABTestWithModeType:(SABFetchABTestModeType)type experimentId:(NSString *)experimentId defaultValue:(id)defaultValue timeoutInterval:(NSTimeInterval)timeoutInterval completionHandler:(void (^)(id _Nullable result))completionHandler;

@end

NS_ASSUME_NONNULL_END
