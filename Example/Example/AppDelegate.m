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
static NSString* kSABResultsServerURL = @"http://abtesting.saas.debugbox.sensorsdata.cn/api/v2/abtest/online/results?project-key=0a551836f92dc3292be545c748f3f462e2d43bc9";

static NSString* kSABResultsTestServerURL = @"http://abtesting.saas.debugbox.sensorsdata.cn/api/v2/abtest/online/results?project-key=9868E3674EAF7697D779D8CE5F79D789BE40CFD4";

// 测试环境，数据接收地址
static NSString* kSABTestServerURL = @"http://10.120.239.245:8106/sa?project=default";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    SAConfigOptions *options = [[SAConfigOptions alloc] initWithServerURL:kSABTestServerURL launchOptions:launchOptions];
//    options.autoTrackEventType = SensorsAnalyticsEventTypeAppStart | SensorsAnalyticsEventTypeAppEnd | SensorsAnalyticsEventTypeAppClick | SensorsAnalyticsEventTypeAppViewScreen;
    options.autoTrackEventType = SensorsAnalyticsEventTypeAppStart | SensorsAnalyticsEventTypeAppEnd;
    options.enableTrackAppCrash = YES;

    options.enableHeatMap = YES;
    options.enableVisualizedAutoTrack = YES;
    options.enableJavaScriptBridge = YES;
    options.enableLog = YES;
    [SensorsAnalyticsSDK startWithConfigOptions:options];
    

    [[SensorsAnalyticsSDK sharedInstance] setFlushNetworkPolicy:SensorsAnalyticsNetworkTypeALL];

    SensorsABTestConfigOptions *abtestConfigOptions = [[SensorsABTestConfigOptions alloc] initWithURL:kSABResultsTestServerURL];
    [SensorsABTest startWithConfigOptions:abtestConfigOptions];
    
    return YES;
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if ([[SensorsABTest sharedInstance] handleOpenURL:url]) {
        return YES;
    }
    return NO;
}


@end
