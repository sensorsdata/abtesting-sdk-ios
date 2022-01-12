//
// SABUtilsTests.m
// SensorsABTestTests
//
// Created by 储强盛 on 2020/10/9.
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
#import "SABURLUtils.h"
#import "SABFileStore.h"
#import "SABValidUtils.h"
#import "SABURLUtils.h"
#import "SABFileStore.h"
#import "NSString+SABHelper.h"

@interface SABUtilsTests : XCTestCase

@end

@implementation SABUtilsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark - SABAnalysisUtils
/// isValidString
- (void)testIsValidString {
    BOOL validValue = [SABValidUtils isValidString:@"fafsdvc"];
    XCTAssertTrue(validValue);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    BOOL inValid1 = [SABValidUtils isValidString:nil];
    XCTAssertFalse(inValid1);

    BOOL inValid2 = [SABValidUtils isValidString:@""];
    XCTAssertFalse(inValid2);

    BOOL inValid3 = [SABValidUtils isValidString:[NSNull null]];
    XCTAssertFalse(inValid3);

    BOOL inValid4 = [SABValidUtils isValidString:@(2343)];
    XCTAssertFalse(inValid4);
#pragma clang diagnostic pop
}


#pragma mark - SABURLUtils
- (void)testQueryItemsWithURLString {
    NSDictionary *queryDic = [SABURLUtils queryItemsWithURLString:@"sae8ff9352://abtest?sensors_abtest_url=http://abtesting.debugbox.sensorsdata.cn/api/v2/sa/abtest/experiments/distinct_id&feature_code=1602300608332:502723&account_id=2"];
    NSDictionary *queryResult = @{@"sensors_abtest_url": @"http://abtesting.debugbox.sensorsdata.cn/api/v2/sa/abtest/experiments/distinct_id", @"feature_code": @"1602300608332:502723", @"account_id": @"2"};
    XCTAssertEqualObjects(queryDic, queryResult);
}

- (void)testQueryItemsWithURL {
    NSDictionary *queryDic = [SABURLUtils queryItemsWithURL:[NSURL URLWithString:@"sae8ff9352://abtest?sensors_abtest_url=http://abtesting.debugbox.sensorsdata.cn/api/v2/sa/abtest/experiments/distinct_id&feature_code=1602300608332:502723&account_id=2"]];
    NSDictionary *queryResult = @{@"sensors_abtest_url": @"http://abtesting.debugbox.sensorsdata.cn/api/v2/sa/abtest/experiments/distinct_id", @"feature_code": @"1602300608332:502723", @"account_id": @"2"};
    XCTAssertEqualObjects(queryDic, queryResult);
}

- (void)testBaseURLWithURLString {
    NSURL *baseURL = [SABURLUtils baseURLWithURLString:@"http://abtesting-online.saas.debugbox.sensorsdata.cn/api/v2/abtest/online/results?project-key=test"];
    NSString *baseURLString = @"http://abtesting-online.saas.debugbox.sensorsdata.cn/api/v2/abtest/online/results";
    XCTAssertEqualObjects(baseURL.absoluteString, baseURLString);
}

#pragma mark - SABFileStore
- (void)testArchiveAndUnarchiveFile {
    // NSDictionary 读写
    NSString *dicFileName = @"SensorsABTestFileName-Test-Dictionary";
    NSDictionary *dic = @{ @"sensors_abtest_url": @"http://abtesting.debugbox.sensorsdata.cn/api/v2/sa/abtest/experiments/distinct_id", @"feature_code": @"1602300608332:502723", @"account_id": @"2" };
    [SABFileStore archiveWithFileName:dicFileName value:dic];
    NSDictionary *unarchiveDicResult = (NSDictionary *)[SABFileStore unarchiveWithFileName:dicFileName];
    XCTAssertEqualObjects(dic, unarchiveDicResult);

    // NSData 读写
    NSString *dataFileName = @"SensorsABTestFileName-Test-Data";
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    if (jsonData) {
        [SABFileStore archiveWithFileName:dataFileName value:jsonData];
        NSData *unarchiveDataResult = (NSData *)[SABFileStore unarchiveWithFileName:dataFileName];
        XCTAssertEqual(jsonData.hash, unarchiveDataResult.hash);
    }

    // NSString 读写
    NSString *stringFileName = @"SensorsABTestFileName-Test-String";
    NSString *string = @"zm,ncv,mcx/..,m'';'l;l;kkl;jjkhfa][[poiuuqtre1231253456467=5-90-877+__)(*&!@##$$%^&^&(M><?<?}{P:{PO\":L";
    [SABFileStore archiveWithFileName:stringFileName value:string];
    NSString *unarchiveStringResult = (NSString *)[SABFileStore unarchiveWithFileName:stringFileName];
    XCTAssertEqualObjects(string, unarchiveStringResult);

    // NSNumber 读写
    NSString *numbrerFileName = @"SensorsABTestFileName-Test-Number";
    NSNumber *numbrer = [NSNumber numberWithInteger:12314];
    [SABFileStore archiveWithFileName:numbrerFileName value:numbrer];
    NSNumber *unarchiveNumberResult = (NSNumber *)[SABFileStore unarchiveWithFileName:numbrerFileName];
    XCTAssertEqualObjects(numbrer, unarchiveNumberResult);

    // NSArray 读写
    NSString *arrayFileName = @"SensorsABTestFileName-Test-Array";
    NSArray *array = @[@"rwerwq", @(2312), @{ @"name": @"哈哈哈" }, [NSDate date]];
    [SABFileStore archiveWithFileName:arrayFileName value:array];
    NSArray *unarchiveArrayResult = (NSArray *)[SABFileStore unarchiveWithFileName:arrayFileName];
    XCTAssertEqualObjects(array, unarchiveArrayResult);
}

@end
