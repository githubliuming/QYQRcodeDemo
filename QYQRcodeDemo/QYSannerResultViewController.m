//
//  QYSannerResultViewController.m
//  QYQRcodeDemo
//
//  Created by 明刘 on 16/5/10.
//  Copyright © 2016年 liuming. All rights reserved.
//

#import "QYSannerResultViewController.h"

@interface QYSannerResultViewController ()<UIWebViewDelegate>

@property(nonatomic, strong) UIWebView *web;
@end

@implementation QYSannerResultViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor whiteColor];
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (self.resultStyle)
        {
            case QYScannerResultStyleTxt:
            {
                UILabel *label =
                    [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height - 300) / 2.0,
                                                              self.view.bounds.size.width, 300)];
                label.text = self.content;
                label.backgroundColor = [UIColor orangeColor];
                label.layer.masksToBounds = YES;
                label.layer.cornerRadius = 5;
                label.layer.borderColor = [UIColor greenColor].CGColor;
                label.layer.borderWidth = 1;
                [self.view addSubview:label];
                break;
            }
            case QYScannerResultStyleWeb:
            {
                NSURLRequest *requst = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.content]];
                self.web = [[UIWebView alloc] initWithFrame:self.view.bounds];
                self.web.delegate = self;
                [self.web loadRequest:requst];
                [self.view addSubview:self.web];
                break;
            }
        }
    });
}

- (void)webViewDidStartLoad:(UIWebView *)webView {}
- (void)webViewDidFinishLoad:(UIWebView *)webView {}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
