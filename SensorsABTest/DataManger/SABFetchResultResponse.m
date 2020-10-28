//
//  SABFetchResultResponse.m
//  SensorsABTest
//
//  Created by 储强盛 on 2020/9/21.
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

#import "SABFetchResultResponse.h"
#import "SABJSONUtils.h"
#import "SABValidUtils.h"

static id dictionaryValueForKey(NSDictionary *dic, NSString *key) {
    if (![SABValidUtils isValidDictionary:dic]) {
        return nil;
    }

    id value = dic[key];
    return (value && ![value isKindOfClass:NSNull.class]) ? value : nil;
}

@implementation SABExperimentResultConfig

- (instancetype)initWithDictionary:(NSDictionary *)configDic {
    self = [super init];
    if (self) {
        if (![configDic isKindOfClass:NSDictionary.class]) {
            return nil;
        }
        NSString* variables = dictionaryValueForKey(configDic, @"variables");
        _type = [self experimentResultTypeTransformWithString:dictionaryValueForKey(configDic, @"type")];
        _value = [self analysisExperimentResultValueWithResultVariables:variables type:_type];
    }
    return self;
}

/// 试验结果类型解析
- (SABExperimentResultType)experimentResultTypeTransformWithString:(NSString *)typeString {
    if (![SABValidUtils isValidString:typeString]) {
        return SABExperimentResultTypeInvalid;
    }

    if ([typeString isEqualToString:@"INTEGER"]) {
        return SABExperimentResultTypeInt;
    } else if ([typeString isEqualToString:@"STRING"]) {
        return SABExperimentResultTypeString;
    } else if ([typeString isEqualToString:@"BOOLEAN"]) {
        return SABExperimentResultTypeBool;
    } else if ([typeString isEqualToString:@"JSON"]) {
        return SABExperimentResultTypeJSON;
    } else {
        return SABExperimentResultTypeInvalid;
    }
}

/// 解析试验结果的试验值
- (nullable id)analysisExperimentResultValueWithResultVariables:(NSString *)variables type:(SABExperimentResultType)type {
    if (!variables) {
        return nil;
    }
    switch (type) {
        case SABExperimentResultTypeInvalid:
            return nil;
        case SABExperimentResultTypeInt: {
            return @([variables integerValue]);
        }
        case SABExperimentResultTypeBool: {
            return @([variables boolValue]);
        }
        case SABExperimentResultTypeString:
            return variables;
        case SABExperimentResultTypeJSON: {
            return [SABJSONUtils JSONObjectWithString:variables];
        }
    }
    return nil;
}

#pragma mark NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    SABExperimentResultConfig *resultConfig = [[[self class] allocWithZone:zone] init];
    resultConfig.type = self.type;
    resultConfig.value = self.value;
    return resultConfig;
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.type forKey:@"type"];
    [coder encodeObject:self.value forKey:@"value"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.type = [coder decodeIntegerForKey:@"type"];
        self.value = [coder decodeObjectForKey:@"value"];
    }
    return self;
}

@end

@implementation SABExperimentResult

- (instancetype)initWithDictionary:(NSDictionary *)resultDic {
    self = [super init];
    if (self) {
        if (![resultDic isKindOfClass:NSDictionary.class]) {
            return nil;
        }
        /*
         "abtest_experiment_id": 666,
         "abtest_experiment_group_id": 888,
         "is_control_group": true,
         "is_white_list": false,
         "config": {
             "variables": "1",
             "type": "INTEGER"
         }

         */
        _experimentId = dictionaryValueForKey(resultDic, @"abtest_experiment_id");
        _experimentGroupId = dictionaryValueForKey(resultDic, @"abtest_experiment_group_id");
        _controlGroup = [dictionaryValueForKey(resultDic, @"is_control_group") boolValue];
        _whiteList = [dictionaryValueForKey(resultDic, @"is_white_list") boolValue];
        _config = [[SABExperimentResultConfig alloc] initWithDictionary:dictionaryValueForKey(resultDic, @"config")];
    }
    return self;
}

