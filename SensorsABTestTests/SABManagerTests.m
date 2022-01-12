//
// SABManagerTests.m
// SensorsABTestTests
//
// Created by 储强盛 on 2020/10/12.
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
#import "SABManager.h"
#import "SensorsABTestConfigOptions.h"

/// SABManager 测试
@interface SABManagerTests : XCTestCase
@property (nonatomic, strong) SABManager *manager;
@end

@implementation SABManagerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    SensorsABTestConfigOptions *abtestConfigOptions = [[SensorsABTestConfigOptions alloc] initWithURL:@"http://abtesting-online.saas.debugbox.sensorsdata.cn/api/v2/abtest/online/results?project-key=test"];
    self.manager = [[SABManager alloc] initWithConfigOptions:abtestConfigOptions];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.

    self.manager = nil;
    XCTAssertNil(self.manager, @"The self.manager is nil");
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
    __block NSObject *value1 = nil;
    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeCache paramName:@(23435) defaultValue:defaultValue timeoutInterval:30 completionHandler:^(id _Nullable result) {
        value1 = result;
    }];
    XCTAssertEqual(value1.hash, defaultValue.hash);

    __block NSObject *value2 = nil;
    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeCache paramName:nil defaultValue:defaultValue timeoutInterval:30 completionHandler:^(id _Nullable result) {
        value2 = result;
    }];
    XCTAssertEqual(value2.hash, defaultValue.hash);

    __block NSObject *value3 = nil;
    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeCache paramName:[NSNull null] defaultValue:defaultValue timeoutInterval:30 completionHandler:^(id _Nullable result) {
        value3 = result;
    }];
    XCTAssertEqual(value2.hash, defaultValue.hash);

#pragma clang diagnostic pop
}

/// asyncFetchABTest
- (void)testAsyncFetchABTestWithInvalidParamName {
    XCTestExpectation *expect1 = [self expectationWithDescription:@"异步操作 1 超时 timeout！"];
    XCTestExpectation *expect2 = [self expectationWithDescription:@"异步操作 2 超时 timeout！"];
    XCTestExpectation *expect3 = [self expectationWithDescription:@"异步操作 3 超时 timeout！"];
    NSString *defaultValue = @"测试默认结果";

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeAsync paramName:@(23435) defaultValue:defaultValue timeoutInterval:30 completionHandler:^(id _Nullable result) {
        NSObject *resultValue = result;
        XCTAssertEqual(resultValue.hash, defaultValue.hash);
        [expect1 fulfill];
    }];

    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeAsync paramName:nil defaultValue:defaultValue timeoutInterval:30 completionHandler:^(id _Nullable result) {
        NSObject *resultValue = result;
        XCTAssertEqual(resultValue.hash, defaultValue.hash);
        [expect2 fulfill];
    }];

    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeAsync paramName:[NSNull null] defaultValue:defaultValue timeoutInterval:30 completionHandler:^(id _Nullable result) {
        NSObject *resultValue = result;
        XCTAssertEqual(resultValue.hash, defaultValue.hash);
        [expect3 fulfill];
    }];

#pragma clang diagnostic pop
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

/// fastFetchABTest
- (void)testFastFetchABTestWithInvalidParamName {
    XCTestExpectation *expect1 = [self expectationWithDescription:@"异步操作 1 超时 timeout！"];
    XCTestExpectation *expect2 = [self expectationWithDescription:@"异步操作 2 超时 timeout！"];
    XCTestExpectation *expect3 = [self expectationWithDescription:@"异步操作 3 超时 timeout！"];
    NSString *defaultValue = @"测试默认结果";

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeFast paramName:@(23435) defaultValue:defaultValue timeoutInterval:30 completionHandler:^(id _Nullable result) {
        NSObject *resultValue = result;
        XCTAssertEqual(resultValue.hash, defaultValue.hash);
        [expect1 fulfill];
    }];

    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeFast paramName:nil defaultValue:defaultValue timeoutInterval:30 completionHandler:^(id _Nullable result) {
        NSObject *resultValue = result;
        XCTAssertEqual(resultValue.hash, defaultValue.hash);
        [expect2 fulfill];
    }];

    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeFast paramName:[NSNull null] defaultValue:defaultValue timeoutInterval:30 completionHandler:^(id _Nullable result) {
        NSObject *resultValue = result;
        XCTAssertEqual(resultValue.hash, defaultValue.hash);
        [expect3 fulfill];
    }];
#pragma clang diagnostic pop

    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}


