//
// SABFetchResultResponse.m
// SensorsABTest
//
// Created by 储强盛 on 2020/9/21.
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

#import "SABFetchResultResponse.h"
#import "SABJSONUtils.h"
#import "SABValidUtils.h"
#import "SABLogBridge.h"
#import "SABBridge.h"

static id dictionaryValueForKey(NSDictionary *dic, NSString *key) {
    if (![SABValidUtils isValidDictionary:dic]) {
        return nil;
    }

    id value = dic[key];
    return (value && ![value isKindOfClass:NSNull.class]) ? value : nil;
}

@implementation SABUserIdenty

- (instancetype)initWithDistinctId:(NSString *)distinctId loginId:(NSString *)loginId anonymousId:(NSString *)anonymousId {
    self = [super init];
    if (self) {
        _distinctId = distinctId;
        _loginId = loginId;
        _anonymousId = anonymousId;
    }
    return self;
}

/// 构建用户主体信息
- (instancetype)initWithSubjectType:(SABUserSubjectType)subjectType subjectId:(NSString *)subjectId {
    self = [super init];
    if (self) {
        _subjectType = subjectType;
        _subjectId = subjectId;
    }
    return self;
}

- (BOOL)isEqualUserIdenty:(SABUserIdenty *)userIdenty {
    if (self == userIdenty) {
        return YES;
    }
    if (!userIdenty) {
        return NO;
    }

    // 如果包含 subject 用户信息，优先匹配
    if (self.subjectId && userIdenty.subjectId) {
        if (self.subjectType == userIdenty.subjectType && [self.subjectId isEqualToString:userIdenty.subjectId]) {
            return YES;
        }
        return NO;
    }

    // 如果设置了 customIDs，也需要匹配 customIDs
    BOOL isSameCustomIDs = (self.customIDs.count == 0 && userIdenty.customIDs.count == 0) || [self.customIDs isEqualToDictionary:userIdenty.customIDs];
    // distinctId 和 anonymousId 都相同，才能确认为相同用户，防止影响设备主体试验分流
    if ([self.distinctId isEqualToString:userIdenty.distinctId] && [self.anonymousId isEqualToString:userIdenty.anonymousId] && isSameCustomIDs) {
        return YES;
    }
    return NO;
}

#pragma mark NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    SABUserIdenty *userIdenty = [[[self class] allocWithZone:zone] init];
    userIdenty.distinctId = self.distinctId;
    userIdenty.loginId = self.loginId;
    userIdenty.anonymousId = self.anonymousId;
    userIdenty.customIDs = self.customIDs;
    
    userIdenty.subjectType = self.subjectType;
    userIdenty.subjectId = self.subjectId;

    return userIdenty;
}


#pragma mark NSCoding
- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.distinctId forKey:@"distinctId"];
    [coder encodeObject:self.loginId forKey:@"loginId"];
    [coder encodeObject:self.anonymousId forKey:@"anonymousId"];
    [coder encodeObject:self.customIDs forKey:@"customIDs"];

    [coder encodeInteger:self.subjectType forKey:@"subjectType"];
    [coder encodeObject:self.subjectId forKey:@"subjectId"];

}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.distinctId = [coder decodeObjectForKey:@"distinctId"];
        self.loginId = [coder decodeObjectForKey:@"loginId"];
        self.anonymousId = [coder decodeObjectForKey:@"anonymousId"];
        self.customIDs = [coder decodeObjectForKey:@"customIDs"];

        self.subjectType = [coder decodeIntegerForKey:@"subjectType"];
        self.subjectId = [coder decodeObjectForKey:@"subjectId"];
    }
    return self;
}

@end

@implementation SABExperimentResultVariable

- (instancetype)initWithDictionary:(NSDictionary *)configDic {
    self = [super init];
    if (self) {
        if (![configDic isKindOfClass:NSDictionary.class]) {
            return nil;
        }
        NSString* valueString = dictionaryValueForKey(configDic, @"value");
        _type = [self experimentResultTypeTransformWithString:dictionaryValueForKey(configDic, @"type")];
        _value = [self analysisExperimentResultValueWithResultVariables:valueString type:_type];
        _paramName = dictionaryValueForKey(configDic, @"name");
    }
    return self;
}

/// 试验结果类型解析
- (SABExperimentResultType)experimentResultTypeTransformWithString:(NSString *)typeString {
    if (![SABValidUtils isValidString:typeString]) {
        SABLogWarn(@"experimentResult type error: %@" ,typeString);
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
        SABLogWarn(@"experimentResult type error: %@" ,typeString);
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
            id jsonValue = [SABJSONUtils JSONObjectWithString:variables];
            if (!jsonValue) { // 可能存在 jsonString 格式问题导致解析失败
                SABLogWarn(@"JSON type experiment failed to parse: %@", variables);
            }
            return jsonValue;
        }
    }
    return nil;
}

