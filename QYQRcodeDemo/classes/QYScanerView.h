//
//  QYScanerView.h
//  QYQRDemo
//
//  Created by 明刘 on 16/5/6.
//  Copyright © 2016年 liuming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class QYScanerView;
@protocol QYScanerViewDelegate <NSObject>

- (void)scaner:(QYScanerView *)scanerView scannerResult:(AVMetadataMachineReadableCodeObject *)result;

@end
@interface QYScanerView : UIView


@property (nonatomic,assign)id<QYScanerViewDelegate> delegate;

- (instancetype) initWithFrame:(CGRect)frame wihtDelegate:(id<QYScanerViewDelegate> )delegate;
-(UIImage *)getMyImage:(NSString *)str;
- (NSString *)scanerQRFromImage:(UIImage *)image;
@end
