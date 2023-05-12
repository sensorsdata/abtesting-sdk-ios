//
// SABJSONUtils.m
// SensorsABTest
//
// Created by 储强盛 on 2020/10/15.
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

#import "SABJSONUtils.h"
#import "SABLogBridge.h"
#import "SABValidUtils.h"

@implementation SABJSONUtils

/// json 数据解析
+ (nullable id)JSONObjectWithData:(NSData *)data {
    if (![SABValidUtils isValidData:data]) {
        SABLogInfo(@"json data is nil");
        return nil;
    }
    NSError *jsonError = nil;
    id jsonObject = nil;
    @try {
        jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    } @catch (NSException *exception) {
        SABLogError(@"%@", exception);
    } @finally {
        return jsonObject;
    }
}

/// JsonString 数据解析
+ (nullable id)JSONObjectWithString:(NSString *)string {
    if (![SABValidUtils isValidString:string]) {
        return nil;
    }
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        SABLogError(@"string dataUsingEncoding failure:%@",string);
        return nil;
    }
    return [self JSONObjectWithData:data];
}

+ (nullable NSData *)JSONSerializeObject:(id)obj {
    if (![NSJSONSerialization isValidJSONObject:obj]) {
        return nil;
    }
    NSError *error = nil;
    NSData *data = nil;
    @try {
        data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:&error];
    }
    @catch (NSException *exception) {
        SABLogError(@"%@ exception encoding api data: %@", self, exception);
    }
    if (error) {
        SABLogError(@"%@ error encoding api data: %@", self, error);
    }
    return data;
}

+ (NSString *)stringWithJSONObject:(id)obj {
    NSData *jsonData = [self JSONSerializeObject:obj];
    if (![jsonData isKindOfClass:NSData.class]) {
        SABLogError(@"json data is invalid");
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (id)JSONObjectByRemovingKeysWithNullValues:(id)object {
    if (!object) {
        return nil;
    }
    return [self JSONObjectByRemovingKeysWithNullValues:object options:0];
}

/// 移除 json 中的 null
/// 已有合法性判断，暂未使用
+ (id)JSONObjectByRemovingKeysWithNullValues:(id)object options:(NSJSONReadingOptions)readingOptions {
    if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[(NSArray *)object count]];
        for (id value in (NSArray *)object) {
            if (![value isEqual:[NSNull null]]) {
                [mutableArray addObject:[SABJSONUtils JSONObjectByRemovingKeysWithNullValues:value options:readingOptions]];
            }
        }

        return (readingOptions & NSJSONReadingMutableContainers) ? mutableArray : [NSArray arrayWithArray:mutableArray];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:object];
        for (id <NSCopying> key in [(NSDictionary *)object allKeys]) {
            id value = (NSDictionary *)object[key];
            if (!value || [value isEqual:[NSNull null]]) {
                [mutableDictionary removeObjectForKey:key];
            } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
                mutableDictionary[key] = [SABJSONUtils JSONObjectByRemovingKeysWithNullValues:value options:readingOptions];
            }
        }

        return (readingOptions & NSJSONReadingMutableContainers) ? mutableDictionary : [NSDictionary dictionaryWithDictionary:mutableDictionary];
    }

    return object;
}
@end
