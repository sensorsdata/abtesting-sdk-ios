//
//  WKWebViewController.m
//  Example
//
//  Created by 储强盛 on 2020/9/27.
//  Copyright © 2020 Sensors Data Inc. All rights reserved.
//

#import "WKWebViewController.h"
#import <WebKit/WebKit.h>
@interface WKWebViewController ()
@property (nonatomic, strong) WKWebView* webView;
@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.title = @"WKWebView";

    [self.view addSubview:_webView];

//    NSString *path = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"JSCallOC.html"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];

    // js 测试页面
    NSString *httpStr = @"http://jssdk.debugbox.sensorsdata.cn/js/ls/app/sa-sdk-abtest/index.html";
    // 多链接试验
//    httpStr = @"http://jssdk.debugbox.sensorsdata.cn/js/ls/ab/index.html";

    // 不做多链接试验
//    httpStr = @"http://jssdk.debugbox.sensorsdata.cn/js/ls/ab/index.html?saSDKMultilink=true";

    NSURL *httpUrl = [NSURL URLWithString:httpStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:httpUrl];

//    NSString *path = [[[NSBundle mainBundle] bundlePath]  stringByAppendingPathComponent:@"index.html"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];

    [self.webView loadRequest:request];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
