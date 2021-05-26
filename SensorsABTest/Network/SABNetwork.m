//
//  SABNetwork.m
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

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "SABNetwork.h"
#import "SABLogBridge.h"
#import "SABJSONUtils.h"

@interface SABNetwork()

@property(nonatomic, strong) NSURLSession *session;

@end

@implementation SABNetwork

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSOperationQueue *networkQueue = [[NSOperationQueue alloc] init];
        networkQueue.name = [NSString stringWithFormat:@"com.SensorsABTest.SABNetwork.%p", self];
        networkQueue.maxConcurrentOperationCount = 1;

        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.timeoutIntervalForRequest = 30;
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:networkQueue];
    }
    return self;
}

+ (instancetype) sharedInstance {
    static SABNetwork *sharedInstance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    }) ;

    return sharedInstance;
}

+ (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(SABURLSessionTaskCompletionHandler)completionHandler {
    if (!request || !completionHandler) {
        return nil;
    }
    SABNetwork *network = [SABNetwork sharedInstance];
    NSURLSessionDataTask *task = [network.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
            return completionHandler(nil, error);
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            completionHandler([SABJSONUtils JSONObjectWithData:data], nil);
        } else {
            SABLogError(@"SABNetwork dataTaskWithRequest failure, error: %@, response: %@",error, response);
            completionHandler(nil, error);
        }
    }];
    [task resume];
    return task;
}

@end
