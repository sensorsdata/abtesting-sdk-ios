//
// SABRequestManager.h
// SensorsABTest
//
// Created by 彭远洋 on 2021/11/23.
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

#import "SensorsABTestExperiment.h"
#import "SABRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface SABRequestManager : NSObject

/// 检查当前是否已存在相同的请求任务
/// @param request 检查对象
/// @return 检查结果
- (BOOL)containsRequest:(SABExperimentRequest *)request;

/// 合并当前试验至已存在的相同请求任务中
/// @param request 当前请求
/// @param experiment 当前试验
- (void)mergeExperimentWithRequest:(SABExperimentRequest *)request experiment:(SensorsABTestExperiment *)experiment;

/// 添加新请求任务到当前列表中
/// @param request 当前请求
/// @param experiment 当前试验
- (void)addRequestTask:(SABExperimentRequest *)request experiment:(SensorsABTestExperiment *)experiment;

/// 执行对应请求任务关联的所有试验回调
/// @param request 当前请求
/// @param completion 试验结果处理闭包
- (void)excuteExperimentsWithRequest:(SABExperimentRequest *)request completion:(void(^)(SensorsABTestExperiment *))completion;

@end

NS_ASSUME_NONNULL_END
