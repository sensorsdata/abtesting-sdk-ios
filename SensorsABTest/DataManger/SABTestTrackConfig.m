//
// SABTestTrackConfig.m
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

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "SABTestTrackConfig.h"
#import "SABValidUtils.h"


@implementation SABTestTrackConfig

- (instancetype) init {
    self = [super init];
    if (self) {
        _remoteConfig = NO;

        _triggerSwitch = YES;
        _propertySwitch = NO;
        
        // 默认扩展属性内容
        _extendedPropertyKeys = @[@"abtest_experiment_version", @"abtest_experiment_result_id"];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)triggerConfig {
    self = [super init];
    if (self) {
        /* track_config 数据结构

         "track_config": {
                 "item_switch": false,  // 暂不支持
                 "trigger_switch": true,
                 "property_set_switch": false,
                 "trigger_content_ext": [   // 上报扩展内容，SDK 上报 $ABTestTrigger 事件需要遍历集合中字段追加对应的属性，比如默认情况下，需要上报 abtest_experiment_version、abtest_experiment_result_id 内容
                     "abtest_experiment_version",
                     "abtest_experiment_result_id"
                 ],
                 "item_content" {  // 暂不支持
                     "item_name": "experimenet_trigger",
                     "content": [
                         "abtest_experiment_id",
                         "abtest_experiment_group_id",
                         "abtest_experiment_result_id",
                         "abtest_experiment_version"
                     ]
                 }
             }
         */

        _remoteConfig = YES;
        if (triggerConfig[@"trigger_switch"]) {
            _triggerSwitch = [triggerConfig[@"trigger_switch"] boolValue];
        }
        if (triggerConfig[@"property_set_switch"]) {
            _propertySwitch = [triggerConfig[@"property_set_switch"] boolValue];
        }
        if (triggerConfig[@"trigger_content_ext"]) {
            _extendedPropertyKeys = triggerConfig[@"trigger_content_ext"];
        }
    }
    return self;
}

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.triggerSwitch forKey:@"triggerSwitch"];
    [coder encodeBool:self.propertySwitch forKey:@"propertySwitch"];
    [coder encodeObject:self.extendedPropertyKeys forKey:@"extendedPropertyKeys"];
    [coder encodeBool:self.remoteConfig forKey:@"remoteConfig"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.triggerSwitch = [coder decodeBoolForKey:@"triggerSwitch"];
        self.propertySwitch = [coder decodeBoolForKey:@"propertySwitch"];
        self.extendedPropertyKeys = [coder decodeObjectForKey:@"extendedPropertyKeys"];
        self.remoteConfig = [coder decodeBoolForKey:@"remoteConfig"];

    }
    return self;
}

@end
