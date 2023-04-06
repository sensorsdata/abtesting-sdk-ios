//
// SABTestGlobalPropertyPlugin.m
// SensorsABTest
//
// Created by  储强盛 on 2023/1/19.
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

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "SABTestGlobalPropertyPlugin.h"

@interface SABTestGlobalPropertyPlugin()

@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *globalProperties;

@end

@implementation SABTestGlobalPropertyPlugin


- (instancetype) init {
    self = [super init];
    if (self) {
        self.globalProperties = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)refreshGlobalProperties:(NSDictionary *)properties {
    if (properties.count == 0) {
        return;
    }
    for (NSString *key in properties.allKeys) {
        id value = properties[key];
        if ([value isKindOfClass:NSArray.class] && [(NSArray *)value count] == 0) {
            // 移除空属性
            self.globalProperties[key] = nil;
        } else {
            self.globalProperties[key] = properties[key];
        }
    }
}

- (BOOL)isMatchedWithFilter:(id<SAPropertyPluginEventFilter>)filter {
    // 属性插件，需要屏蔽 H5 事件，H5 事件中的属性，由 H5 处理
    if (filter.hybridH5) {
        return NO;
    }
    // 支持 track、Signup、Bind、Unbind
    return filter.type & SAEventTypeDefault;
}

- (SAPropertyPluginPriority)priority {
    return SAPropertyPluginPriorityLow;
}

- (NSDictionary<NSString *,id> *)properties {
    return [self.globalProperties copy];
}

@end
