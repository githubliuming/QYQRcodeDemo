//
//  QYScannerViewController.m
//  QYQRcodeDemo
//
//  Created by 明刘 on 16/5/6.
//  Copyright © 2016年 liuming. All rights reserved.
//

#import "QYScannerViewController.h"
#import "QYScanerView.h"
@interface QYScannerViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@end

@implementation QYScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    QYScanerView * scannerView = [[QYScanerView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:scannerView];
    
    
    //选取相册中的二维码进行扫描
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn.frame =CGRectMake( 10, 400, 200, 40);
    [btn setTitle:@"从相册中选取" forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(selectedQRFromAblumHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)selectedQRFromAblumHandler{
    
    UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing=YES;
    picker.sourceType=sourceType;
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage * image=[info objectForKey:UIImagePickerControllerEditedImage];
}
- (void)didReceiveMemoryWarning {
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
