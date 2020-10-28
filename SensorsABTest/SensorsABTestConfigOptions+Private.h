//
//  SensorsABTestConfigOptions+Private.h
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

#import "SensorsABTestConfigOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface SensorsABTestConfigOptions (Private)

/// 获取试验结果 url
@property (nonatomic, copy, readonly) NSURL *baseURL;

/// 项目 key
@property (nonatomic, copy, readonly) NSString *projectKey;

@end

NS_ASSUME_NONNULL_END
