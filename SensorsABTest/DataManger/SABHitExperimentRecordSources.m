//
// SABHitExperimentRecordSources.m
// SensorsABTest
//
// Created by  储强盛 on 2022/12/12.
// Copyright © 2015-2022 Sensors Data Co., Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
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

#import "SABHitExperimentRecordSources.h"

@implementation SABHitExperimentRecord

- (instancetype)initWithExperimentResult:(SABExperimentResult *)experimentResult {
    self = [super init];
    if (self) {
        _experimentId = experimentResult.experimentId;
        _experimentGroupId = experimentResult.experimentGroupId;

        _experimentResultId = experimentResult.experimentResultId;
    }

    return self;
}

- (SABExperimentMachResultType)matchResultWithExperimentIdentifier:(SABHitExperimentRecord *)experimentRecord {
    if (!experimentRecord) {
        return SABExperimentMachResultTypeFailure;
    }

    if (experimentRecord == self) {
        return SABExperimentMachResultTypeResultId;
    }

    if (![self.experimentId isEqualToString:experimentRecord.experimentId]) {
        return SABExperimentMachResultTypeFailure;
    }

    // 新老版本 SaaS 兼容，老版 SaaS 不包含 resultId，则使用 groupId 匹配
    if (self.experimentResultId && experimentRecord.experimentResultId) {
        if ([self.experimentResultId isEqualToString:experimentRecord.experimentResultId]) {
            return SABExperimentMachResultTypeResultId;
        }

        // 如果 ResultId 有值，则只比较 ResultId，不论 groupId 结果如何
        return SABExperimentMachResultTypeExperimentId;
    }

    if ([self.experimentGroupId isEqualToString:experimentRecord.experimentGroupId]) {
        return SABExperimentMachResultTypeResultId;
    }

    return SABExperimentMachResultTypeExperimentId;
}


#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.experimentId forKey:@"experimentId"];
    [coder encodeObject:self.experimentGroupId forKey:@"experimentGroupId"];
    [coder encodeObject:self.experimentResultId forKey:@"experimentResultId"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.experimentId = [coder decodeObjectForKey:@"experimentId"];
        self.experimentGroupId = [coder decodeObjectForKey:@"experimentGroupId"];
        self.experimentResultId = [coder decodeObjectForKey:@"experimentResultId"];
    }
    return self;
}
@end



@implementation SABHitExperimentRecordSources

- (instancetype) init {
    self = [super init];
    if (self) {
        _experimentRecords = [NSMutableDictionary dictionary];
    }
    return self;
}

/* 新版 091 版本 SaaS 试验记录
 {
    "subject_id": "13k4jrfdsdnfdzft5e6345",  // 用户主体 Id
    "subject_name": "device",   // 用户主体名称
        // 命中试验记录的集合
    <abtest_experiment_id1>: {  // 命中试验 Id1
        "abtest_experiment_id": "334", // 试验 Id
        "abtest_experiment_group_id": "1", // 试验组 Id
        "abtest_experiment_result_id": "3340101"
    }
    <abtest_experiment_id2>: {  // 命中试验 Id2
        ...
    }
},

老版 SaaS 试验记录
 {
    "distinct_id": "13k4jrfdsdnfdzft5e6345",  // 当前用户唯一标识
    "anonymous_id": "xxxxxxxx",  // 当前用户的匿名 Id
    "custom_ids": "fravdxfgdfgrt" // 自定义主体 ID，如果支持并设置了，也需要判断
    <abtest_experiment_id1>: {  // 命中试验 Id1
        "abtest_experiment_id": "334", // 试验 Id
        "abtest_experiment_group_id": "1", // 试验组 Id
        "abtest_experiment_result_id": "3340101"
    },
    <abtest_experiment_id2>: {  // 命中试验 Id2
        ...
    },
 },
 */

- (instancetype)initWithExperimentResult:(SABExperimentResult *)experimentResult {
    self = [super init];
    if (self) {
        if (experimentResult.userIdenty.subjectId) {
            _userIdenty = [[SABUserIdenty alloc] initWithSubjectType:experimentResult.userIdenty.subjectType subjectId:experimentResult.userIdenty.subjectId];
        } else {
            _userIdenty = experimentResult.userIdenty;
        }

        _experimentRecords = [NSMutableDictionary dictionary];
        _experimentRecords[experimentResult.experimentId] = [[SABHitExperimentRecord alloc] initWithExperimentResult:experimentResult];
    }

    return self;
}

- (void)insertHitExperimentRecord:(SABHitExperimentRecord *)experimentRecord {
    if (!experimentRecord.experimentId) {
        return;
    }
    self.experimentRecords[experimentRecord.experimentId] = experimentRecord;
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userIdenty forKey:@"userIdenty"];
    [coder encodeObject:self.experimentRecords forKey:@"experimentRecords"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.userIdenty = [coder decodeObjectForKey:@"userIdenty"];
        self.experimentRecords = [coder decodeObjectForKey:@"experimentRecords"];
    }
    return self;
}


@end
