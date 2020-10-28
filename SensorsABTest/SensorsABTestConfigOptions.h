//
//  SensorsABTestConfigOptions.h
//  SensorsABTest
//
//  Created by 储强盛 on 2020/9/15.
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

NS_ASSUME_NONNULL_BEGIN

@interface SensorsABTestConfigOptions : NSObject<NSCopying>

- (instancetype)init NS_UNAVAILABLE;


/// 指定初始化方法，设置 serverURL
/// @param urlString 设置地址链接 URL
/// @return 实例对象
- (instancetype)initWithURL:(NSString *)urlString NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
