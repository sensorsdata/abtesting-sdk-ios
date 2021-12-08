//
//  SensorsABTestExperiment.m
//  SensorsABTest
//
//  Created by 彭远洋 on 2021/10/22.
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

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "SensorsABTestExperiment.h"
#import "SABConstants.h"
#import "SensorsABTestExperiment+Private.h"

@interface SensorsABTestExperiment ()

/// 试验参数
@property (nonatomic, copy, readwrite) NSString *paramName;

/// 默认值
@property (nonatomic, strong, readwrite) id defaultValue;

/// 获取类型
@property (nonatomic, assign) SABFetchABTestModeType modeType;

/// 回调函数
@property (nonatomic, copy) SABCompletionHandler handler;

@end

@implementation SensorsABTestExperiment

- (instancetype)initWithParamName:(NSString *)paramName defaultValue:(id)defaultValue {
    self = [super init];
    if (self) {
        _paramName = paramName;
        _defaultValue = defaultValue;
        _timeoutInterval = kSABFetchABTestResultDefaultTimeoutInterval;
    }
    return self;
}

+ (SensorsABTestExperiment *)experimentWithParamName:(NSString *)paramName defaultValue:(id)defaultValue {
    return [[SensorsABTestExperiment alloc] initWithParamName:paramName defaultValue:defaultValue];
}

@end
