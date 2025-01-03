//
// SensorsABTestConfigOptions.m
// SensorsABTest
//
// Created by 储强盛 on 2020/9/15.
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

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "SensorsABTestConfigOptions.h"
#import "SABURLUtils.h"
#import "SABPropertyValidator.h"
#import "SABLogBridge.h"

@interface SensorsABTestConfigOptions ()

/// 获取试验结果 url
@property (nonatomic, copy) NSURL *baseURL;

/// 项目 key
@property (nonatomic, copy) NSString *projectKey;

@end

@implementation SensorsABTestConfigOptions

- (instancetype)initWithURL:(nonnull NSString *)urlString {
    self = [super init];
    if (self) {
        if (urlString) {
            NSDictionary *params = [SABURLUtils queryItemsWithURLString:urlString];
            _projectKey = params[@"project-key"];
            _baseURL = [SABURLUtils baseURLWithURLString:urlString];
        }
    }
    return self;
}

#pragma mark NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    SensorsABTestConfigOptions *options = [[[self class] allocWithZone:zone] init];
    options.baseURL = self.baseURL;
    options.projectKey = self.projectKey;
    options.customProperties = self.customProperties;
    
    return options;
}

- (void)setCustomProperties:(NSDictionary *)customProperties {
    NSError *error;
    // 验证自定义属性合法性，并统一修改自定义属性值为 String 类型
    NSDictionary *properties = [SABPropertyValidator validateProperties:customProperties error:&error];
    if (error) {
        SABLogError(@"%@", error.localizedDescription);
        return;
    }
    _customProperties = properties;
}

@end
