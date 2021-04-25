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

    NSString *requestDistinctId = [SABBridge distinctId];
    [SABNetwork dataTaskWithRequest:requestData.request completionHandler:^(id _Nullable jsonObject, NSError *_Nullable error) {
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

        // 判断 distinctId 是否变化
        NSString *currentDistinctId = [SABBridge distinctId];
        if (![currentDistinctId isEqualToString:requestDistinctId]) {
            SABLogWarn(@"distinctId has been changed, requestDistinctId is %@, currentDistinctId is %@, Retry to asyncFetchAllABTest", requestDistinctId, currentDistinctId);

            // 刷新用户标识
            [requestData refreshUserIdenty];

            // 重试请求
            [self asyncFetchAllExperimentWithRequest:requestData completionHandler:^(SABFetchResultResponse * _Nullable responseData, NSError * _Nullable error) {
                completionHandler(responseData, error);
            }];
            return;
        }

        // 数据解析
        SABFetchResultResponse *responseData = [[SABFetchResultResponse alloc] initWithDictionary:jsonObject];

        // 获取试验成功，更新缓存
        if (responseData.status == SABFetchResultResponseStatusSuccess) {
            SABLogInfo(@"asyncFetchAllExperiment success jsonObject %@", jsonObject);
            
            // 缓存请求时刻的 distinctId
            responseData.distinctId = requestDistinctId;
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
        if ([result isKindOfClass:SABFetchResultResponse.class]) {
            SABFetchResultResponse *resultResponse = (SABFetchResultResponse *)result;
            NSString *distinctId = [SABBridge distinctId];
            // 校验缓存试验的 distinctId
            if ([resultResponse.distinctId isEqualToString:distinctId] && resultResponse.results.count > 0) {
                self.resultResponse = resultResponse;

                SABLogInfo(@"unarchiveExperimentResult success jsonObject %@", resultResponse.responseObject);
            }

            // TODO: v0.0.3 添加，尝试删除一次老版缓存，下个版本移除
        } else {
            // 首次安装，删除老版缓存
            BOOL isDelete = [SABFileStore deleteFileWithFileName:kSABExperimentResultOldFileName];
            if (isDelete) {
                SABLogInfo(@"delete old version experimentResult success");
            } else {
                SABLogWarn(@"delete old version experimentResult fail");
            }
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
    return self.resultResponse.results[paramName];
}

- (void)validateExperiment {
    // TODO: v0.0.3 添加，因为 SA 的问题，这里或 distinctId 可能不是最新，直接清除缓存即可，待 SA 通知逻辑更新后，改成判断 distinctId 是否一致来清除缓存
    self.resultResponse = nil;
}

@end
