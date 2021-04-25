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
/// 当前版本号
extern NSString *const kSABLibVersion;

/// SA 最低支持版本
extern NSString *const kSABMinSupportedSALibVersion;

#pragma mark eventName
/// $ABTestTrigger 事件名
extern NSString *const kSABTriggerEventName;

#pragma mark propertyName
/// A/B 试验组 ID
extern NSString *const kSABTriggerExperimentId;

/// A/B 试验 ID
extern NSString *const kSABTriggerExperimentGroupId;

/// 采集插件版本号
extern NSString *const kSABLibPluginVersion;

/// abtesting iOS SDK 版本号
extern NSString *const kSABIOSLibPrefix;

#pragma mark value
/// 请求试验 timeoutInterval 默认值
extern NSTimeInterval const kSABFetchABTestResultDefaultTimeoutInterval;

#pragma mark - fileName
/// 0.0.2 及之前版本试验缓存文件名
extern NSString *const kSABExperimentResultOldFileName;

/// 试验缓存文件名
extern NSString *const kSABExperimentResultFileName;

#pragma mark - NSNotificationName
#pragma mark H5 打通相关
/// SA 注入 H5 打通 Bridge
extern NSNotificationName const kSABRegisterSAJSBridgeNotification;

/// H5 发送 abtest 消息
extern NSNotificationName const kSABMessageFromH5Notification;

#pragma mark 用户 id 变化
// login
extern NSNotificationName const kSABSALoginNotification;

// logout
extern NSNotificationName const kSABSALogoutNotification;

// identify
extern NSNotificationName const kSABSAIdentifyNotification;

// resetAnonymousId
extern NSNotificationName const kSABSAResetAnonymousIdNotification;
