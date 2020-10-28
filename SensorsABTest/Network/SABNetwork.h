//
//  SABNetwork.h
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

typedef void(^SABURLSessionTaskCompletionHandler)(id _Nullable jsonObject, NSError * _Nullable error);

@interface SABNetwork : NSObject

/// 通过 request 创建一个 task，并设置完成的回调
/// @param request 请求 request
/// @param completionHandler 结果回调
/// @return NSURLSessionDataTask 对象
+ (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(SABURLSessionTaskCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
