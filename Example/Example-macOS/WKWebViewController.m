//
// WKWebViewController.m
// Example-macOS
//
// Created by 储强盛 on 2021/7/14.
// Copyright © 2021-2022 Sensors Data Co., Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "WKWebViewController.h"
#import <WebKit/WebKit.h>

@interface WKWebViewController ()
@property (weak) IBOutlet WKWebView *webView;

@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

    [self cleanWebCache];

    // js 测试页面
      NSString *httpStr = @"http://jssdk.debugbox.sensorsdata.cn/js/ls/app/sa-sdk-abtest/index.html";

      // 多链接试验
  //   httpStr = @"http://jssdk.debugbox.sensorsdata.cn/js/ls/ab/index.html";

      // 不做多链接试验
  //   httpStr = @"http://jssdk.debugbox.sensorsdata.cn/js/ls/ab/index.html?saSDKMultilink=true";

      NSURL *httpUrl = [NSURL URLWithString:httpStr];
      NSURLRequest *request = [NSURLRequest requestWithURL:httpUrl];
    [self.webView loadRequest:request];
}

- (void)cleanWebCache {
    NSArray * types =@[WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeDiskCache];
    NSSet *websiteDataTypes = [NSSet setWithArray:types];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:date completionHandler:^{
    }];
}
@end
