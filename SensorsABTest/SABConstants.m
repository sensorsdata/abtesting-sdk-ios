//
//  SABConstants.m
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

#import "SABConstants.h"

// min SA SDK version required
NSString *const kSABMinSupportedSALibVersion = @"2.1.14";

#pragma mark eventName
NSString *const kSABTriggerEventName = @"$ABTestTrigger";

#pragma mark propertyName
// A/B 试验 ID
NSString *const kSABTriggerExperimentId = @"$abtest_experiment_id";

// A/B 试验组 ID
NSString *const kSABTriggerExperimentGroupId = @"$abtest_experiment_group_id";

#pragma mark - fileName
NSString *const kSABExperimentResultFileName = @"SensorsABTestExperimentResultFileName";

#pragma mark - NSNotificationName
/// SA 注入 H5 打通 Bridge
NSNotificationName const kSABRegisterSAJSBridgeNotification = @"SensorsAnalyticsRegisterJavaScriptBridgeNotification";

/// H5 发送 abtest 消息
NSNotificationName const kSABMessageFromH5Notification = @"SensorsAnalyticsMessageFromH5Notification";

