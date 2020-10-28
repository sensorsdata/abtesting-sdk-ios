//
//  SABExperimentResultTest.m
//  SensorsABTestTests
//
//  Created by 储强盛 on 2020/10/12.
//  Copyright © 2020 Sensors Data Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import <XCTest/XCTest.h>
#import "SABFetchResultResponse.h"
#import "SABConstants.h"

@interface SABExperimentResultConfig()
/// 初始化
- (instancetype)initWithDictionary:(NSDictionary *)configDic;
// 试验结果类型解析
- (SABExperimentResultType)experimentResultTypeTransformWithString:(NSString *)typeString;

/// 试验结果解析
- (nullable id)analysisExperimentResultValueWithResultVariables:(NSString *)variables type:(SABExperimentResultType)type;
@end


@interface SABExperimentResult()
/// 初始化
- (instancetype)initWithDictionary:(NSDictionary *)resultDic;

/// 解析一个值的试验类型
- (SABExperimentResultType)experimentResultTypeWithValue:(id)value;
@end

/// 数据模型校验测试
@interface SABExperimentResultTest : XCTestCase
@property (nonatomic, strong) SABExperimentResult *resultData;
@end

@implementation SABExperimentResultTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    NSDictionary *resultDic = @{@"abtest_experiment_id": @(666),
                                @"abtest_experiment_group_id": @(888),
                                @"is_control_group": @(YES),
                                @"is_white_list": @(NO),
                                @"config":@{
                                        @"variables": @"1",
                                        @"type": @"INTEGER"
                                }
    };
    self.resultData = [[SABExperimentResult alloc] initWithDictionary:resultDic];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.resultData = nil;
}

/// isSameTypeExperimentResult
- (void)testIsSameTypeExperimentResult {
    NSInteger integerValue = 1;
    BOOL boolValue = YES;
    NSString *stringValue = @"测试默认试验结果啊";
    NSDictionary *jsonValue = @{ @"name": @"测试默认试验结果啊", @"type": @"JSON" };

    BOOL sameType = [self.resultData isSameTypeWithDefaultValue:@(integerValue)];
    XCTAssertTrue(sameType);

    BOOL differentType1 = [self.resultData isSameTypeWithDefaultValue:@(boolValue)];
    XCTAssertFalse(differentType1);

    BOOL differentType2 = [self.resultData isSameTypeWithDefaultValue:stringValue];
    XCTAssertFalse(differentType2);

    BOOL differentType3 = [self.resultData isSameTypeWithDefaultValue:jsonValue];
    XCTAssertFalse(differentType3);
}

/// experimentResultTypeTransformWithString
- (void)testExperimentResultTypeTransformWithString {
    XCTAssertEqual(SABExperimentResultTypeInt, [self.resultData.config experimentResultTypeTransformWithString:@"INTEGER"]);

    XCTAssertEqual(SABExperimentResultTypeString, [self.resultData.config experimentResultTypeTransformWithString:@"STRING"]);

    XCTAssertEqual(SABExperimentResultTypeBool, [self.resultData.config experimentResultTypeTransformWithString:@"BOOLEAN"]);

    XCTAssertEqual(SABExperimentResultTypeJSON, [self.resultData.config experimentResultTypeTransformWithString:@"JSON"]);

    XCTAssertEqual(SABExperimentResultTypeInvalid, [self.resultData.config experimentResultTypeTransformWithString:@"vcwe5rtf45t"]);
}

/// analysisExperimentResultValueWithResultVariables
- (void)testAnalysisExperimentResultValue {
    NSObject *intValue = [self.resultData.config analysisExperimentResultValueWithResultVariables:@"1" type:SABExperimentResultTypeInt];
    XCTAssertEqualObjects(intValue, @(1));

    NSObject *boolValue = [self.resultData.config analysisExperimentResultValueWithResultVariables:@"true" type:SABExperimentResultTypeBool];
    XCTAssertEqualObjects(boolValue, @(YES));

    NSObject *stringValue = [self.resultData.config analysisExperimentResultValueWithResultVariables:@"r54wtsrdgbvfdxb" type:SABExperimentResultTypeString];
    XCTAssertEqualObjects(stringValue, @"r54wtsrdgbvfdxb");

    NSDictionary *resultDic = @{@"abtest_experiment_id": @(666),
                                @"abtest_experiment_group_id": @(888),
                                @"is_control_group": @(YES),
                                @"is_white_list": @(NO),
                                @"config":@{
                                        @"variables": @"1",
                                        @"type": @"INTEGER"
                                }

    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:0 error:nil];
    if (jsonData) {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSObject *jsonValue = [self.resultData.config analysisExperimentResultValueWithResultVariables:jsonString type:SABExperimentResultTypeJSON];
        XCTAssertEqualObjects(resultDic, jsonValue);
    }
}

/// experimentResultTypeTransformWithValue
- (void)testExperimentResultTypeTransformWithValue {
    XCTAssertEqual(SABExperimentResultTypeInt, [self.resultData experimentResultTypeWithValue:@(1)]);

    XCTAssertEqual(SABExperimentResultTypeString, [self.resultData experimentResultTypeWithValue:@"erqc"]);

    XCTAssertEqual(SABExperimentResultTypeBool, [self.resultData experimentResultTypeWithValue:@(YES)]);

    XCTAssertEqual(SABExperimentResultTypeJSON, [self.resultData experimentResultTypeWithValue:@{@"type":@"json"}]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
