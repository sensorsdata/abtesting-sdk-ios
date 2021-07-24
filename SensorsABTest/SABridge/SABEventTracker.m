//
//  SABEventTracker.m
//  SensorsABTesting
//
//  Created by 储强盛 on 2021/5/11.
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

#import "SABEventTracker.h"
#import "SABConstants.h"

static NSString * const kSALoginId = @"login_id";
static NSString * const kSADistinctId = @"distinct_id";
static NSString * const kSAAnonymousId = @"anonymous_id";
static NSString * const kSAProperties = @"properties";

@implementation SABEventTracker

- (void)sensorsabtest_trackEvent:(NSMutableDictionary *)event isSignUp:(BOOL)isSignUp {
    NSString *eventName = event[@"event"];
    NSDictionary *properties = event[kSAProperties];

    if ([eventName isKindOfClass:[NSString class]] && [eventName isEqualToString: kSABTriggerEventName] && [properties isKindOfClass:[NSDictionary class]]) {

        // 实际为 NSMutableDictionary，直接修改即可，从而保证 SAEventTracker 日志打印中 distinct_id 等信息为修改后的
        NSMutableDictionary *tempEvent = event;
        if (![event isKindOfClass:NSMutableDictionary.class]) {
            tempEvent = [event mutableCopy];
        }

        // 用于移除 properties 中的 loginId, distinctId,anonymousId
        NSMutableDictionary *tempProperties = [properties mutableCopy];

        // 修改 loginId, distinctId,anonymousId
        if (properties[kSABLoginId]) {
            tempEvent[kSALoginId] = properties[kSABLoginId];
            tempProperties[kSABLoginId] = nil;
        }

        if (properties[kSABDistinctId]) {
            tempEvent[kSADistinctId] = properties[kSABDistinctId];
            tempProperties[kSABDistinctId] = nil;
        }

        if (properties[kSABAnonymousId]) {
            tempEvent[kSAAnonymousId] = properties[kSABAnonymousId];
            tempProperties[kSABAnonymousId] = nil;
        }

        tempEvent[kSAProperties] = tempProperties;
        [self sensorsabtest_trackEvent:tempEvent isSignUp:isSignUp];
    } else {
        [self sensorsabtest_trackEvent:event isSignUp:isSignUp];
    }
}

@end
