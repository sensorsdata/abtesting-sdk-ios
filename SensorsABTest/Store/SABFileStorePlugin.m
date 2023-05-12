//
// SABFileStorePlugin.m
// SensorsABTesting
//
// Created by 储强盛 on 2021/12/10.
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

#import "SABFileStorePlugin.h"
#import "SABLogBridge.h"

static NSString * const kSABFileStorePluginType = @"cn.sensorsdata.ABTesting.File.";

@implementation SABFileStorePlugin

- (NSString *)filePath:(NSString *)key {
    NSString *newKey = [key stringByReplacingOccurrencesOfString:self.type withString:@""];
    NSString *filename = [NSString stringWithFormat:@"sensorsanalytics-abtest-%@.plist", newKey];
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:filename];
    return filepath;
}

#pragma mark - SAStorePlugin

- (NSString *)type {
    return kSABFileStorePluginType;
}

- (void)upgradeWithOldPlugin:(nonnull id<SAStorePlugin>)oldPlugin {

}

- (nullable id)objectForKey:(nonnull NSString *)key {
    if (!key) {
        SABLogError(@"key should not be nil for file store");
        return nil;
    }
    NSString *filePath = [self filePath:key];
    @try {
        NSData *data = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } @catch (NSException *exception) {
        SABLogError(@"%@ unable to unarchive data in %@, starting fresh", self, filePath);
        return nil;
    }
}

- (void)setObject:(nullable id)value forKey:(nonnull NSString *)key {
    if (!key || !value) {
        SABLogError(@"key should not be nil for file store");
        return;
    }
    NSString *filePath = [self filePath:key];
    
#if TARGET_OS_IOS
    /* 为filePath文件设置保护等级 */
    NSDictionary *protection = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                           forKey:NSFileProtectionKey];
#elif TARGET_OS_OSX
    // macOS10.13 不包含 NSFileProtectionComplete
    NSDictionary *protection = [NSDictionary dictionary];
#endif
    
    [[NSFileManager defaultManager] setAttributes:protection
                                     ofItemAtPath:filePath
                                            error:nil];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
    if (![NSKeyedArchiver archiveRootObject:data toFile:filePath]) {
        SABLogError(@"%@ unable to archive %@", self, key);
    } else {
        SABLogDebug(@"%@ archived %@", self, key);
    }
}

- (void)removeObjectForKey:(nonnull NSString *)key {
    NSString *filePath = [self filePath:key];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
}

@end
