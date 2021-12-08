//
//  SensorsABTestExperiment+Private.h
//  Pods
//
//  Created by 彭远洋 on 2021/10/29.
//  Copyright © 2021 Sensors Data Inc. All rights reserved.
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

#import "SensorsABTestExperiment.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @abstract
 * 获取试验结果方式类型
 *
 * @discussion
 * 获取试验结果方式类型
 *   SABFetchABTestModeType - 从缓存获取
 *   SABFetchABTestModeTypeAsync - 异步请求获取
 *   SABFetchABTestModeTypeFast - 快速获取（优先读缓存，无缓存再异步请求）
 */
typedef NS_ENUM(NSInteger, SABFetchABTestModeType) {
    SABFetchABTestModeTypeCache,
    SABFetchABTestModeTypeAsync,
    SABFetchABTestModeTypeFast
};

typedef void (^SABCompletionHandler)(id _Nullable result);

@interface SensorsABTestExperiment (Private)

@property (nonatomic, assign) SABFetchABTestModeType modeType;
@property (nonatomic, copy) SABCompletionHandler handler;

@end

NS_ASSUME_NONNULL_END
