//
// SABExperimentDataManager.m
// SensorsABTest
//
// Created by 储强盛 on 2020/10/11.
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

#import "SABExperimentDataManager.h"
#import "SABNetwork.h"
#import "SABLogBridge.h"
#import "SABValidUtils.h"
#import "SABBridge.h"
#import "SABStoreManager.h"
#import "SABFileStorePlugin.h"

@interface SABExperimentDataManager()

/// 试验结果
@property (atomic, strong) SABFetchResultResponse *resultResponse;
@property (atomic, strong, readwrite) NSArray <NSString *> *fuzzyExperiments;
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation SABExperimentDataManager

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *serialQueueLabel = [NSString stringWithFormat:@"com.SensorsABTest.SABExperimentDataManager.serialQueue.%p", self];
        _serialQueue = dispatch_queue_create([serialQueueLabel UTF8String], DISPATCH_QUEUE_SERIAL);

        [self resgisterStorePlugins];
        
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

            // 只有在请求成功后才可以更新白名单
            self.fuzzyExperiments = responseData.responseObject[@"fuzzy_experiments"];

            // 存储到本地
            [self archiveExperimentResult:responseData];
        } else {
            SABLogWarn(@"asyncFetchAllExperiment fail，request： %@，jsonObject %@", requestData.request, jsonObject);
        }
        completionHandler(responseData, nil);
    }];
}

#pragma mark - cache
/// 读取本地缓存试验
- (void)unarchiveExperimentResult {
    dispatch_async(self.serialQueue, ^{
        id result = [SABStoreManager.sharedInstance objectForKey:kSABExperimentResultFileName];
        // 解析缓存
        if (![result isKindOfClass:SABFetchResultResponse.class]) {
            SABLogDebug(@"unarchiveExperimentResult failure %@", result);
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
        [SABStoreManager.sharedInstance setObject:resultResponse forKey:kSABExperimentResultFileName];
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
    // 清除试验时也需要清除当前白名单
    self.fuzzyExperiments = nil;
    dispatch_async(self.serialQueue, ^{
        // 删除本地缓存
        [SABStoreManager.sharedInstance removeObjectForKey:kSABExperimentResultFileName];
    });
}

#pragma mark - StorePlugins
- (void)resgisterStorePlugins {
    // 文件明文存储，兼容历史本地数据
    SABFileStorePlugin *filePlugin = [[SABFileStorePlugin alloc] init];
    [[SABStoreManager sharedInstance] registerStorePlugin:filePlugin];
    
    // 注册 SA 的自定义插件
    for (id<SAStorePlugin> plugin in SABBridge.storePlugins) {
        [[SABStoreManager sharedInstance] registerStorePlugin:plugin];
    }
}

@end
