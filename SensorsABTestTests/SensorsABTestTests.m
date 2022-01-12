//
// SensorsABTestTests.m
// SensorsABTestTests
//
// Created by 储强盛 on 2020/8/20.
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

#import <XCTest/XCTest.h>
#import "SensorsABTest.h"

@interface SensorsABTestTests : XCTestCase
@property (nonatomic, weak) SensorsABTest *sensorsABTest;
@end

@implementation SensorsABTestTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    SensorsABTestConfigOptions *options = [[SensorsABTestConfigOptions alloc] initWithURL:@"http://abtesting-online.saas.debugbox.sensorsdata.cn/api/v2/abtest/online/results?project-key=123"];

    // 需要取消 判断 SensorsAnalyticsSDK 有效性断言
    [SensorsABTest startWithConfigOptions:options];

    self.sensorsABTest = [SensorsABTest sharedInstance];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.sensorsABTest = nil;
    XCTAssertNil(self.sensorsABTest, @"The [SensorsABTest sharedInstance] is nil");
}

#pragma mark - Initialize
/// 测试重复初始化，多次初始化仅第一次有效
- (void)testRepeatInitializeMethod {
    NSUInteger firstHash = self.sensorsABTest.hash;

    SensorsABTestConfigOptions *options = [[SensorsABTestConfigOptions alloc] initWithURL:@"http://abtesting-online.saas.debugbox.sensorsdata.cn/api/v2/abtest/online/results?project-key=123"];
    [SensorsABTest startWithConfigOptions:options];
    XCTAssertEqual(firstHash, [SensorsABTest sharedInstance].hash);
}

#pragma mark - public API
#pragma mark invalid paramName
/* 测试无效试验 Id 获取缓存试验，预期返回默认值 */

/// fetchCacheABTest
- (void)testFetchCacheABTestWithInvalidParamName {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"

    NSString *defaultValue = @"测试默认结果";
    NSObject *value1 =  [[SensorsABTest sharedInstance] fetchCacheABTestWithParamName:@(23435) defaultValue:defaultValue];
    XCTAssertEqual(value1.hash, defaultValue.hash);

    NSObject *value2 =  [[SensorsABTest sharedInstance] fetchCacheABTestWithParamName:nil defaultValue:defaultValue];
    XCTAssertEqual(value2.hash, defaultValue.hash);

    NSObject *value3 =  [[SensorsABTest sharedInstance] fetchCacheABTestWithParamName:[NSNull null] defaultValue:defaultValue];
    XCTAssertEqual(value3.hash, defaultValue.hash);

#pragma clang diagnostic pop
}
#pragma mark - handleOpenURL
- (void)testHandleOpenURL {
    BOOL validValue = [[SensorsABTest sharedInstance] handleOpenURL:[NSURL URLWithString:@"sa83746610://abtest?sensors_abtest_url=http://abtesting.debugbox.sensorsdata.cn/api/v2/sa/abtest/experiments/distinct_id&feature_code=re4sefr4&account_id=454254fsre"]];
    XCTAssertTrue(validValue);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"

    // 判空
    BOOL invalidValue1 = [[SensorsABTest sharedInstance] handleOpenURL:nil];
    XCTAssertFalse(invalidValue1);

    // 类型错误
    BOOL invalidValue2 = [[SensorsABTest sharedInstance] handleOpenURL:@"sa83746610://abtest?sensors_abtest_url=http://abtesting.debugbox.sensorsdata.cn/api/v2/sa/abtest/experiments/distinct_id&feature_code=re4sefr4&account_id=454254fsre"];
    XCTAssertFalse(invalidValue2);

    // host 错误
    BOOL invalidValue3 = [[SensorsABTest sharedInstance] handleOpenURL:[NSURL URLWithString:@"sa83746610://fsrfsd?sensors_abtest_url=http://abtesting.debugbox.sensorsdata.cn/api/v2/sa/abtest/experiments/distinct_id&feature_code=re4sefr4&account_id=454254fsre"]];
    XCTAssertFalse(invalidValue3);

#pragma clang diagnostic pop
}

@end