#pragma mark NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    SABExperimentResultVariable *resultConfig = [[[self class] allocWithZone:zone] init];
    resultConfig.type = self.type;
    resultConfig.value = self.value;
    resultConfig.paramName = self.paramName;
    return resultConfig;
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.type forKey:@"type"];
    [coder encodeObject:self.value forKey:@"value"];
    [coder encodeObject:self.paramName forKey:@"paramName"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.type = [coder decodeIntegerForKey:@"type"];
        self.value = [coder decodeObjectForKey:@"value"];
        self.paramName = [coder decodeObjectForKey:@"paramName"];
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
         "variables": [  // 编程试验包含参数，一个试验组可能包含多个试验参数
            {
                "name": "color1",
                "value": "1",       // 变量值
                "type": "INTEGER"    // 变量类型 INTEGER
            }
         ]
         */
        _experimentId = dictionaryValueForKey(resultDic, @"abtest_experiment_id");
        _experimentGroupId = dictionaryValueForKey(resultDic, @"abtest_experiment_group_id");
        _controlGroup = [dictionaryValueForKey(resultDic, @"is_control_group") boolValue];
        _whiteList = [dictionaryValueForKey(resultDic, @"is_white_list") boolValue];

        // SA 老版接口，没有 experiment_type 参数，只支持编程试验，设置默认类型
        // H5 支持的多链接试验和可视化试验，没有 variables 字段
        _experimentType = dictionaryValueForKey(resultDic, @"experiment_type");

        // 解析试验结果唯一标识
        _experimentResultId = dictionaryValueForKey(resultDic, @"abtest_experiment_result_id");
        // 扩展信息
        _extendedInfo = resultDic;
    }
    return self;
}

/// 保存当前试验的用户信息
- (void)setUserIdenty:(SABUserIdenty *)userIdenty {
    _userIdenty = userIdenty;

    NSString *subjectId = dictionaryValueForKey(self.extendedInfo, @"subject_id");
    if (![SABValidUtils isValidString:subjectId]) {
        return;
    }

    // 解析命中当前试验的用户主体
    _userIdenty.subjectId = subjectId;
    NSString *subjectName = dictionaryValueForKey(self.extendedInfo, @"subject_name");
    if ([subjectName isEqualToString:@"CUSTOM"]) {
        _userIdenty.subjectType = SABUserSubjectTypeCustom;
    } else if ([subjectName isEqualToString:@"DEVICE"]) {
        _userIdenty.subjectType = SABUserSubjectTypeDevice;
    } else { // 用户主体， USER
        _userIdenty.subjectType = SABUserSubjectTypeUser;
    }
}

- (BOOL)isSameTypeWithDefaultValue:(id)defaultValue {
    if (!defaultValue) {
        return YES;
    }

    SABExperimentResultType defaultType = [self.class experimentResultTypeWithValue:defaultValue];
    return defaultType == self.variable.type;
}

