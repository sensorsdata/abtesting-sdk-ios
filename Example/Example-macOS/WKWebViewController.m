//
//  WKWebViewController.m
//  Example-macOS
//
//  Created by 储强盛 on 2021/7/14.
//  Copyright © 2021 Sensors Data Inc. All rights reserved.
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
  //    httpStr = @"http://jssdk.debugbox.sensorsdata.cn/js/ls/ab/index.html";

      // 不做多链接试验
  //    httpStr = @"http://jssdk.debugbox.sensorsdata.cn/js/ls/ab/index.html?saSDKMultilink=true";

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
