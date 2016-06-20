//
//  QYScannerViewController.m
//  QYQRcodeDemo
//
//  Created by 明刘 on 16/5/6.
//  Copyright © 2016年 liuming. All rights reserved.
//
#import "QYScannerViewController.h"
#import "QYScanerView.h"
#import "QYSannerResultViewController.h"
@interface QYScannerViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,
                                      QYScanerViewDelegate>

@property(nonatomic, strong) QYScanerView *scannerView;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation QYScannerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //选取相册中的二维码进行扫描
    self.scannerView = [[QYScanerView alloc] initWithFrame:self.view.bounds wihtDelegate:self];
    [self.view addSubview:self.scannerView];

    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];

    btn.frame = CGRectMake(10, 400, 200, 40);
    [btn setTitle:@"从相册中选取" forState:UIControlStateNormal];

    [btn addTarget:self action:@selector(selectedQRFromAblumHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.scannerView stopTimer];
}
- (void)viewDidAppear:(BOOL)animated { [super viewDidAppear:animated]; }
#pragma mark - QYScanerViewDelegate
- (void)scaner:(QYScanerView *)scanerView scannerResult:(AVMetadataMachineReadableCodeObject *)result
{
    if ([[result type] isEqualToString:AVMetadataObjectTypeQRCode])
    {
        NSString *string = [result stringValue];

        [self showResult:string];
    }
}
- (void)selectedQRFromAblumHandler
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    NSString *result = [self.scannerView scanerQRFromImage:image];
    if (![result isEqualToString:@""])
    {
        [self showResult:result];
    }
}

- (void)showResult:(NSString *)result
{
    if ([result hasPrefix:@"http://"] || [result hasPrefix:@"https://"])
    {
        //网络地址

        QYSannerResultViewController *viewControll = [[QYSannerResultViewController alloc] init];
        viewControll.resultStyle = QYScannerResultStyleWeb;
        viewControll.content = result;

        [self.navigationController pushViewController:viewControll animated:YES];
    }
    else
    {
        //    文本

        QYSannerResultViewController *viewControll = [[QYSannerResultViewController alloc] init];
        viewControll.resultStyle = QYScannerResultStyleTxt;
        viewControll.content = result;

        [self.navigationController pushViewController:viewControll animated:YES];
    }
}

- (void)scannerwillOpenCamera:(QYScanerView *)scannerView
{
    //摄像头
    NSLog(@"将要打开摄像头");
    scannerView.hidden = YES;
    if (self.activityIndicatorView == nil)
    {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        self.activityIndicatorView.center = self.view.center;
        [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.activityIndicatorView setBackgroundColor:[UIColor lightGrayColor]];
        [self.view addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
    }
}

- (void)scannerDidOpenCamera:(QYScanerView *)scannerView
{
    //摄像头已经打开

    NSLog(@"摄像头一打开");
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.activityIndicatorView)
        {
            scannerView.hidden = NO;
            [weakSelf.activityIndicatorView removeFromSuperview];
            [weakSelf.activityIndicatorView stopAnimating];
            weakSelf.activityIndicatorView = nil;
        }

    });
}
- (void)dealloc
{
    NSLog(@"扫描控制器被释放");
    self.scannerView = nil;
}
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
