//
//  SABSwizzler.m
//  SensorsABTesting
//
//  Created by 储强盛 on 2021/5/11.
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

#import "SABSwizzler.h"
#import <objc/runtime.h>
#import "SABEventTracker.h"

@implementation SABSwizzler

+ (void)swizzleSATrackEvent {
    Class saEventTrackerClass = NSClassFromString(@"SAEventTracker");
    if (!saEventTrackerClass) {
        return;
    }
    SEL saTrackEventSel = NSSelectorFromString(@"trackEvent:isSignUp:");
    SEL sabTrackEventSel = NSSelectorFromString(@"sensorsabtest_trackEvent:isSignUp:");
    [saEventTrackerClass sensorsabtest_swizzle:saTrackEventSel withSelector:sabTrackEventSel destinationClass:[SABEventTracker class]];
}

@end

@implementation NSObject (SABSwizzler)
+ (void)sensorsabtest_swizzle:(SEL)originalSelector withSelector:(SEL)destinationSelector destinationClass:(Class)destinationClass {
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    if (!originalMethod) {
        return;
    }

    Method destinationMethod = class_getInstanceMethod(destinationClass, destinationSelector);
    if (!destinationMethod) {
        return;
    }

    //为了避免获取的是父类的方法
    class_addMethod(self,
                    originalSelector,
                    class_getMethodImplementation(self, originalSelector),
                    method_getTypeEncoding(originalMethod));
    class_addMethod(destinationClass,
                    destinationSelector,
                    class_getMethodImplementation(destinationClass, destinationSelector),
                    method_getTypeEncoding(destinationMethod));

    //交换之前，先对自定义方法进行添加
    BOOL didAddMethod = class_addMethod(self,
                                        destinationSelector,
                                        method_getImplementation(destinationMethod),
                                        method_getTypeEncoding(destinationMethod));
    if (didAddMethod) {
        //class_getInstanceMethod(self, destinationSelector) 重新获取一次 destinationSelector 对应的 method
        method_exchangeImplementations(originalMethod, class_getInstanceMethod(self, destinationSelector));
    }
}
@end
