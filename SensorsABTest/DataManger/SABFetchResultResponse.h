//
// SABFetchResultResponse.h
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

#import <Foundation/Foundation.h>
#import "SABConstants.h"

/// 试验类型
typedef NS_ENUM(NSInteger, SABExperimentType) {
    /// 编程试验
    SABExperimentTypeCode = 0,
    /// 多链接试验，只支持 H5
    SABExperimentTypeLink = 1,
    /// 无效类型，此类型暂不支持
    SABExperimentTypeInvalid = -1
};

/**
 * @abstract
 * 试验结果类型
 *
 * @discussion
 * 试验结果类型枚举
 */
typedef NS_ENUM(NSInteger, SABExperimentResultType) {
    /// 类型无效，一般为 nil
    SABExperimentResultTypeInvalid = 0,
    /// INTEGER 类型结果
    SABExperimentResultTypeInt,
    /// STRING 类型结果
    SABExperimentResultTypeString,
    /// BOOLEAN 类型结果
    SABExperimentResultTypeBool,
    /// JSON 类型结果
    SABExperimentResultTypeJSON
};

/**
 * @abstract
 * 拉取试验结果状态
 *
 */
typedef NS_ENUM(NSInteger, SABFetchResultResponseStatus) {
    /// 拉取试验成功
    SABFetchResultResponseStatusSuccess,
    /// 拉取试验失败
    SABFetchResultResponseStatusFailed
};

/**
 * @abstract
 * 拉取试验分流的用户主体类型
 *
 * @discussion
 * 目前支持 用户主体、设备主体和自定义主体三种类型
 */
typedef NS_ENUM(NSInteger, SABUserSubjectType) {
    /// 用户主体，"subject_name" = USER;
    SABUserSubjectTypeUser = 0,
    /// 设备主体，"subject_name" = DEVICE
    SABUserSubjectTypeDevice,
    /// 自定义主体，"subject_name" = CUSTOM
    SABUserSubjectTypeCustom
};

/// 用户标识信息
@interface SABUserIdenty : NSObject <NSCoding, NSCopying>

#pragma mark 当前 App 用户信息
@property (nonatomic, copy) NSString *loginId;
@property (nonatomic, copy) NSString *anonymousId;

@property (nonatomic, copy) NSString *distinctId;

/// 自定义主体 ID
@property (nonatomic, copy) NSDictionary *customIDs;

#pragma mark 命中试验的用户信息

/// 用户主体名称（类型）
///
/// 用户主体，"subject_name" = USER；设备主体，"subject_name" = DEVICE；自定义主体，"subject_name" = CUSTOM
@property (nonatomic, assign) SABUserSubjectType subjectType;

/// 用户主体 Id（值）
@property (nonatomic, copy) NSString *subjectId;

- (instancetype)init NS_UNAVAILABLE;

/// 构建用户信息
- (instancetype)initWithDistinctId:(NSString *)distinctId loginId:(NSString *)loginId anonymousId:(NSString *)anonymousId;

/// 构建用户主体信息
- (instancetype)initWithSubjectType:(SABUserSubjectType)subjectType subjectId:(NSString *)subjectId;

/// 是否为相同用户
- (BOOL)isEqualUserIdenty:(SABUserIdenty *)userIdenty;

@end

/// 试验值
@interface SABExperimentResultVariable : NSObject<NSCopying, NSCoding>

/// 试验参数名
@property (nonatomic, copy) NSString *paramName;

/// 试验结果类型
@property (nonatomic, assign) SABExperimentResultType type;

/// 解析后的试验结果
@property (nonatomic) id value;
@end

/// 试验结果数据
@interface SABExperimentResult : NSObject<NSCopying, NSCoding>

/// 试验 Id
@property (nonatomic, copy) NSString *experimentId;

/// 试验组 Id
@property (nonatomic, copy) NSString *experimentGroupId;

/// 是否为对照组（SDK 暂未使用）
@property (nonatomic, assign, getter = isControlGroup) BOOL controlGroup;

/// 是否为白名单
@property (nonatomic, assign, getter = isWhiteList) BOOL whiteList;

/// 编程试验结果
///
/// 目前已按照 paramName 分组，所以试验结果，只有一个试验值
@property (nonatomic, strong) SABExperimentResultVariable *variable;

/// 试验类型
@property (nonatomic, copy) NSString *experimentType;

/// 用户标识
@property (nonatomic, strong) SABUserIdenty *userIdenty;

/// 试验结果 Id
///
/// 包含了试验 Id、试验组 Id、和实验组版本信息，唯一标识某个时刻的试验结果（试验组）
@property (nonatomic, copy) NSString *experimentResultId;

/// 扩展信息
///
/// 试验结果的扩展信息，方便后期扩展其他属性，用于 $ABTestTrigger 事件上报
@property (nonatomic, copy) NSDictionary * extendedInfo;

/// 试验结果和默认值是否相同类型
- (BOOL)isSameTypeWithDefaultValue:(id)defaultValue;

/// 解析默认值类型
+ (SABExperimentResultType)experimentResultTypeWithValue:(id)value;

/// 描述试验类型
+ (NSString *)descriptionWithExperimentResultType:(SABExperimentResultType)type;

@end

/// 网络回调完整数据结构
@interface SABFetchResultResponse : NSObject<NSCoding>

/// 获取试验状态
@property (nonatomic, assign) SABFetchResultResponseStatus status;

/// 错误类型，请求结果为 Failed 时返回
@property (nonatomic, copy) NSString *errorType;

/// 错误描述信息，请求结果为 Failed 时返回
@property (nonatomic, copy) NSString *errorMessage;

/// 分流试验结果
///
/// key: paramName 参数名，value: result 试验结果
@property (nonatomic, copy) NSDictionary <NSString *, SABExperimentResult *> *results;

/// 出组试验结果
///
/// key: paramName 参数名, value: 出组试验结果
@property (nonatomic, copy) NSDictionary <NSString *, SABExperimentResult *> *outResults;

/// 原始数据
@property (nonatomic, copy) NSDictionary *responseObject;

/// 用户标识信息，校验试验
@property (nonatomic, strong) SABUserIdenty *userIdenty;

/// 所有分流结果的 resultId 集合
@property (nonatomic, copy) NSArray <NSString *>*allResultIdOfResults;

- (instancetype)initWithDictionary:(NSDictionary *)responseDic;

@end
