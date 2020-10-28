//
//  SABConstants.h
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

#pragma mark libVersion
extern NSString *const kSABMinSupportedSALibVersion;

#pragma mark eventName
extern NSString *const kSABTriggerEventName;

#pragma mark propertyName
extern NSString *const kSABTriggerExperimentId;

extern NSString *const kSABTriggerExperimentGroupId;

#pragma mark - fileName
extern NSString *const kSABExperimentResultFileName;


#pragma mark - NSNotificationName
/// SA 注入 H5 打通 Bridge
extern NSNotificationName const kSABRegisterSAJSBridgeNotification;
/// H5 发送 abtest 消息
extern NSNotificationName const kSABMessageFromH5Notification;
