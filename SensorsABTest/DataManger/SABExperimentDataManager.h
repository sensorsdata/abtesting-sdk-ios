//
//  SABExperimentDataManager.h
//  SensorsABTest
//
//  Created by 储强盛 on 2020/10/11.
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
#import "SABFetchResultResponse.h"
#import "SABRequest.h"

typedef void(^SABFetchResultResponseCompletionHandler)(SABFetchResultResponse *_Nullable responseData, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

/// 数据存储和解析
@interface SABExperimentDataManager : NSObject

/// 请求白名单，只在发送请求成功后更新
@property (atomic, strong, readonly) NSArray <NSString *> *fuzzyExperiments;

/// 获取缓存试验结果
- (nullable SABExperimentResult *)cachedExperimentResultWithParamName:(NSString *)paramName;

/// 异步请求所有试验
- (void)asyncFetchAllExperimentWithRequest:(SABExperimentRequest *)requestData completionHandler:(SABFetchResultResponseCompletionHandler)completionHandler;

/// 切换用户，清空缓存
- (void)clearExperiment;

@end

NS_ASSUME_NONNULL_END
