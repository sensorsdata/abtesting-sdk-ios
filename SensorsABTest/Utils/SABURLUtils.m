//
//  SABURLUtils.m
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

#import "SABURLUtils.h"
#import "SABLogBridge.h"

@interface SABURLUtils()
@end

@implementation SABURLUtils

+ (NSDictionary<NSString *, NSString *> *)queryItemsWithURLString:(NSString *)URLString {
    if (URLString.length == 0) {
        return nil;
    }
    NSURLComponents *components = [NSURLComponents componentsWithString:URLString];
    return [self queryItemsWithURLComponents:components];
}

+ (NSDictionary<NSString *, NSString *> *)queryItemsWithURL:(NSURL *)url {
    if (!url) {
        return nil;
    }
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    return [self queryItemsWithURLComponents:components];
}

+ (NSURL *)baseURLWithURLString:(NSString *)URLString {
    NSURL *url = [NSURL URLWithString:URLString];
    NSURLComponents *urlComponets = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    if (!urlComponets) {
        SABLogError(@"URLString is malformed, nil is returned.");
        return nil;
    }
    urlComponets.query = nil;
    return urlComponets.URL;
}


+ (NSDictionary<NSString *, NSString *> *)queryItemsWithURLComponents:(NSURLComponents *)components {
    if (!components) {
        return nil;
    }
    NSMutableDictionary *items = [NSMutableDictionary dictionaryWithCapacity:components.queryItems.count];
    for (NSURLQueryItem *queryItem in components.queryItems) {
        items[queryItem.name] = queryItem.value;
    }
    return items;
}

@end
