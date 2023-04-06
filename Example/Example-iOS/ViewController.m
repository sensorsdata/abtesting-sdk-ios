//
// ViewController.m
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

#import "ViewController.h"
#import "WKWebViewController.h"
#import <SensorsABTest.h>
#import <SensorsAnalyticsSDK.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.rowHeight = 50;
    self.tableView.sectionHeaderHeight = 12;
    self.tableView.sectionFooterHeight = 0;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row;
    NSUInteger section = indexPath.section;
    switch (section) {
        case 0: {// fetchCache
            switch (row) {
                case 0: { // INTEGER
                    id result = [[SensorsABTest sharedInstance] fetchCacheABTestWithParamName:@"color1" defaultValue:@(1111)];
                    NSLog(@"fetchCacheABTest，paramName：%@ - result:%@\n", @"color1", result);
                    
                    //                    id result2 = [[SensorsABTest sharedInstance] fetchCacheABTestWithParamName:@"102" defaultValue:@(1111)];
                    //                    NSLog(@"fetchCacheABTest，paramName：%@ - result:%@\n", @"102", result2);
                }
                    break;
                    
                case 1: { // BOOLEAN
                    id result = [[SensorsABTest sharedInstance] fetchCacheABTestWithParamName:@"16" defaultValue:@(NO)];
                    NSLog(@"fetchCacheABTest，paramName：%@ - result:%@\n", @"16", result);
                }
                    break;
                    
                case 2: { // STRING
                    id result = [[SensorsABTest sharedInstance] fetchCacheABTestWithParamName:@"hef_tes" defaultValue:@"默认值字符串"];
                    NSLog(@"fetchCacheABTest，paramName：%@ - result:%@\n", @"hef_tes", result);
                }
                    break;
                    
                case 3: { // JSON
                    id result = [[SensorsABTest sharedInstance] fetchCacheABTestWithParamName:@"color4" defaultValue:@{}];
                    NSLog(@"fetchCacheABTest，paramName：%@ - result:%@\n", @"color4", result);
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 1: { // asyncFetch
            switch (row) {
                case 0: { // INTEGER
                    [[SensorsABTest sharedInstance] asyncFetchABTestWithParamName:@"color1" defaultValue:@(1111) completionHandler:^(id _Nullable result) {
                        NSLog(@"asyncFetchABTest，paramName：%@ - result:%@\n", @"color1", result);
                    }];
                    
                    [[SensorsABTest sharedInstance] asyncFetchABTestWithParamName:@"19" defaultValue:@(1111) completionHandler:^(id _Nullable result) {
                        NSLog(@"asyncFetchABTest，paramName：%@ - result:%@\n", @"19", result);
                    }];
                }
                    break;
                    
                case 1: { // BOOLEAN
                    [[SensorsABTest sharedInstance] asyncFetchABTestWithParamName:@"color3" defaultValue:@(NO) completionHandler:^(id _Nullable result) {
                        NSLog(@"asyncFetchABTest，paramName：%@ - result:%@\n", @"color3", result);
                    }];
                }
                    break;
                    
                case 2: { // STRING
                    [[SensorsABTest sharedInstance] asyncFetchABTestWithParamName:@"color2" defaultValue:@"默认值字符串" completionHandler:^(id _Nullable result) {
                        NSLog(@"asyncFetchABTest，paramName：%@ - result:%@\n", @"color2", result);
                    }];
                }
                    break;
                    
                case 3: { // JSON
                    [[SensorsABTest sharedInstance] asyncFetchABTestWithParamName:@"color4" defaultValue:@{} completionHandler:^(id _Nullable result) {
                        NSLog(@"asyncFetchABTest，paramName：%@ - result:%@\n", @"color4", result);
                    }];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 2: { // fastFetch
            switch (row) { // 试验 Id
                case 0: { // INTEGER
                    [[SensorsABTest sharedInstance] fastFetchABTestWithParamName:@"color1" defaultValue:@(1111) completionHandler:^(id _Nullable result) {
                        NSLog(@"fastFetchABTest，paramName：%@ - result:%@\n", @"color1", result);
                    }];
                    
                    [[SensorsABTest sharedInstance] fastFetchABTestWithParamName:@"21" defaultValue:@(1111) completionHandler:^(id _Nullable result) {
                        NSLog(@"asyncFetchABTest，paramName：%@ - result:%@\n", @"21", result);
                    }];
                }
                    break;
                    
                case 1: { // BOOLEAN
                    [[SensorsABTest sharedInstance] fastFetchABTestWithParamName:@"color3" defaultValue:@(NO) completionHandler:^(id _Nullable result) {
                        NSLog(@"fastFetchABTest，paramName：%@ - result:%@\n", @"color3", result);
                    }];
                }
                    break;
                    
                case 2: { // STRING
                    [[SensorsABTest sharedInstance] fastFetchABTestWithParamName:@"color2" defaultValue:@"默认值字符串" completionHandler:^(id _Nullable result) {
                        NSLog(@"fastFetchABTest，paramName：%@ - result:%@\n", @"color2", result);
                    }];
                }
                    break;
                    
                case 3: { // JSON
                    [[SensorsABTest sharedInstance] fastFetchABTestWithParamName:@"color4" defaultValue:@{} completionHandler:^(id _Nullable result) {
                        NSLog(@"fastFetchABTest，paramName：%@ - result:%@\n", @"color4", result);
                    }];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 3: { // Subject 多主体，fache 接口
            switch (row) { //
                case 0: { // user 主体
                    id result = [[SensorsABTest sharedInstance] fetchCacheABTestWithParamName:@"li" defaultValue:@(1111)];
                    NSLog(@"fetchCacheABTest，Subject User，paramName：%@ - result:%@\n", @"li", result);
                }
                    break;
                    
                case 1: { // device 主体
                    id result = [[SensorsABTest sharedInstance] fetchCacheABTestWithParamName:@"cqs_color" defaultValue:@"默认试验值"];
                    NSLog(@"fetchCacheABTest，Subject Device，paramName：%@ - result:%@\n", @"cqs_color", result);
                }
                    break;
                case 2: { // custom 主体
                    id result = [[SensorsABTest sharedInstance] fetchCacheABTestWithParamName:@"cqs_os" defaultValue:@"默认试验值"];
                    NSLog(@"fetchCacheABTest，Subject Custom，paramName：%@ - result:%@\n", @"cqs_os", result);
                }
                    break;
                case 3: { // 自定义属性试验
                    SensorsABTestExperiment *experiment = [[SensorsABTestExperiment alloc] initWithParamName:@"cqs_device" defaultValue:@"设备默认值"];
                    experiment.properties = @{@"device": @"iPhone"};
                    [[SensorsABTest sharedInstance] fastFetchABTestWithExperiment:experiment completionHandler:^(id  _Nullable result) {

                        NSLog(@"fastFetchABTestWithExperiment，自定义属性 device 试验，paramName：%@ - result:%@\n", @"cqs_device", result);
                    }];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 4: { // other
            switch (row) { //
                case 0: { // flush
                    [[SensorsAnalyticsSDK sharedInstance] flush];
                }
                    break;

                case 1: { // go webView
                    WKWebViewController *webViewVC = [[WKWebViewController alloc] init];
                    [self.navigationController pushViewController:webViewVC animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 5: { // login、logout、identify 、resetAnonymousId
            switch (row) {
                case 0: { // login
                    [[SensorsAnalyticsSDK sharedInstance] login:@"login_test_20201217" withProperties:@{ @"name": @"batest_relod_login" }];
                }
                    break;
                    
                case 1: { // logout
                    [[SensorsAnalyticsSDK sharedInstance] logout];
                }
                    break;
                    
                case 2: { // identify
                    [[SensorsAnalyticsSDK sharedInstance] identify:@"abtest_relod_identify_1234567"];
                }
                    break;
                    
                case 3: { // resetAnonymousId
                    [[SensorsAnalyticsSDK sharedInstance] resetAnonymousId];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            // other
        case 6: {
            switch (row) {
                case 0: {
                    
                    dispatch_queue_t serialQueue1 = dispatch_queue_create([@"test1" UTF8String], DISPATCH_QUEUE_SERIAL);
                    dispatch_queue_t serialQueue2 = dispatch_queue_create([@"test2" UTF8String], DISPATCH_QUEUE_SERIAL);
                    dispatch_queue_t serialQueue3 = dispatch_queue_create([@"test3" UTF8String], DISPATCH_QUEUE_SERIAL);
                    
                    for (NSInteger index = 0; index < 1000; index ++) {
                        dispatch_async(serialQueue1, ^{
                            id result = [[SensorsABTest sharedInstance] fetchCacheABTestWithParamName:@"index_cqs" defaultValue:@(1111)];
                            NSLog(@"fetchCacheABTest1，paramName：%@ - result:%@\n", @"index_cqs", result);
                        });
                        
                        dispatch_async(serialQueue2, ^{
                            id result = [[SensorsABTest sharedInstance] fetchCacheABTestWithParamName:@"index_cqs" defaultValue:@(2222)];
                            NSLog(@"fetchCacheABTest2，paramName：%@ - result:%@\n", @"index_cqs", result);
                        });
                        
                        dispatch_async(serialQueue3, ^{
                            id result = [[SensorsABTest sharedInstance] fetchCacheABTestWithParamName:@"index_cqs" defaultValue:@(3333)];
                            NSLog(@"fetchCacheABTest3，paramName：%@ - result:%@\n", @"index_cqs", result);
                        });
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
        default:
            break;
    }
}

@end
