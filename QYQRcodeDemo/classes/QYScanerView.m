//
//  QYScanerView.m
//  QYQRDemo
//
//  Created by 明刘 on 16/5/6.
//  Copyright © 2016年 liuming. All rights reserved.
//

#import "QYScanerView.h"

@interface QYScanerView ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) UIView *boxView;
@property (nonatomic) BOOL isReading;
@property (strong, nonatomic) CALayer *scanLayer;

//捕捉会话
@property (nonatomic, strong) AVCaptureSession *captureSession;
//展示layer
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic ,strong) NSTimer *timer;
@end
@implementation QYScanerView

- (instancetype) initWithFrame:(CGRect)frame wihtDelegate:(id<QYScanerViewDelegate> )delegate{

    self = [self initWithFrame:frame];
    if (self) {
        
        self.delegate = delegate;
    }
    
    return self;
}
- (instancetype) initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self initScanner];
        [self startReading];
    }
    
    return self;
}

- (BOOL)initScanner {
    NSError *error;
    
    //1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //2.用captureDevice创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    //3.创建媒体数据输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    //4.实例化捕捉会话
    _captureSession = [[AVCaptureSession alloc] init];
    
    //4.1.将输入流添加到会话
    [_captureSession addInput:input];
    _captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
    //4.2.将媒体输出流添加到会话中
    [_captureSession addOutput:captureMetadataOutput];
    
    //5.创建串行队列，并加媒体输出流添加到队列当中
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    //5.1.设置代理
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    //5.2.设置输出媒体数据类型为QRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    //6.实例化预览图层
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    
    //7.设置预览图层填充方式
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //8.设置图层的frame
    [_videoPreviewLayer setFrame:self.bounds];
    
    //9.将图层添加到预览view的图层上
    [self.layer addSublayer:_videoPreviewLayer];
    
    //10.1.扫描框
    CGRect frame = CGRectMake((self.frame.size.width - 200)/2.0f, (self.frame.size.height - 200)/2.0f, 200, 200);
    
    
    CGSize size = self.bounds.size;
    CGRect cropRect = frame;
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用了1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = self.bounds.size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        captureMetadataOutput.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                  cropRect.origin.x/size.width,
                                                  cropRect.size.height/fixHeight,
                                                  cropRect.size.width/size.width);
    } else {
        
        CGFloat fixWidth =self.bounds.size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        captureMetadataOutput.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                                  (cropRect.origin.x + fixPadding)/fixWidth,
                                                  cropRect.size.height/size.height,
                                                  cropRect.size.width/fixWidth);
    }
   
    _boxView = [[UIView alloc] initWithFrame:frame];
    _boxView.layer.borderColor = [UIColor greenColor].CGColor;
    _boxView.layer.borderWidth = 1.0f;
    
    [self addSubview:_boxView];
    //10.2.扫描线
    _scanLayer = [[CALayer alloc] init];
    _scanLayer.frame = CGRectMake(0, 0, _boxView.frame.size.width, 1);
    _scanLayer.backgroundColor = [UIColor brownColor].CGColor;
    
    [_boxView.layer addSublayer:_scanLayer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(moveScanLayer:) userInfo:nil repeats:YES];
    
    [self.timer setFireDate:[NSDate distantFuture]];
    
   
    return YES;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //判断是否有数据
        if (metadataObjects != nil && [metadataObjects count] > 0) {
            AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
            [self stopReading];
            if (self.delegate && [self.delegate respondsToSelector:@selector(scaner:scannerResult:)]) {
                
                [self.delegate scaner:self scannerResult:metadataObj];
            }
            
        }
        
    });
    
//        //判断回传的数据类型
//        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
//            
//            NSLog(@"%@",[metadataObj stringValue]);
//            [self stopReading];
//        }
    
}

- (void) startReading{
    
    //10.开始扫描
    [_captureSession startRunning];
    [self.timer setFireDate:[NSDate distantPast]];
}
-(void)stopReading{
    [_captureSession stopRunning];
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)moveScanLayer:(NSTimer *)timer
{
    __block CGRect frame = _scanLayer.frame;
    if (frame.origin.y == _boxView.frame.size.height -1) {
        frame.origin.y = 0;
        _scanLayer.frame = frame;
        
    } else {
    
        CGFloat y = MIN(_boxView.frame.size.height - 1, frame.origin.y + 5);
        [UIView animateWithDuration:0.1 animations:^{
            
             frame.origin.y = y;
            _scanLayer.frame = frame;
        }];
    }
    
    
}

@end
