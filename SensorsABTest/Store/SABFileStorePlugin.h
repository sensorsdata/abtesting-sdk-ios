//
// SABFileStorePlugin.h
// SensorsABTesting
//
// Created by 储强盛 on 2021/12/10.
// Copyright © 2020-2022 Sensors Data Co., Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#if __has_include(<SensorsAnalyticsSDK/SABaseStoreManager.h>)
#import <SensorsAnalyticsSDK/SAStorePlugin.h>
#elif __has_include("SAStorePlugin.h")
#import "SAStorePlugin.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 文件存储插件，兼容历史明文本地数据
@interface SABFileStorePlugin : NSObject <SAStorePlugin>

@end

NS_ASSUME_NONNULL_END
