//
//  SABFetchResultResponse.h
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

#import <Foundation/Foundation.h>
#import "SABConstants.h"

/**
 * @abstract
 * 试验结果类型
 *
 * @discussion
 * 试验结果类型枚举
 *   SABExperimentResultTypeInvalid 类型无效
 *   SABExperimentResultTypeInt - INTEGER 类型结果
 *   SABExperimentResultTypeString - STRING 类型结果
 *   SABExperimentResultTypeBool - BOOLEAN 类型结果
 *   SABExperimentResultTypeJSON - JSON 类型结果
 */
typedef NS_OPTIONS(NSInteger, SABExperimentResultType) {
    SABExperimentResultTypeInvalid,
    SABExperimentResultTypeInt,
    SABExperimentResultTypeString,
    SABExperimentResultTypeBool,
    SABExperimentResultTypeJSON
};

/**
 * @abstract
 * 拉取试验结果状态
 *
 * @discussion
 * 拉取试验结果类型
 *   SABFetchResultResponseStatusSuccess - 拉取试验成功
 *   SABFetchResultResponseStatusFailed - 拉取试验失败
 */
typedef NS_OPTIONS(NSInteger, SABFetchResultResponseStatus) {
    SABFetchResultResponseStatusSuccess,
    SABFetchResultResponseStatusFailed
};

/// 试验值
@interface SABExperimentResultConfig : NSObject<NSCopying, NSCoding>

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

/// 是否为对照组
@property (nonatomic, assign, getter = isControlGroup) BOOL controlGroup;

/// 是否为白名单
@property (nonatomic, assign, getter = isWhiteList) BOOL whiteList;

/// 试验结果配置模型
@property (nonatomic, strong) SABExperimentResultConfig *config;

/// 试验结果和默认值是否相同类型
- (BOOL)isSameTypeWithDefaultValue:(id)defaultValue;

@end

/// 网络回调完整数据结构
@interface SABFetchResultResponse : NSObject

/// 获取试验状态
@property (nonatomic, assign) SABFetchResultResponseStatus status;

/// 错误类型，请求结果为 Failed 时返回
@property (nonatomic, copy) NSString *errorType;

/// 错误描述信息，请求结果为 Failed 时返回
@property (nonatomic, copy) NSString *errorMessage;

/// 试验结果
@property (nonatomic, copy) NSDictionary <NSString *, SABExperimentResult *> *results;

/// 原始数据
@property (nonatomic, copy) NSDictionary *responseObject;

- (instancetype)initWithDictionary:(NSDictionary *)responseDic;

@end
