//
//  ViewController.m
//  Example
//
//  Created by 储强盛 on 2020/8/20.
//  Copyright © 2020 Sensors Data Inc. All rights reserved.
//

#import "ViewController.h"
#import "WKWebViewController.h"
#import <SensorsABTest/SensorsABTest.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
}

- (IBAction)fetchCacheAction:(UIButton *)sender {

//    [[SensorsABTest sharedInstance] handleOpenURL:[NSURL URLWithString:@"sae8ff9352://abtest?sensors_abtest_url=http://abtesting.debugbox.sensorsdata.cn/api/v2/sa/abtest/experiments/distinct_id&feature_code=16023053434&account_id=2"]];

   id result = [[SensorsABTest sharedInstance] fetchCacheABTestWithExperimentId:@"233" defaultValue:@(123)];
    NSLog(@"fetchCacheABTest，experimentId：%@ - result:%@\n",@"233", result);

}

- (IBAction)asyncFetch:(UIButton *)sender {
    [[SensorsABTest sharedInstance] asyncFetchABTestWithExperimentId:@"234" defaultValue:@(123) completionHandler:^(id  _Nullable result) {
        NSLog(@"asyncFetchABTest，experimentId：%@ - result:%@\n",@"234", result);
    }];
}

- (IBAction)fastFetch:(UIButton *)sender {
    [[SensorsABTest sharedInstance] fastFetchABTestWithExperimentId:@"234" defaultValue:@(123) completionHandler:^(id  _Nullable result) {
        NSLog(@"fastFetchABTest，experimentId：%@ - result:%@\n",@"234", result);
    }];
}

- (IBAction)gotoWKWebView:(UIButton *)sender {
    WKWebViewController *webViewVC = [[WKWebViewController alloc] init];
    [self.navigationController pushViewController:webViewVC animated:YES];
}


@end
