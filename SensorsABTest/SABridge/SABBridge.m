//
// SABBridge.m
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

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#if __has_include(<SensorsAnalyticsSDK/SensorsAnalyticsSDK.h>)
#import <SensorsAnalyticsSDK/SensorsAnalyticsSDK.h>
#elif __has_include("SensorsAnalyticsSDK.h")
#import "SensorsAnalyticsSDK.h"
#endif

#import "SABBridge.h"
#import "SABLogBridge.h"

@interface SensorsAnalyticsSDK(SABBridge)
@property (nonatomic, strong, readonly) SAConfigOptions *configOptions;
@end

@interface SAConfigOptions(SABBridge)

// 注册自定义插件
@property (nonatomic, strong, readonly) NSMutableArray *storePlugins;
@end

@implementation SABBridge

+ (id)sensorsAnalyticsInstance {
    id instance = nil;
    // 这里 catch SensorsAnalyticsSDK 未初始化的断言，依赖 SensorsABTesting 的断言提示
    @try {
        instance = SensorsAnalyticsSDK.sharedInstance;
    } @catch (NSException *exception) {
        SABLogWarn(@"%@", exception);
    } @finally {
        return instance;
    }
}

#pragma mark get properties
+ (NSString *)anonymousId {
    return [SensorsAnalyticsSDK.sharedInstance anonymousId];
}

+ (NSString *)loginId {
    return [SensorsAnalyticsSDK.sharedInstance loginId];
}

+ (NSString *)distinctId {
    return [SensorsAnalyticsSDK.sharedInstance distinctId];
}

+ (NSString *)libVersion {
    return [SensorsAnalyticsSDK.sharedInstance libVersion];
}

+ (NSDictionary *)presetProperties {
    return [SensorsAnalyticsSDK.sharedInstance getPresetProperties];
}

+ (NSMutableArray *)storePlugins {
    return SensorsAnalyticsSDK.sharedInstance.configOptions.storePlugins;
}

#pragma mark track
+ (void)track:(NSString *)eventName properties:(NSDictionary *)properties {
    [SensorsAnalyticsSDK.sharedInstance track:eventName withProperties:properties];
}

+ (void)registerABTestPropertyPlugin:(SAPropertyPlugin *)propertyPlugin {
    [SensorsAnalyticsSDK.sharedInstance registerPropertyPlugin:propertyPlugin];
}

+ (void)unregisterWithPropertyPluginClass:(Class)pluginClass {
    [SensorsAnalyticsSDK.sharedInstance unregisterPropertyPluginWithPluginClass:pluginClass];
}
@end
