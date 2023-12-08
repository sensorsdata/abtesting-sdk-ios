//
// SABConstants.m
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

#import "SABConstants.h"

// 当前版本号
NSString *const kSABLibVersion = @"1.0.2";

// SA 最低支持版本
NSString *const kSABMinSupportedSALibVersion = @"4.5.6";

#if TARGET_OS_OSX
NSString *const kSABLibPrefix = @"macos_abtesting";
#else
// abtesting 插件版本号前缀
NSString *const kSABLibPrefix = @"ios_abtesting";
#endif

#pragma mark eventName
NSString *const kSABTriggerEventName = @"$ABTestTrigger";

#pragma mark propertyName
// A/B 试验 ID
NSString *const kSABTriggerExperimentId = @"$abtest_experiment_id";

// A/B 试验组 ID
NSString *const kSABTriggerExperimentGroupId = @"$abtest_experiment_group_id";

// 采集插件版本号
NSString *const kSABLibPluginVersion = @"$lib_plugin_version";

#pragma mark userId
NSString *const kSABLoginId = @"sab_loginId";

NSString *const kSABDistinctId = @"sab_distinctId";

NSString *const kSABAnonymousId = @"sab_anonymousId";


#pragma mark value
NSTimeInterval const kSABFetchABTestResultDefaultTimeoutInterval = 30;

#pragma mark - fileName
NSString *const kSABExperimentResultFileName = @"SensorsABTestExperimentResultsResponseData";

NSString *const kSABCustomIDsFileName = @"SensorsABTestCustomIDs";

NSString *const kSABHitExperimentRecordSourcesFileName = @"SensorsABTestHitExperimentRecordSourcesData";

NSString *const kSABTestTrackConfigFileName = @"SensorsABTestTrackConfigSources";

#pragma mark - NSNotificationName，依赖 SA
#pragma mark H5 打通相关
/// SA 注入 H5 打通 Bridge
NSNotificationName const kSABSARegisterSAJSBridgeNotification = @"SensorsAnalyticsRegisterJavaScriptBridgeNotification";

/// H5 发送 abtest 消息
NSNotificationName const kSABSAMessageFromH5Notification = @"SensorsAnalyticsMessageFromH5Notification";

#pragma mark 用户 id 变化
// login
NSNotificationName const kSABSALoginNotification = @"SensorsAnalyticsTrackLoginNotification";

// logout
NSNotificationName const kSABSALogoutNotification = @"SensorsAnalyticsTrackLogoutNotification";

// identify
NSNotificationName const kSABSAIdentifyNotification = @"SensorsAnalyticsTrackIdentifyNotification";

// resetAnonymousId
NSNotificationName const kSABSAResetAnonymousIdNotification = @"SensorsAnalyticsTrackResetAnonymousIdNotification";

#pragma mark other
// 监听 SA 的生命周期通知，依赖版本 v2.6.3 及以上
NSNotificationName const kSABSAAppLifecycleStateDidChangeNotification = @"com.sensorsdata.SAAppLifecycleStateDidChange";


void sabtest_dispatch_safe_async(dispatch_queue_t queue,DISPATCH_NOESCAPE dispatch_block_t block) {
    if ((dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)) == dispatch_queue_get_label(queue)) {
        block();
    } else {
        dispatch_async(queue, block);
    }
}

void sabtest_dispatch_safe_sync(dispatch_queue_t queue,DISPATCH_NOESCAPE dispatch_block_t block) {
    if ((dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)) == dispatch_queue_get_label(queue)) {
        block();
    } else {
        dispatch_sync(queue, block);
    }
}
