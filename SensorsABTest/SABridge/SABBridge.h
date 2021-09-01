//
//  SABBridge.h
//  SensorsABTest
//
//  Created by 储强盛 on 2020/9/15.
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

NS_ASSUME_NONNULL_BEGIN

/// 与 SensorsAnalyticsSDK 的桥接工具
@interface SABBridge : NSObject

/// 获取 SensorsAnalyticsSDK 单例
@property (class, nonatomic, strong, readonly) id sensorsAnalyticsInstance;

/// 匿名 Id
@property (class, nonatomic, copy, readonly) NSString *anonymousId;

/// 登录 Id
@property (class, nonatomic, copy, readonly) NSString *loginId;

/// 用户的唯标识 Id
@property (class, nonatomic, copy, readonly) NSString *distinctId;

/// 需要的预置属性
@property (class, nonatomic, copy, readonly) NSDictionary <NSString *, id>*presetProperties;

/// SA SDK 版本
@property (class, nonatomic, copy, readonly) NSString *libVersion;

/// 调用 track 接口，追踪一个带有属性的 event
/// @param eventName 事件名称
/// @param properties 事件属性
+ (void)track:(NSString *)eventName properties:(NSDictionary *)properties;

@end

NS_ASSUME_NONNULL_END
