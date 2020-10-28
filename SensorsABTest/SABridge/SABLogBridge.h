//
//  SABLogBridge.h
//  SensorsABTest
//
//  Created by 储强盛 on 2020/9/15.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define SENSORS_ABTEST_LOG_MACRO(isAsynchronous, lvl, fnct, ctx, frmt, ...) \
[SABLogBridge log : isAsynchronous                                     \
     level : lvl                                                \
      file : __FILE__                                           \
  function : fnct                                               \
      line : __LINE__                                           \
   context : ctx                                                \
    format : (frmt), ## __VA_ARGS__]

#define SABLogError(frmt, ...)   SENSORS_ABTEST_LOG_MACRO(YES, (1 << 0), __PRETTY_FUNCTION__, 0, frmt, ##__VA_ARGS__)
#define SABLogWarn(frmt, ...)   SENSORS_ABTEST_LOG_MACRO(YES, (1 << 1), __PRETTY_FUNCTION__, 0, frmt, ##__VA_ARGS__)
#define SABLogInfo(frmt, ...)   SENSORS_ABTEST_LOG_MACRO(YES, (1 << 2), __PRETTY_FUNCTION__, 0, frmt, ##__VA_ARGS__)
#define SABLogDebug(frmt, ...)   SENSORS_ABTEST_LOG_MACRO(YES, (1 << 3), __PRETTY_FUNCTION__, 0, frmt, ##__VA_ARGS__)
#define SABLogVerbose(frmt, ...)   SENSORS_ABTEST_LOG_MACRO(YES, (1 << 4), __PRETTY_FUNCTION__, 0, frmt, ##__VA_ARGS__)

@interface SABLogBridge : NSObject

+ (void)log:(BOOL)asynchronous
   level:(NSUInteger)level
    file:(const char *)file
function:(const char *)function
    line:(NSUInteger)line
 context:(NSInteger)context
  format:(NSString *)format, ... NS_FORMAT_FUNCTION(7, 8);

@end

NS_ASSUME_NONNULL_END
