//
// SABTestTrackConfig.h
// SensorsABTest
//
// Created by  储强盛 on 2023/1/9.
// Copyright © 2015-2023 Sensors Data Co., Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 事件触发配置
@interface SABTestTrackConfig : NSObject<NSCoding>

/// 是否触发 $ABTestTrigger 事件
@property (nonatomic, assign) BOOL triggerSwitch;

/// 是否任意事件都包含试验信息配置
@property (nonatomic, assign) BOOL propertySwitch;

/// $ABTestTrigger 事件，扩展属性列表
@property (nonatomic, copy) NSArray *extendedPropertyKeys;

/// 扩展字段，是否为远程下发配置
@property (nonatomic, assign, getter=isRemoteConfig) BOOL remoteConfig;

/// 根据 json 初始化触发配置
- (instancetype)initWithDictionary:(NSDictionary *)triggerConfig;

@end

NS_ASSUME_NONNULL_END