+ (SABExperimentResultType)experimentResultTypeWithValue:(id)value {
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

+ (NSString *)descriptionWithExperimentResultType:(SABExperimentResultType)type {
    switch (type) {
        case SABExperimentResultTypeInvalid:
            return @"Invalid";
        case SABExperimentResultTypeInt:
            return @"INTEGER";
        case SABExperimentResultTypeString:
            return @"STRING";
        case SABExperimentResultTypeBool:
            return @"BOOLEAN";
        case SABExperimentResultTypeJSON:
            return @"JSON";
        default:
            return @"Invalid";
    }
}

#pragma mark NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    SABExperimentResult *resultData = [[[self class] allocWithZone:zone] init];
    resultData.experimentId = self.experimentId;
    resultData.experimentGroupId = self.experimentGroupId;
    resultData.controlGroup = self.controlGroup;
    resultData.whiteList = self.whiteList;
    resultData.variable = self.variable;
    resultData.experimentType = self.experimentType;

    resultData.experimentResultId = self.experimentResultId;
    resultData.extendedInfo = self.extendedInfo;

    return resultData;
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.experimentId forKey:@"experimentId"];
    [coder encodeObject:self.experimentGroupId forKey:@"experimentGroupId"];
    [coder encodeBool:self.controlGroup forKey:@"controlGroup"];
    [coder encodeBool:self.whiteList forKey:@"whiteList"];
    [coder encodeObject:self.variable forKey:@"variable"];
    [coder encodeObject:self.experimentType forKey:@"experimentType"];

    [coder encodeObject:self.experimentResultId forKey:@"experimentResultId"];
    [coder encodeObject:self.extendedInfo forKey:@"extendedInfo"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.controlGroup = [coder decodeBoolForKey:@"controlGroup"];
        self.whiteList = [coder decodeBoolForKey:@"whiteList"];
        self.experimentId = [coder decodeObjectForKey:@"experimentId"];
        self.experimentGroupId = [coder decodeObjectForKey:@"experimentGroupId"];
        self.variable = [coder decodeObjectForKey:@"variable"];
        self.experimentType = [coder decodeObjectForKey:@"experimentType"];

        self.experimentResultId = [coder decodeObjectForKey:@"experimentResultId"];
        self.extendedInfo = [coder decodeObjectForKey:@"extendedInfo"];
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
        /* 老版 SaaS 环境
         {
         "status": "SUCCESS", 查询结果标志（SUCCESS:进行试验；FAILED:不进入试验）
         "error_type": "",  错误类型，请求结果为 FAILED 时返回
         "error": "",  错误描述信息
         "results": [ 用户命中的所有试验结果
                {
                     "abtest_experiment_id": "100", // 试验 ID
                     "abtest_experiment_group_id": "123", // 试验分组 ID
                     "is_control_group": false, // 是否是对照组
                     "is_white_list": true, // 是否白名单用户，白名单用户不进行试验事件的上报
                     "experiment_type": "CODE",  //试验类型 variables/link/...
                     "variables": [
                         {
                             "name": "color1", // 变量名
                             "value": "1", // 变量值
                             "type": "INTEGER" // 变量类型 INTEGER
                         }
                     ]
                 },{
                     "abtest_experiment_id": "100", // 试验 ID
                     "abtest_experiment_group_id": "123", // 试验分组 ID
                     "is_control_group": false, // 是否是对照组
                     "is_white_list": true, // 是否白名单用户，白名单用户不进行试验事件的上报
                     "experiment_type": "LINK",  //试验类型 variables/link/...
                     "control_link": "http://aa.com",    //分流 URL 、对照组链接
                     "link_match_type": "STRICT",    //链接匹配类型 STRICT：精确匹配，FUZZY:模糊匹配
                     "experiment_link": "http://aa.com/1"    //用户命中的试验链接（试验组就是试验组url、对照组就是对照组链接）
                }
            ],
         "fuzzy_experiments": [
                 "TeamEntranceType",
                 "goodImageConfig"
             ]
         }
         */

        /* 新版 091 SaaS 返回结果
         {
             "status": "SUCCESS",
             "results":
             [
                 {
                     "abtest_experiment_id": "1011",
                     "abtest_experiment_group_id": "3",
                     "is_control_group": false,
                     "is_white_list": false,
                     "experiment_type": "CODE",
                     "variables":
                     [
                         {
                             "name": "cqs_os",
                             "type": "STRING",
                             "value": "windows"
                         }
                     ],
                     "abtest_unique_id": "10110103",
                     "subject_id": "iOS自定义主体Id",
                     "subject_name": "CUSTOM",
                     "abtest_version": "1",
                     "stickiness": "STICKINESS"
                 },
                 {
                     "abtest_experiment_id": "1012",
                     "abtest_experiment_group_id": "1",
                     "is_control_group": false,
                     "is_white_list": true,
                     "experiment_type": "CODE",
                     "variables":
                     [
                         {
                             "name": "cqs_color",
                             "type": "STRING",
                             "value": "red"
                         },
                         {
                             "name": "cqs_index",
                             "type": "INTEGER",
                             "value": "1"
                         }
                     ],
                     "abtest_unique_id": "10120101",
                     "subject_id": "AAC58A96-445E-4D12-8028-EC518988AAF2",
                     "subject_name": "DEVICE",
                     "abtest_version": "1",
                     "stickiness": "STICKINESS"
                 },
                 {
                     "abtest_experiment_id": "1007",
                     "abtest_experiment_group_id": "0",
                     "is_control_group": true,
                     "is_white_list": false,
                     "experiment_type": "CODE",
                     "variables":
                     [
                         {
                             "name": "li",
                             "type": "INTEGER",
                             "value": "1"
                         }
                     ],
                     "abtest_unique_id": "10060114",
                     "subject_id": "AAC58A96-445E-4D12-8028-EC518988AAF2",
                     "subject_name": "USER",
                     "abtest_version": "1",
                     "stickiness": "STICKINESS"
                 }
             ],
             "track_config":  // 新增事件触发配置，用于控制事件触发逻辑，默认不返回，修改后全量返回
             {
                 "item_switch": false,
                 "trigger_switch": true,
                 "property_set_switch": false,
                 "trigger_content_ext":
                 [
                     "abtest_experiment_version",
                     "abtest_experiment_result_id"
                 ]
             },
             "out_results":  // 新增出组记录列表，只返回关键的试验信息，用于上报出组
             [
                 {
                     "abtest_experiment_id": "335",
                     "abtest_experiment_group_id": "0",
                     "abtest_experiment_result_id": "-1",
                     "subject_id": "AAC58A96-445E-4D12-8028-EC518988AAADSD",
                     "subject_name": "USER",
                     "abtest_version": "1",
                     "variables":
                     [
                         {
                             "name": "ai"
                         }
                     ]
                 }
             ]
         }
         */
        if ([dictionaryValueForKey(responseDic, @"status") isEqualToString:@"SUCCESS"]) {
            _status = SABFetchResultResponseStatusSuccess;
        } else {
            _status = SABFetchResultResponseStatusFailed;
        }
        _errorType = dictionaryValueForKey(responseDic, @"error_type");
        _errorMessage = dictionaryValueForKey(responseDic, @"error");

        // 进组结果解析
        NSArray <NSDictionary *> *results = dictionaryValueForKey(responseDic, @"results");
        if (results.count > 0) {
            // 构建分流试验结果
            _results = [self buildExperimentResultsWithArray:results isResults:YES];
        } else {
            // 请求成功，无分流结果
            _allResultIdOfResults = @[];
        }

        // 出组分流结果解析
        NSArray <NSDictionary *> *outListArray = dictionaryValueForKey(responseDic, @"out_list");
        if (outListArray.count > 0) {
            // 构建出组试验结果
            _outResults = [self buildExperimentResultsWithArray:outListArray isResults:NO];
        }
        
        _responseObject = [responseDic copy];
    }
    return self;
}


