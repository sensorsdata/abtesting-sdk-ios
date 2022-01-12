//
// SABFetchResultResponseTests.m
// SensorsABTestTests
//
// Created by 储强盛 on 2020/12/18.
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
#import "SABFetchResultResponse.h"
#import "SABJSONUtils.h"
#import "SABConstants.h"

@interface SABExperimentResultVariable()
// 试验结果类型解析
- (SABExperimentResultType)experimentResultTypeTransformWithString:(NSString *)typeString;

/// 试验结果解析
- (nullable id)analysisExperimentResultValueWithResultVariables:(NSString *)variables type:(SABExperimentResultType)type;
@end



/*
 1. 加载本地 json mock 试验结果
 2. 构造试验结果
 3. 重新缓存实现，直接返回构造的结果
 4. 模拟调用接口返回试验结果，验证结果正确性
 */

/// 试验结果解析单元测试
@interface SABFetchResultResponseTests : XCTestCase
/*
key: paramName 参数名
value: result 试验结果
 */
/// 试验结果
@property (atomic, copy) NSDictionary<NSString *, SABExperimentResult *> *experimentResults;

@end

@implementation SABFetchResultResponseTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    //文件路径
    NSString *jsonPath = [[NSBundle bundleForClass:self.class] pathForResource:@"ABTestTests_result.json" ofType:nil];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *resultDic = [SABJSONUtils JSONObjectWithData:jsonData];
    SABFetchResultResponse *resultResponse = [[SABFetchResultResponse alloc] initWithDictionary:resultDic];
    self.experimentResults = resultResponse.results;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.

    self.experimentResults = nil;
    XCTAssertNil(self.experimentResults, @"The self.manager is nil");
}

/// 通过 paramName 获取试验
- (void)testFetchABTestWithParamName {
    SABExperimentResult *result1 = self.experimentResults[@"color1"];
    XCTAssertEqualObjects(@(1), result1.variable.value);
    XCTAssertEqual(YES, result1.isControlGroup);

    SABExperimentResult *result2 = self.experimentResults[@"color2"];
    XCTAssertEqualObjects(@"sensorsdata_abtes", result2.variable.value);

    SABExperimentResult *result3 = self.experimentResults[@"color3"];
    XCTAssertEqualObjects(@(YES), result3.variable.value);

    SABExperimentResult *result4 = self.experimentResults[@"color4"];
    NSDictionary *color4Value = @{@"experiment_id": @"100", @"name": @"color4"};
    XCTAssertEqualObjects(color4Value, result4.variable.value);

    SABExperimentResult *result5 = self.experimentResults[@"enableclick"];
    XCTAssertEqualObjects(@(NO), result5.variable.value);

    SABExperimentResult *result6 = self.experimentResults[@"contentmessage"];
    NSDictionary *contentmessageValue = @{@"experiment_id": @"102", @"name": @"contentmessage"};
    XCTAssertEqualObjects(contentmessageValue, result6.variable.value);
    XCTAssertEqual(YES, result6.isControlGroup);
    XCTAssertEqual(YES, result6.isWhiteList);
}

/// 通过 experimentId 获取试验
- (void)testFetchABTestWithExperimentId {
    SABExperimentResult *result1 = self.experimentResults[@"101"];
    XCTAssertEqualObjects(@(1), result1.variable.value);
    XCTAssertEqual(NO, result1.isWhiteList);
    XCTAssertEqual(YES, result1.isControlGroup);

    SABExperimentResult *result2 = self.experimentResults[@"103"];
    XCTAssertEqualObjects(@(100), result2.variable.value);
    XCTAssertEqual(YES, result2.isWhiteList);
    XCTAssertEqual(NO, result2.isControlGroup);
}

/// 试验类型判断
- (void)testIsSameTypeExperimentResult {
    NSInteger integerValue = 1;
    BOOL boolValue = YES;
    NSString *stringValue = @"测试默认试验结果啊";
    NSDictionary *jsonValue = @{ @"name": @"测试默认试验结果啊", @"type": @"JSON" };

    SABExperimentResult *result1 = self.experimentResults[@"color1"];
    XCTAssertTrue([result1 isSameTypeWithDefaultValue:@(integerValue)]);

    SABExperimentResult *result2 = self.experimentResults[@"color2"];
    XCTAssertTrue([result2 isSameTypeWithDefaultValue:stringValue]);

    SABExperimentResult *result3 = self.experimentResults[@"color3"];
    XCTAssertTrue([result3 isSameTypeWithDefaultValue:@(boolValue)]);

    SABExperimentResult *result4 = self.experimentResults[@"color4"];
    XCTAssertTrue([result4 isSameTypeWithDefaultValue:jsonValue]);
}

/// 试验类型解析
- (void)testExperimentResultTypeTransformWithString {
    SABExperimentResult *result = self.experimentResults[@"color1"];
    XCTAssertEqual(SABExperimentResultTypeInt, [result.variable experimentResultTypeTransformWithString:@"INTEGER"]);

    XCTAssertEqual(SABExperimentResultTypeString, [result.variable experimentResultTypeTransformWithString:@"STRING"]);

    XCTAssertEqual(SABExperimentResultTypeBool, [result.variable experimentResultTypeTransformWithString:@"BOOLEAN"]);

    XCTAssertEqual(SABExperimentResultTypeJSON, [result.variable experimentResultTypeTransformWithString:@"JSON"]);

    XCTAssertEqual(SABExperimentResultTypeInvalid, [result.variable experimentResultTypeTransformWithString:@"vcwe5rtf45t"]);
}

/// 解析试验结果的试验值
- (void)testAnalysisExperimentResultValue {
    SABExperimentResult *result = self.experimentResults[@"color1"];
    NSObject *intValue = [result.variable analysisExperimentResultValueWithResultVariables:@"1" type:SABExperimentResultTypeInt];
    XCTAssertEqualObjects(intValue, @(1));

    NSObject *boolValue = [result.variable analysisExperimentResultValueWithResultVariables:@"true" type:SABExperimentResultTypeBool];
    XCTAssertEqualObjects(boolValue, @(YES));

    NSObject *stringValue = [result.variable analysisExperimentResultValueWithResultVariables:@"r54wtsrdgbvfdxb" type:SABExperimentResultTypeString];
    XCTAssertEqualObjects(stringValue, @"r54wtsrdgbvfdxb");

    NSString *jsonString = @"{\"experiment_id\":\"100\",\"name\":\"color4\"}";
    NSDictionary *jsonDic = [SABJSONUtils JSONObjectWithString:jsonString];
    NSObject *jsonValue = [result.variable analysisExperimentResultValueWithResultVariables:jsonString type:SABExperimentResultTypeJSON];
    XCTAssertEqualObjects(jsonDic, jsonValue);
}

/// 解析默认值的类型
- (void)testExperimentResultTypeTransformWithValue {
    XCTAssertEqual(SABExperimentResultTypeInt, [SABExperimentResult experimentResultTypeWithValue:@(1)]);

    XCTAssertEqual(SABExperimentResultTypeString, [SABExperimentResult experimentResultTypeWithValue:@"erqc"]);

    XCTAssertEqual(SABExperimentResultTypeBool, [SABExperimentResult experimentResultTypeWithValue:@(YES)]);

    XCTAssertEqual(SABExperimentResultTypeJSON, [SABExperimentResult experimentResultTypeWithValue:@{@"type":@"json"}]);
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
