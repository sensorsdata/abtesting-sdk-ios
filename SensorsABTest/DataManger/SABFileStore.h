//
//  SABFileStore.h
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

@interface SABFileStore : NSObject

/// 本地文件存储
/// @param fileName 文件名
/// @param value 存储内容
/// @return YES/NO 是否存储成功
+ (BOOL)archiveWithFileName:(NSString *)fileName value:(nullable id)value;

/// 读取本地存储的文件内容
/// @param fileName 文件名
/// @return 缓存数据
+ (nullable id)unarchiveWithFileName:(NSString *)fileName;

/// 删除文件
/// @param fileName 文件名
/// @return YES/NO 是否删除成功
+ (BOOL)deleteFileWithFileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