/// 构建试验结果集合
/// @param results 试验结果集合 json
/// @param isResults 是否进组结果
- (NSDictionary <NSString *, SABExperimentResult *> *) buildExperimentResultsWithArray:(NSArray <NSDictionary *> *)results isResults:(BOOL)isResults {
    // 构造试验数据
    NSMutableDictionary <NSString *, SABExperimentResult *> *resultsDic = [NSMutableDictionary dictionary];
    NSMutableSet <NSString *>*allResultIdOfResults = [NSMutableSet set];

    // 遍历所有试验
    for (NSDictionary *resultDic in results) {
        SABExperimentResult *result = [[SABExperimentResult alloc] initWithDictionary:resultDic];

        if (isResults && result.experimentResultId) {
            // 构建所有分流结果 result_id 记录
            [allResultIdOfResults addObject:result.experimentResultId];
        }

        NSArray <NSDictionary *> *variables = dictionaryValueForKey(resultDic, @"variables");
        // 没有试验结果，Native 不作处理
        if (variables.count == 0) {
            continue;
        }
        // 遍历每个试验下所有试验参数
        for (NSDictionary *variableDic in variables) {
            SABExperimentResultVariable *variable = [[SABExperimentResultVariable alloc] initWithDictionary:variableDic];
            // 后端已按照更新时间做排序，相同 paramName 只取第一个即为最新试验
            if (!variable.paramName || resultsDic[variable.paramName]) {
                continue;
            }
            SABExperimentResult *newResult = [result copy];
            newResult.variable = variable;
            resultsDic[variable.paramName] = newResult;
        }
    }

    if (isResults) {
        _allResultIdOfResults = [allResultIdOfResults allObjects];
    }

    return [resultsDic copy];
}


#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.status forKey:@"status"];
    [coder encodeObject:self.errorType forKey:@"errorType"];
    [coder encodeObject:self.errorMessage forKey:@"errorMessage"];
    [coder encodeObject:self.results forKey:@"results"];
    [coder encodeObject:self.responseObject forKey:@"responseObject"];
    [coder encodeObject:self.userIdenty forKey:@"userIdenty"];

    [coder encodeObject:self.outResults forKey:@"outResults"];
    [coder encodeObject:self.allResultIdOfResults forKey:@"allResultIdOfResults"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.status = [coder decodeIntegerForKey:@"status"];
        self.errorType = [coder decodeObjectForKey:@"errorType"];
        self.errorMessage = [coder decodeObjectForKey:@"errorMessage"];
        self.results = [coder decodeObjectForKey:@"results"];
        self.responseObject = [coder decodeObjectForKey:@"responseObject"];
        // 调用 set 方法，设置每个试验 userIdenty
        self.userIdenty = [coder decodeObjectForKey:@"userIdenty"];

        self.outResults = [coder decodeObjectForKey:@"outResults"];
        self.allResultIdOfResults = [coder decodeObjectForKey:@"allResultIdOfResults"];
    }
    return self;
}

- (void)setUserIdenty:(SABUserIdenty *)userIdenty {
    _userIdenty = userIdenty;
    // 每个试验结果，设置 userIdenty，用于 track 事件
    for (SABExperimentResult *result in self.results.allValues) {
        result.userIdenty = [userIdenty copy];
    }

    for (SABExperimentResult *result in self.outResults.allValues) {
        result.userIdenty = [userIdenty copy];
    }
}
@end

