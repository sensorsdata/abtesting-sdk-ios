//
//  SABPropertyValidator.m
//  SensorsABTest
//
//  Created by 彭远洋 on 2021/10/21.
//  Copyright © 2021 Sensors Data Inc. All rights reserved.
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

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "SABPropertyValidator.h"
#import "SABJSONUtils.h"

#define SABPropertyError(errorCode, fromat, ...) \
    [NSError errorWithDomain:@"SensorsABTestErrorDomain" \
                        code:errorCode \
                    userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:fromat,##__VA_ARGS__]}] \

static NSUInteger const kSABPropertyLengthLimitation = 8191;

@protocol SABPropertyKeyValidateProtocol <NSObject>

- (BOOL)sensorsabtest_validatePropertyKey;

@end

@protocol SABPropertyValueValidateProtocol <NSObject>

- (NSString *)sensorsabtest_validatePropertyValue;

@end

@interface NSString (SABPropertyValidator) <SABPropertyKeyValidateProtocol,SABPropertyValueValidateProtocol>

@end

@implementation NSString (SABPropertyValidator)

static NSRegularExpression *_regexForValidKey;

- (BOOL)sensorsabtest_validatePropertyKey {
    if (self.length < 1) {
        return NO;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *name = @"^([a-zA-Z_][a-zA-Z\\d_]{0,99})$";
        _regexForValidKey = [NSRegularExpression regularExpressionWithPattern:name options:NSRegularExpressionCaseInsensitive error:nil];
    });
    // 保留字段通过字符串直接比较，效率更高
    NSSet *reservedProperties = [NSSet setWithObjects:@"date", @"datetime", @"distinct_id", @"event", @"events", @"first_id", @"id", @"original_id", @"properties", @"second_id", @"time", @"user_id", @"users", nil];
    for (NSString *reservedProperty in reservedProperties) {
        if ([reservedProperty caseInsensitiveCompare:self] == NSOrderedSame) {
            return NO;
        }
    }
    // 属性名通过正则表达式匹配，比使用谓词效率更高
    NSRange range = NSMakeRange(0, self.length);
    return ([_regexForValidKey numberOfMatchesInString:self options:0 range:range] > 0);
}

- (NSString *)sensorsabtest_validatePropertyValue {
    if (self.length < 1 || self.length > kSABPropertyLengthLimitation) {
        return nil;
    }
    return self;
}

@end

@interface NSNumber (SABPropertyValidator) <SABPropertyValueValidateProtocol>

@end

@implementation NSNumber (SABPropertyValidator)

- (NSString *)sensorsabtest_validatePropertyValue {
    return self.stringValue;
}

@end

@interface NSArray (SABPropertyValidator) <SABPropertyValueValidateProtocol>

@end

@implementation NSArray (SABPropertyValidator)

- (NSString *)sensorsabtest_validatePropertyValue {
    for (NSString *item in self) {
        if (![item isKindOfClass:NSString.class]) {
            return nil;
        }
        NSString *result = [(id<SABPropertyValueValidateProtocol>)item sensorsabtest_validatePropertyValue];
        if (!result) {
            return nil;
        }
    }
    return [SABJSONUtils stringWithJSONObject:self];
}

@end

@interface NSSet (SABPropertyValidator) <SABPropertyValueValidateProtocol>

@end

@implementation NSSet (SABPropertyValidator)

- (NSString *)sensorsabtest_validatePropertyValue {
    for (NSString *item in self) {
        if (![item isKindOfClass:NSString.class]) {
            return nil;
        }

        NSString *result = [(id<SABPropertyValueValidateProtocol>)item sensorsabtest_validatePropertyValue];
        if (!result) {
            return nil;
        }
    }
    return [SABJSONUtils stringWithJSONObject:self];
}

@end

@interface NSDate (SABPropertyValidator) <SABPropertyValueValidateProtocol>

@end

@implementation NSDate (SABPropertyValidator)

- (NSString *)sensorsabtest_validatePropertyValue {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    if (dateFormatter) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    }
    return [dateFormatter stringFromDate:self];
}

@end

@implementation SABPropertyValidator

+ (NSDictionary *)validateProperties:(NSDictionary *)properties error:(NSError **)error {
    if (![properties isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (id key in properties) {
        if (![key conformsToProtocol:@protocol(SABPropertyKeyValidateProtocol)]) { // 键名类型不合法
            *error = SABPropertyError(10001, @"property name [ %@ ] is not valid", key);
            return nil;
        }
        id value = properties[key];
        if (![value conformsToProtocol:@protocol(SABPropertyValueValidateProtocol)]) { // 键值类型不合法
            *error = SABPropertyError(10002, @"property values must be String, Number, Boolean, String List or Date. property [ %@ ] of value [ %@ ] is not valid", key, value);
            return nil;
        }
        if (![key sensorsabtest_validatePropertyKey]) { // 键名内容不合法
            *error = SABPropertyError(10003, @"property name [ %@ ] is not valid", key);
            return nil;
        }
        NSString *newValue = [value sensorsabtest_validatePropertyValue];
        if (!newValue) { // 键值内容不合法
            *error = SABPropertyError(10004, @"property [ %@ ] of value [ %@ ] is not valid ", key, value);
            return nil;
        }
        result[key] = newValue;
    }
    return result;
}

@end
