//
//  SensorsABTestExperiment.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SensorsABTestExperiment : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithParamName:(NSString *)paramName defaultValue:(id)defaultValue NS_DESIGNATED_INITIALIZER;

+ (SensorsABTestExperiment *)experimentWithParamName:(NSString *)paramName defaultValue:(id)defaultValue;

/// 试验参数名
@property (copy, nonatomic, readonly) NSString *paramName;

/// 默认值
@property (strong, nonatomic, readonly) id defaultValue;

/// 自定义属性
@property (strong, nonatomic) NSDictionary *properties;

/// 超时时间，单位为秒
@property (assign, nonatomic) NSTimeInterval timeoutInterval;

@end

NS_ASSUME_NONNULL_END
