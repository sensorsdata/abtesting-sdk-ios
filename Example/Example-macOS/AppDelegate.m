//
// AppDelegate.m
// Example-macOS
//
// Created by 储强盛 on 2021/6/18.
// Copyright © 2021-2022 Sensors Data Co., Ltd. All rights reserved.
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
static NSString* kSABResultsTestURL = @"http://10.1.131.245:8202/api/v2/abtest/online/results?project-key=D9493739E8353F0917275C992F0C605A31D120AB";

// 测试环境，数据接收地址
static NSString* SADefaultServerURL = @"http://10.1.137.85:8106/sa?project=default";


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

#ifdef DEBUG
    options.enableLog = YES;
    options.flushNetworkPolicy = SensorsAnalyticsNetworkTypeNONE;
#endif
    
    [SensorsAnalyticsSDK startWithConfigOptions:options];
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
//   return YES;
//}


@end
