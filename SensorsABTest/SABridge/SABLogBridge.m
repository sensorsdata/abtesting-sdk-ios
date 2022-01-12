//
// SABLogBridge.m
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

#import "SABLogBridge.h"

typedef void (*SALogMethod)(id,SEL,BOOL,NSString*,NSUInteger,const char*,const char*,NSUInteger,NSInteger);

@implementation SABLogBridge

+ (void)log:(BOOL)asynchronous level:(NSUInteger)level file:(const char *)file function:(const char *)function line:(NSUInteger)line context:(NSInteger)context format:(NSString *)format, ... {
    if (!format) {
        return;
    }
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    Class saLogClass = NSClassFromString(@"SALog");
    if (!saLogClass) {
        return;
    }
    SEL logMessageSEL = NSSelectorFromString(@"log:message:level:file:function:line:context:");
    SALogMethod logMessageIMP = (SALogMethod)[saLogClass methodForSelector:logMessageSEL];
    logMessageIMP(saLogClass,logMessageSEL,asynchronous,message,level,file,function,line,context);
}

@end
