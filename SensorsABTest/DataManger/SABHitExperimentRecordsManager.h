//
// SABHitExperimentRecordsManager.h
// SensorsABTest
//
// Created by  储强盛 on 2023/1/19.
// Copyright © 2015-2023 Sensors Data Co., Ltd. All rights reserved.
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

/// 命中记录数据管理
@interface SABHitExperimentRecordsManager : NSObject

/// 指定初始化接口
/// @param serialQueue 串行队列
- (instancetype)initWithSerialQueue:(dispatch_queue_t)serialQueue NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/// 命中试验，是否需要触发事件
/// @param resultData 命中的试验组信息
/// @return 是否需要触发事件
- (BOOL)enableTrackWithHitExperiment:(SABExperimentResult *)resultData;


/// 查询当前用户的所有命中记录试验结果 Id
/// @param userIdenty 用户信息
/// @return 试验结果 Id 集合
- (nullable NSArray <NSString *> *)queryAllResultIdOfHitRecordsWithUser:(SABUserIdenty *)userIdenty;

@end

NS_ASSUME_NONNULL_END
