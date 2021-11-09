//
//  AppDelegate.m
//  Example
//
//  Created by 储强盛 on 2020/8/20.
//  Copyright © 2020 Sensors Data Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <SensorsAnalyticsSDK.h>
#import <SensorsABTest.h>

/// 测试环境，获取试验地址
static NSString* kSABResultsTestURL = @"http://abtesting.saas.debugbox.sensorsdata.cn/api/v2/abtest/online/results?project-key=438B9364C98D54371751BA82F6484A1A03A5155E";

// 测试环境，数据接收地址
static NSString* kSABTestServerURL = @"http://10.130.6.4:8106/sa?project=default";

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
    options.autoTrackEventType = SensorsAnalyticsEventTypeAppStart | SensorsAnalyticsEventTypeAppEnd | SensorsAnalyticsEventTypeAppClick | SensorsAnalyticsEventTypeAppViewScreen;

    options.enableHeatMap = YES;
    options.enableVisualizedAutoTrack = YES;
    options.enableJavaScriptBridge = YES;
    options.enableLog = YES;
    options.flushNetworkPolicy = SensorsAnalyticsNetworkTypeALL;

    [SensorsAnalyticsSDK startWithConfigOptions:options];
}

- (void)startSensorsABTest {
    SensorsABTestConfigOptions *abtestConfigOptions = [[SensorsABTestConfigOptions alloc] initWithURL:kSABResultsTestURL];
    [SensorsABTest startWithConfigOptions:abtestConfigOptions];

}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if ([[SensorsABTest sharedInstance] handleOpenURL:url]) {
        return YES;
    }
    return NO;
}

@end
