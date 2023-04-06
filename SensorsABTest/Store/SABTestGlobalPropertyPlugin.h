//
// SABTestGlobalPropertyPlugin.h
// SensorsABTest
//
// Created by  储强盛 on 2023/1/19.
// Copyright © 2015-2023 Sensors Data Co., Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>

#if __has_include(<SensorsAnalyticsSDK/SensorsAnalyticsSDK.h>)
#import <SensorsAnalyticsSDK/SensorsAnalyticsSDK.h>
#elif __has_include("SensorsAnalyticsSDK.h")
#import "SensorsAnalyticsSDK.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// AB 全局属性插件，采集试验记录属性
@interface SABTestGlobalPropertyPlugin : SAPropertyPlugin

/// 刷新属性信息
///
/// 可能是命中记录或试验分流记录属性
- (void)refreshGlobalProperties:(NSDictionary *)properties;

@end

NS_ASSUME_NONNULL_END
