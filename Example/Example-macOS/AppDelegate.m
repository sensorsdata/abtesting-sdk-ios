//
//  AppDelegate.m
//  Example-macOS
//
//  Created by 储强盛 on 2021/6/18.
//  Copyright © 2021 Sensors Data Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <SensorsAnalyticsSDK.h>
#import <SensorsABTest.h>


static NSString *const SADefaultServerURL = @"http://10.130.6.4:8106/sa?project=default";

/// 测试环境，获取试验地址
static NSString* kSABResultsTestURL = @"http://abtesting.saas.debugbox.sensorsdata.cn/api/v2/abtest/online/results?project-key=438B9364C98D54371751BA82F6484A1A03A5155E";


@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    [self startSensorsAnalyticsSDKWithLaunching:aNotification];

    [self startSensorsABTest];
}

-  (void)startSensorsAnalyticsSDKWithLaunching:(NSNotification *)aNotification {
    SAConfigOptions *options = [[SAConfigOptions alloc] initWithServerURL:SADefaultServerURL launchOptions:nil];
    options.enableJavaScriptBridge = YES;
    options.enableLog = YES;
    [SensorsAnalyticsSDK startWithConfigOptions:options];

    [[SensorsAnalyticsSDK sharedInstance] setFlushNetworkPolicy:SensorsAnalyticsNetworkTypeALL];
}

- (void)startSensorsABTest {
    SensorsABTestConfigOptions *abtestConfigOptions = [[SensorsABTestConfigOptions alloc] initWithURL:kSABResultsTestURL];
    [SensorsABTest startWithConfigOptions:abtestConfigOptions];
}

- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls {
    for (NSURL *url in urls) {
        if ([SensorsABTest.sharedInstance handleOpenURL:url]) {
            return;
        }
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

//- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application {
//    return YES;
//}


@end
