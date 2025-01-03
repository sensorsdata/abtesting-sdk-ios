//
// AppDelegate.m
// Example
//
// Created by 储强盛 on 2020/8/20.
// Copyright © 2020-2022 Sensors Data Co., Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "AppDelegate.h"
#import <SensorsAnalyticsSDK.h>
#import <SensorsABTest.h>

/// 测试环境，获取试验地址
static NSString* kSABResultsTestURL = @"http://10.1.132.85:8202/api/v2/abtest/online/results?project-key=CDF5B1BE9CDCBEB289EA0589066A263D741742BD";

// 测试环境，数据接收地址
static NSString* kSABTestServerURL =  @"http://10.1.132.86:8106/sa?project=default";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [self startSensorsAnalyticsSDKWithConfigOptions:launchOptions];

    [self startSensorsABTest];
    
    return YES;
}

- (void)startSensorsAnalyticsSDKWithConfigOptions:(NSDictionary *)launchOptions {
    SAConfigOptions *options = [[SAConfigOptions alloc] initWithServerURL:kSABTestServerURL launchOptions:launchOptions];
//    options.autoTrackEventType = SensorsAnalyticsEventTypeAppStart | SensorsAnalyticsEventTypeAppEnd | SensorsAnalyticsEventTypeAppClick | SensorsAnalyticsEventTypeAppViewScreen;
//    options.autoTrackEventType = SensorsAnalyticsEventTypeAppStart | SensorsAnalyticsEventTypeAppEnd | SensorsAnalyticsEventTypeAppViewScreen;

    options.enableHeatMap = YES;
    options.enableVisualizedAutoTrack = YES;
    options.enableJavaScriptBridge = YES;
#ifdef DEBUG
    options.enableLog = YES;
    options.flushNetworkPolicy = SensorsAnalyticsNetworkTypeNONE;
#endif

    [SensorsAnalyticsSDK startWithConfigOptions:options];

//    [SensorsAnalyticsSDK.sharedInstance identify:@"cqs_identify_20241230001"];

    [[SensorsAnalyticsSDK sharedInstance] track:@"test_track" withProperties:@{@"city": @"beijing"}];

}

- (void)startSensorsABTest {
    SensorsABTestConfigOptions *abtestConfigOptions = [[SensorsABTestConfigOptions alloc] initWithURL:kSABResultsTestURL];
//    abtestConfigOptions.customProperties = @{@"ab_city": @"beijing"};
    [SensorsABTest startWithConfigOptions:abtestConfigOptions];

//    [SensorsABTest.sharedInstance setCustomIDs:@{@"custom_subject_id":@"iOS自定义主体333"}];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if ([[SensorsABTest sharedInstance] handleOpenURL:url]) {
        return YES;
    }
    return NO;
}

@end
