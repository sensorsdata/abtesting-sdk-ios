//
// SABExperimentDataManager.h
// SensorsABTest
//
// Created by 储强盛 on 2020/10/11.
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
#import "SABFetchResultResponse.h"
#import "SABRequest.h"
#import "SABTestTrackConfig.h"

/// App 原生分流请求回调
typedef void(^SABFetchResultResponseCompletionHandler)(SABFetchResultResponse *_Nullable responseData, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

/// 数据存储和解析
@interface SABExperimentDataManager : NSObject

/// 指定初始化接口
/// @param serialQueue 串行队列
- (instancetype)initWithSerialQueue:(dispatch_queue_t)serialQueue NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/// 请求白名单，只在发送请求成功后更新，只有白名单内的试验参数名，才可能需要重新拉取试验配置
@property (atomic, strong, readonly) NSArray <NSString *> *fuzzyExperiments;

/// $ABTestTrigger 事件配置
@property (atomic, strong, readonly) SABTestTrackConfig *trackConfig;

/// 当前用户信息
@property (atomic, strong, readonly) SABUserIdenty *currentUserIndenty;

/// 获取缓存试验结果
- (nullable SABExperimentResult *)cachedExperimentResultWithParamName:(NSString *)paramName;

/// 异步请求所有试验
- (void)asyncFetchAllExperimentWithRequest:(SABExperimentRequest *)requestData completionHandler:(SABFetchResultResponseCompletionHandler)completionHandler;

/// 切换用户，清空分流结果缓存
- (void)clearExperimentResults;

/// 更新自定义主体
- (void)updateCustomIDs:(NSDictionary <NSString*, NSString*>*)customIDs;

/// 更新用户信息
- (void)updateUserIdenty;

/// 查询出组试验结果
- (nullable SABExperimentResult *)queryOutResultWithParamName:(NSString *)paramName;

/// 查询 $ABTestTrigger 扩展属性
/// @param resultData 当前试验数据
- (nullable NSDictionary *)queryExtendedPropertiesWithExperimentResult:(SABExperimentResult *)resultData;


/// 命中试验，是否触发事件
/// @param resultData 命中的试验组信息
/// @return 是否触发事件
- (BOOL)enableTrackWithHitExperiment:(SABExperimentResult *)resultData;

@end

NS_ASSUME_NONNULL_END
