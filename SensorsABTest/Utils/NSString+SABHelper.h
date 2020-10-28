//
//  NSString+SABHelper.h
//  SensorsABTest
//
//  Created by 储强盛 on 2020/9/18.
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

@interface NSString (SABHelper)

/// 比较版本号大小
/// @param version 版本号字符串
/// @return 比较结果
- (NSComparisonResult)sensorsabtest_compareVersion:(NSString *)version;

@end

NS_ASSUME_NONNULL_END