- (BOOL)isSameTypeWithDefaultValue:(id)defaultValue {
    if (!defaultValue) {
        return YES;
    }

    SABExperimentResultType defaultType = [self experimentResultTypeWithValue:defaultValue];
    return defaultType == self.config.type;
}

- (SABExperimentResultType)experimentResultTypeWithValue:(id)value {
    if (!value) {
        return SABExperimentResultTypeInvalid;
    }

    if ([value isKindOfClass:NSNumber.class]) {
        NSNumber *number = (NSNumber *)value;
        // OBJC_BOOL_IS_CHAR 是否定义，结果不同
        if (strcmp([number objCType], "c") == 0 || strcmp([number objCType], "B") == 0) {
            return SABExperimentResultTypeBool;
        } else {
            return SABExperimentResultTypeInt;
        }
    } else if ([value isKindOfClass:NSString.class]) {
        return SABExperimentResultTypeString;
    } else if ([value isKindOfClass:NSDictionary.class]) {
        return SABExperimentResultTypeJSON;
    } else {
        return SABExperimentResultTypeInvalid;
    }
}

#pragma mark NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    SABExperimentResult *resultData = [[[self class] allocWithZone:zone] init];
    resultData.experimentId = self.experimentId;
    resultData.experimentGroupId = self.experimentGroupId;
    resultData.controlGroup = self.controlGroup;
    resultData.whiteList = self.whiteList;
    resultData.config = self.config;
    return resultData;
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.experimentId forKey:@"experimentId"];
    [coder encodeObject:self.experimentGroupId forKey:@"experimentGroupId"];
    [coder encodeBool:self.controlGroup forKey:@"controlGroup"];
    [coder encodeBool:self.whiteList forKey:@"whiteList"];
    [coder encodeObject:self.config forKey:@"config"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.controlGroup = [coder decodeBoolForKey:@"controlGroup"];
        self.whiteList = [coder decodeBoolForKey:@"whiteList"];
        self.experimentId = [coder decodeObjectForKey:@"experimentId"];
        self.experimentGroupId = [coder decodeObjectForKey:@"experimentGroupId"];
        self.config = [coder decodeObjectForKey:@"config"];
    }
    return self;
}
@end

@implementation SABFetchResultResponse
- (instancetype)initWithDictionary:(NSDictionary *)responseDic {
    self = [super init];
    if (self) {
        if (![responseDic isKindOfClass:NSDictionary.class]) {
            return nil;
        }
        /*
         {
             "status": "SUCCESS", 查询结果标志（SUCCESS:进行试验；FAILED:不进入试验）
             "error_type": "",  错误类型，请求结果为 FAILED 时返回
             "error": "",  错误描述信息
             "results": [{   用户命中的所有试验结果
             }]
         }
         */
        if ([dictionaryValueForKey(responseDic, @"status") isEqualToString:@"SUCCESS"]) {
            _status = SABFetchResultResponseStatusSuccess;
        } else {
            _status = SABFetchResultResponseStatusFailed;
        }
        _errorType = dictionaryValueForKey(responseDic, @"error_type");
        _errorMessage = dictionaryValueForKey(responseDic, @"error");

        NSArray <NSDictionary *> *results = dictionaryValueForKey(responseDic, @"results");
        if (results.count > 0) {
            // 构造试验数据
            NSMutableDictionary <NSString *, SABExperimentResult *> *resultsDic = [NSMutableDictionary dictionaryWithCapacity:results.count];
            for (NSDictionary *resultDic in results) {
                SABExperimentResult *resultData = [[SABExperimentResult alloc] initWithDictionary:resultDic];
                resultsDic[resultData.experimentId] = resultData;
            }
            _results = [resultsDic copy];
        }

        _responseObject = [responseDic copy];
    }
    return self;
}

@end

