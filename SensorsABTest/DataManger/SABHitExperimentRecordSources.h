//
// SABHitExperimentRecordSources.h
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


#import <Foundation/Foundation.h>
#import "SABFetchResultResponse.h"

NS_ASSUME_NONNULL_BEGIN


/**
 * @abstract
 * 命中试验匹配结果类型
 *
 * @discussion
 * 用于区分不同维度是匹配结果，试验 Id 相同，或试验组标识完全相同
 */
typedef NS_ENUM(NSInteger, SABExperimentMachResultType) {
    /// 匹配失败，即为不同试验
    SABExperimentMachResultTypeFailure = 0,
    /// 匹配试验 Id，即相同试验 Id，但是试验组不同
    SABExperimentMachResultTypeExperimentId = 1,
    /// 匹配试验结果 Id，即试验 Id、试验组、试验版本都相同
    SABExperimentMachResultTypeResultId = 2
};


/// 命中试验记录
@interface SABHitExperimentRecord : NSObject<NSCoding>

/// 试验 Id
@property (nonatomic, copy) NSString *experimentId;

/// 试验组 Id
@property (nonatomic, copy) NSString *experimentGroupId;

/// 试验唯一标识
///
/// 091 版本新增，老版 SaaS 分流结果无此字段，使用 试验组 Id 处理
@property (nonatomic, copy) NSString *experimentResultId;

/// 初始化试验记录
- (instancetype)initWithExperimentResult:(SABExperimentResult *)experimentResult;

/// 试验命中记录匹配结果
- (SABExperimentMachResultType)matchResultWithExperimentIdentifier:(SABHitExperimentRecord *)experimentRecord;

@end

/// 某个用户的所有命中试验记录
@interface SABHitExperimentRecordSources : NSObject<NSCoding>

/* 不同版本 SaaS 兼容
 老版 SaaS：distinctId、customIds
 新版 091 试验：subjectId、subjectName
 */
/// 当前命中记录的用户信息
@property (nonatomic, strong) SABUserIdenty *userIdenty;

#pragma mark 命中试验记录
/// 当前用户的所有命中试验记录
///
/// key 为试验 Id，value 为试验关键标识信息
@property (nonatomic, strong) NSMutableDictionary <NSString *, SABHitExperimentRecord *>*experimentRecords;

/// 初始化当前用户的试验记录
- (instancetype)initWithExperimentResult:(SABExperimentResult *)experimentResult;

/// 插入一条命中试验记录
- (void)insertHitExperimentRecord:(SABHitExperimentRecord *)experimentRecord;

@end

NS_ASSUME_NONNULL_END
