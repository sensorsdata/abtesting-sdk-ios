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
#import "SABBridge.h"

@interface SABExperimentDataManager()

/// 试验结果
@property (atomic, strong) SABFetchResultResponse *resultResponse;
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

- (void)asyncFetchAllExperimentWithRequest:(SABExperimentRequest *)requestData completionHandler:(SABFetchResultResponseCompletionHandler)completionHandler {

    [SABNetwork dataTaskWithRequest:requestData.request completionHandler:^(id _Nullable jsonObject, NSError *_Nullable error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }

        // 数据格式错误
        if (!jsonObject || ![jsonObject isKindOfClass:NSDictionary.class]) {
            SABLogError(@"asyncFetchAllABTest invalid %@", jsonObject);
            NSError *error = [[NSError alloc] initWithDomain:@"SABResponseInvalidError" code:-1011 userInfo:@{NSLocalizedDescriptionKey: @"JSON parse error"}];
            completionHandler(nil, error);
            return;
        }

        // 数据解析
        SABFetchResultResponse *responseData = [[SABFetchResultResponse alloc] initWithDictionary:jsonObject];
        // 获取试验成功，更新缓存
        if (responseData.status == SABFetchResultResponseStatusSuccess) {
            SABLogInfo(@"asyncFetchAllExperiment success jsonObject %@", jsonObject);
            
            // 缓存请求时刻的用户信息
            responseData.userIdenty = requestData.userIdenty;

            self.resultResponse = responseData;
            // 存储到本地
            [self archiveExperimentResult:responseData];
        } else {
            SABLogWarn(@"asyncFetchAllExperiment fail，request： %@，jsonObject %@", requestData.request, jsonObject);
        }
        completionHandler(responseData, nil);
    }];
}

/// 读取本地缓存试验
- (void)unarchiveExperimentResult {
    dispatch_async(self.serialQueue, ^{
        NSData *data = [SABFileStore unarchiveWithFileName:kSABExperimentResultFileName];
        id result = [NSKeyedUnarchiver unarchiveObjectWithData:data];

        // 解析缓存
        if (![result isKindOfClass:SABFetchResultResponse.class]) {
            SABLogDebug(@"unarchiveExperimentResult fail %@", result);
            return;
        }

        SABFetchResultResponse *resultResponse = (SABFetchResultResponse *)result;
        NSString *distinctId = [SABBridge distinctId];
        // 校验缓存试验的 distinctId
        if ([resultResponse.userIdenty.distinctId isEqualToString:distinctId] && resultResponse.results.count > 0) {
            self.resultResponse = resultResponse;
            SABLogInfo(@"unarchiveExperimentResult success jsonObject %@", resultResponse.responseObject);
        }
    });
}

/// 写入本地缓存
- (void)archiveExperimentResult:(SABFetchResultResponse *)resultResponse {
    // 存储到本地
    dispatch_async(self.serialQueue, ^{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:resultResponse];
        [SABFileStore archiveWithFileName:kSABExperimentResultFileName value:data];
    });
}


/// 获取缓存试验结果
/// @param paramName 试验参数名
- (SABExperimentResult *)cachedExperimentResultWithParamName:(NSString *)paramName {
    if (![SABValidUtils isValidString:paramName]) {
        return nil;
    }
    
    __block SABExperimentResult *result = nil;
    dispatch_sync(self.serialQueue, ^{
        result = self.resultResponse.results[paramName];
    });
    return result;
}

- (void)clearExperiment {
    self.resultResponse = nil;

    // 删除本地缓存
    [SABFileStore deleteFileWithFileName:kSABExperimentResultFileName];
}

@end
