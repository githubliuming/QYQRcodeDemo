//
//  QYQRBuilderViewController.m
//  QYQRcodeDemo
//
//  Created by 明刘 on 16/5/6.
//  Copyright © 2016年 liuming. All rights reserved.
//

#import "QYQRBuilderViewController.h"
#import "QYQRCodeBuilder.h"
@interface QYQRBuilderViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *msgTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;



@property (nonatomic,strong) UIImage * image;

@end

@implementation QYQRBuilderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"生成二维码";
}
- (IBAction)builderQRCodehandler:(id)sender {
    
    NSString * string = self.msgTextField.text;
    
    if (string.length <= 0) {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"文本信息不能为空" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alertView show];
        return ;
    }
    
    QYQRCodeBuilder * builder = [[QYQRCodeBuilder alloc] init];
    self.image = [builder getMyImage:self.msgTextField.text size:CGSizeMake(200, 200)];
    
    self.imageView.image = self.image;
}
- (void)saveImageToPhotos:(UIImage*)savedImage
{
     UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo

{

    NSString *msg = nil ;

    if(error != NULL){

        msg = @"保存图片失败" ;
        NSLog(@"%@",[error userInfo]);

    }else{

        msg = @"保存图片成功" ;

    }

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                         
                                                    message:msg
                        
                                                   delegate:self
                          
                                          cancelButtonTitle:@"确定"
                         
                                          otherButtonTitles:nil];

    [alert show];

}

- (IBAction)saveQRCodeHander:(id)sender {
    
    
    [self saveImageToPhotos:self.image];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    [self.msgTextField resignFirstResponder];
    return  YES;
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