#pragma mark multiple defaultValue
/// fetchCacheABTest
- (void)testDefaultValueWithFetchCacheABTest {
    NSInteger integerValue = 1;
    BOOL boolValue = YES;
    NSString *stringValue = @"测试默认试验结果啊";
    NSDictionary *jsonValue = @{@"name":@"测试默认试验结果啊", @"type":@"JSON"};

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

    __block NSObject *value1 =  nil;
    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeCache paramName:nil defaultValue:@(integerValue) timeoutInterval:30 completionHandler:^(id _Nullable result) {
        value1 = result;
    }];
    XCTAssertEqual(value1.hash, @(integerValue).hash);


    __block NSObject *value2 =  nil;
    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeCache paramName:nil defaultValue:@(boolValue) timeoutInterval:30 completionHandler:^(id _Nullable result) {
        value2 = result;
    }];
    XCTAssertEqual(value2.hash, @(boolValue).hash);

    __block NSObject *value3 =  nil;
    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeCache paramName:nil defaultValue:stringValue timeoutInterval:30 completionHandler:^(id _Nullable result) {
        value3 = result;
    }];
    XCTAssertEqual(value3.hash, stringValue.hash);

    __block NSObject *value4 =  nil;
    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeCache paramName:nil defaultValue:jsonValue timeoutInterval:30 completionHandler:^(id _Nullable result) {
        value4 = result;
    }];
    XCTAssertEqual(value4.hash, jsonValue.hash);

#pragma clang diagnostic pop
}

/// fastFetchABTest
- (void)testDefaultValueWithFastFetchABTest {
    XCTestExpectation *expect1 = [self expectationWithDescription:@"异步操作 1 超时 timeout！"];
    XCTestExpectation *expect2 = [self expectationWithDescription:@"异步操作 2 超时 timeout！"];
    XCTestExpectation *expect3 = [self expectationWithDescription:@"异步操作 3 超时 timeout！"];
    XCTestExpectation *expect4 = [self expectationWithDescription:@"异步操作 4 超时 timeout！"];

    NSInteger integerValue = 1;
    BOOL boolValue = YES;
    NSString *stringValue = @"测试默认试验结果啊";
    NSDictionary *jsonValue = @{@"name":@"测试默认试验结果啊", @"type":@"JSON"};

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeFast paramName:nil defaultValue:@(integerValue) timeoutInterval:30 completionHandler:^(id _Nullable result) {
        NSObject *resultValue = result;
        XCTAssertEqual(resultValue.hash, @(integerValue).hash);
        [expect1 fulfill];
    }];

    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeFast paramName:nil defaultValue:@(boolValue) timeoutInterval:30 completionHandler:^(id _Nullable result) {
        NSObject *resultValue = result;
        XCTAssertEqual(resultValue.hash, @(boolValue).hash);
        [expect2 fulfill];
    }];

    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeFast paramName:nil defaultValue:stringValue timeoutInterval:30 completionHandler:^(id _Nullable result) {
        NSObject *resultValue = result;
        XCTAssertEqual(resultValue.hash, stringValue.hash);
        [expect3 fulfill];
    }];

    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeFast paramName:nil defaultValue:jsonValue timeoutInterval:30 completionHandler:^(id _Nullable result) {
        NSObject *resultValue = result;
        XCTAssertEqual(resultValue.hash, jsonValue.hash);
        [expect4 fulfill];
    }];
#pragma clang diagnostic pop

    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

/// asyncFetchABTest
- (void)testDefaultValueWithAsyncFetchABTest {
    XCTestExpectation *expect1 = [self expectationWithDescription:@"异步操作 1 超时 timeout！"];
    XCTestExpectation *expect2 = [self expectationWithDescription:@"异步操作 2 超时 timeout！"];
    XCTestExpectation *expect3 = [self expectationWithDescription:@"异步操作 3 超时 timeout！"];
    XCTestExpectation *expect4 = [self expectationWithDescription:@"异步操作 4 超时 timeout！"];

    NSInteger integerValue = 1;
    BOOL boolValue = YES;
    NSString *stringValue = @"测试默认试验结果啊";
    NSDictionary *jsonValue = @{@"name":@"测试默认试验结果啊", @"type":@"JSON"};

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeAsync paramName:nil defaultValue:@(integerValue) timeoutInterval:30 completionHandler:^(id _Nullable result) {
        NSObject *resultValue = result;
        XCTAssertEqual(resultValue.hash, @(integerValue).hash);
        [expect1 fulfill];
    }];

    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeAsync paramName:nil defaultValue:@(boolValue) timeoutInterval:30 completionHandler:^(id _Nullable result) {
        NSObject *resultValue = result;
        XCTAssertEqual(resultValue.hash, @(boolValue).hash);
        [expect2 fulfill];
    }];

    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeAsync paramName:nil defaultValue:stringValue timeoutInterval:30 completionHandler:^(id _Nullable result) {
        NSObject *resultValue = result;
        XCTAssertEqual(resultValue.hash, stringValue.hash);
        [expect3 fulfill];
    }];

    [self.manager fetchABTestWithModeType:SABFetchABTestModeTypeAsync paramName:nil defaultValue:jsonValue timeoutInterval:30 completionHandler:^(id _Nullable result) {
        NSObject *resultValue = result;
        XCTAssertEqual(resultValue.hash, jsonValue.hash);
        [expect4 fulfill];
    }];
#pragma clang diagnostic pop

    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
