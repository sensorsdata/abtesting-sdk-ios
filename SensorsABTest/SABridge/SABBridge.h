//
// SABBridge.h
// SensorsABTest
//
// Created by 储强盛 on 2020/9/15.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SAPropertyPlugin;

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

/// SA 自定义加密插件
@property (class, nonatomic, strong, readonly) NSMutableArray *storePlugins;

/// 调用 track 接口，追踪一个带有属性的 event
/// @param eventName 事件名称
/// @param properties 事件属性
+ (void)track:(NSString *)eventName properties:(NSDictionary *)properties;

/// 注册 AB 属性插件
/// @param propertyPlugin 属性插件
+ (void)registerABTestPropertyPlugin:(SAPropertyPlugin *)propertyPlugin;

/// 注销 AB 属性插件
/// @param pluginClass 属性插件类型
+ (void)unregisterWithPropertyPluginClass:(Class)pluginClass;
@end

NS_ASSUME_NONNULL_END
