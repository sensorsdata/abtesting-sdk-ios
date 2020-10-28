//
//  SABBridge.m
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

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "SABBridge.h"
#import "SABLogBridge.h"
#import "SABValidUtils.h"

typedef id (*SAGetPresetPropertiesMethod)(id, SEL);
typedef void (*SATrackEventMethod)(id, SEL, NSString *, NSDictionary *);

@implementation SABBridge

+ (id)sensorsAnalyticsInstance {
    Class saClass = NSClassFromString(@"SensorsAnalyticsSDK");
    if (!saClass) {
        SABLogError(@"Get SensorsAnalyticsSDK class failed");
        return nil;
    }
    SEL sharedInstanceSEL = NSSelectorFromString(@"sharedInstance");
    id (*sharedInstance)(id, SEL) = (id (*)(id, SEL))[saClass methodForSelector:sharedInstanceSEL];

    id sa = sharedInstance(saClass, sharedInstanceSEL);
    return sa;
}

#pragma mark get properties
+ (NSString *)anonymousId {
    return [self propertyWithName:@"anonymousId"];
}

+ (NSString *)loginId {
    return [self propertyWithName:@"loginId"];
}

+ (NSString *)distinctId {
    return [self propertyWithName:@"distinctId"];
}

+ (NSString *)libVersion {
    return [self propertyWithName:@"libVersion"];
}

+ (NSDictionary *)presetProperties {
    return [self propertyWithName:@"getPresetProperties"];
}

/// 根据方法名获取属性
/// @param name 名称
+ (instancetype)propertyWithName:(NSString *)name {
    id sa = [self sensorsAnalyticsInstance];
    if (!sa) {
        SABLogWarn(@"Get SensorsAnalyticsSDK.sharedIntance failed");
        return nil;
    }
    SEL propertySel = NSSelectorFromString(name);
    SAGetPresetPropertiesMethod method = (SAGetPresetPropertiesMethod)[sa methodForSelector:propertySel];
    return method(sa, propertySel);
}

#pragma mark track
+ (void)track:(NSString *)eventName properties:(NSDictionary *)properties {
    id sa = [self sensorsAnalyticsInstance];
    if (!sa) {
        SABLogWarn(@"Get SensorsAnalyticsSDK.sharedIntance failed");
        return;
    }
    SEL trackSel = NSSelectorFromString(@"track:withProperties:");
    SATrackEventMethod track = (SATrackEventMethod)[sa methodForSelector:trackSel];
    track(sa, trackSel, eventName, properties);
}
@end
