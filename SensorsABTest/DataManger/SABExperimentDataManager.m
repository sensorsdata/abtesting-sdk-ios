//
//  SABExperimentDataManager.m
//  SensorsABTest
//
//  Created by 储强盛 on 2020/10/11.
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

#import "SABExperimentDataManager.h"
#import "SABNetwork.h"
#import "SABLogBridge.h"
#import "SABValidUtils.h"
#import "SABFileStore.h"

@interface SABExperimentDataManager()

/// 试验结果
@property (atomic, copy) NSDictionary<NSString *, SABExperimentResult *> *experimentResults;
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@end

@implementation SABExperimentDataManager

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *serialQueueLabel = [NSString stringWithFormat:@"com.SensorsABTest.SABExperimentDataManager.serialQueue.%p", self];
        _serialQueue = dispatch_queue_create([serialQueueLabel UTF8String], DISPATCH_QUEUE_SERIAL);
        // 读取本地缓存
        [self unarchiveExperimentResult];
    }
    return self;
}

- (void)asyncFetchAllExperimentWithRequest:(NSURLRequest *)request completionHandler:(SABFetchResultResponseCompletionHandler)completionHandler {
    
    [SABNetwork dataTaskWithRequest:request completionHandler:^(id _Nullable jsonObject, NSError *_Nullable error) {
        if (error) {
            SABLogError(@"asyncFetchAllABTest failure, error: %@, jsonObject: %@", error, jsonObject);
            completionHandler(nil, error);
            return;
        }

        // 数据格式错误
        if (!jsonObject || ![jsonObject isKindOfClass:NSDictionary.class]) {
            SABLogError(@"asyncFetchAllABTest invalid %@", jsonObject);
            completionHandler(nil, nil);
            return;
        }

        // 数据解析
        SABFetchResultResponse *responseData = [[SABFetchResultResponse alloc] initWithDictionary:jsonObject];

        // 获取试验成功，更新缓存
        if (responseData.status == SABFetchResultResponseStatusSuccess) {
            SABLogInfo(@"asyncFetchAllExperiment success jsonObject %@", jsonObject);
            self.experimentResults = responseData.results;
            // 存储到本地
            [self archiveExperimentResult:responseData.results];
        } else {
            SABLogWarn(@"asyncFetchAllExperiment fail，request： %@，jsonObject %@", request, jsonObject);
        }
        completionHandler(responseData, nil);
    }];
}

/// 读取本地缓存试验
- (void)unarchiveExperimentResult {
    dispatch_async(self.serialQueue, ^{
        NSData *data = [SABFileStore unarchiveWithFileName:kSABExperimentResultFileName];
        NSDictionary <NSString *, SABExperimentResult *> *result = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([result isKindOfClass:NSDictionary.class] && result.count > 0) {
            self.experimentResults = [result copy];
        }
    });
}

/// 写入本地缓存
- (void)archiveExperimentResult:(NSDictionary <NSString *, SABExperimentResult *> *)result {
    if (!result) {
        result = @{};
    }
    // 存储到本地
    dispatch_async(self.serialQueue, ^{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:result];
        [SABFileStore archiveWithFileName:kSABExperimentResultFileName value:data];
    });
}


/// 获取缓存试验结果
/// @param experimentId 试验 Id
- (SABExperimentResult *)cachedExperimentResultWithExperimentId:(NSString *)experimentId {
    if (![SABValidUtils isValidString:experimentId]) {
        return nil;
    }
    return self.experimentResults[experimentId];
}

@end
