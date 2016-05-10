//
//  QYSannerResultViewController.h
//  QYQRcodeDemo
//
//  Created by 明刘 on 16/5/10.
//  Copyright © 2016年 liuming. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,QYScannerResultStyle) {

    QYScannerResultStyleTxt,
    QYScannerResultStyleWeb
};
@interface QYSannerResultViewController : UIViewController

@property (nonatomic,assign)QYScannerResultStyle resultStyle;

@property (nonatomic,strong)NSString * content;
@end
