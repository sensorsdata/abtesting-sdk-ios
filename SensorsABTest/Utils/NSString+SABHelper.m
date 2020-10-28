//
//  NSString+SABHelper.m
//  SensorsABTest
//
//  Created by 储强盛 on 2020/9/18.
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

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "NSString+SABHelper.h"

@implementation NSString (SABHelper)

- (NSComparisonResult)sensorsabtest_compareVersion:(NSString *)version {
    NSArray<NSString *> *componentsA = [self componentsSeparatedByString:@"."];
    NSArray<NSString *> *componentsB = [version componentsSeparatedByString:@"."];
    NSUInteger length = MAX(componentsA.count, componentsB.count);
    for (NSUInteger index = 0; index < length; index++) {
        NSInteger num1 = index < componentsA.count ? [componentsA[index] integerValue] : 0;
        NSInteger num2 = index < componentsB.count ? [componentsB[index] integerValue] : 0;
        if (num1 < num2) {
            return NSOrderedAscending;
        } else if (num1 > num2) {
            return NSOrderedDescending;
        }
    }
    return NSOrderedSame;
}

@end
