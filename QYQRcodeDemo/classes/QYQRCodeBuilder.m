//
//  QYQRCodeBuilder.m
//  QYQRcodeDemo
//
//  Created by 明刘 on 16/5/6.
//  Copyright © 2016年 liuming. All rights reserved.
//

#import "QYQRCodeBuilder.h"

@implementation QYQRCodeBuilder

#pragma mark -----二维码的生成
-(UIImage *)getMyImage:(NSString *)str{
    //二维码的内容(传统的条形码只能放数字)：纯文本,名片,URL
    
    // 1. 实例化二维码滤镜
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 2. 恢复滤镜的默认属性
    
    [filter setDefaults];
    
    // 3. 将字符串转换成
    
    NSData  *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    // 4. 通过KVO设置滤镜inputMessage数据
    
    [filter setValue:data forKey:@"inputMessage"];
    
    // 5. 获得滤镜输出的图像
    
    CIImage *outputImage = [filter outputImage];
    
    // 6. 将CIImage转换成UIImage，并放大显示
    
    return [UIImage imageWithCIImage:outputImage scale:20.0 orientation:UIImageOrientationUp];
}
@end
