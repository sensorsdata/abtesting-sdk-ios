//
//  SABURLUtils.h
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

@interface SABURLUtils : NSObject

/// 解析 query 参数
/// @param URLString url 字符串
/// @return 参数 Dictionary
+ (NSDictionary<NSString *, NSString *> *)queryItemsWithURLString:(NSString *)URLString;

/// 解析 query 参数
/// @param url NSURL 对象
/// @return 参数 Dictionary
+ (NSDictionary<NSString *, NSString *> *)queryItemsWithURL:(NSURL *)url;

/// 解析 baseURL
/// @param URLString url 字符串
/// @return NSURL 对象
+ (NSURL *)baseURLWithURLString:(NSString *)URLString;

@end

