//
// SABTestTriggerIdentifier.m
// SensorsABTest
//
// Created by  储强盛 on 2022/2/15.
// Copyright © 2015-2022 Sensors Data Co., Ltd. All rights reserved.
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

#import "SABTestTriggerIdentifier.h"

@interface SABTestTriggerIdentifier()

/// 试验 Id
@property (nonatomic, copy) NSString *experimentId;

/// 当前用户 distinctId
@property (nonatomic, copy) NSString *distinctId;

@end

@implementation SABTestTriggerIdentifier

- (instancetype)initWithExperimentId:(NSString *)experimentId distinctId:(NSString *)distinctId {
    self = [super init];
    if (self) {
        _experimentId = experimentId;
        _distinctId = distinctId;
    }
    return self;
}

/// 实现 isEqual:，判断是否为相同事件标识
- (BOOL)isEqual:(SABTestTriggerIdentifier *)identify {
    if (![self.distinctId isEqualToString:identify.distinctId]) {
        return NO;
    }
    if (![self.experimentId isEqualToString:identify.experimentId]) {
        return NO;
    }
    if (identify.customIDs.count == 0) {
        return self.customIDs.count == 0;
    }
    return [self.customIDs isEqualToDictionary:identify.customIDs];
}

@end
