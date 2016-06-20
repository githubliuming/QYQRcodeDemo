//
//  UIImage+commond.m
//  QYQRcodeDemo
//
//  Created by liuming on 16/5/30.
//  Copyright © 2016年 liuming. All rights reserved.
//

#import "UIImage+commond.h"

@implementation UIImage (commond)

+ (UIImage *)addImageOne:(UIImage *)imageOne toOtherImage:(UIImage *)otherImag
{
    CGSize sizeOne = imageOne.size;
    CGSize sizeTwo = otherImag.size;
    CGSize targetSize = CGSizeZero;
    if (sizeOne.width < sizeTwo.width)
    {
        targetSize.width = sizeOne.width;

        targetSize.height = sizeTwo.width * sizeOne.height / sizeOne.width;
    } else {
    
        
    }
    return nil;
}
@end
