//
//  QYScanerView.m
//  QYQRDemo
//
//  Created by 明刘 on 16/5/6.
//  Copyright © 2016年 liuming. All rights reserved.
//

#import "QYScanerView.h"
#import <CoreImage/CoreImageDefines.h>
void showMsg(NSString *msg)
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定", nil];
    [alert show];
}
@interface QYScanerView ()<AVCaptureMetadataOutputObjectsDelegate>
{
    dispatch_queue_t dispatchQueue;
    AVCaptureDevice *captureDevice;
    // 3.创建媒体数据输出流
    AVCaptureMetadataOutput *captureMetadataOutput;

    AVCaptureDeviceInput *input;
}

@property(strong, nonatomic) UIView *boxView;
@property(nonatomic) BOOL isReading;
@property(strong, nonatomic) CALayer *scanLayer;

//捕捉会话
@property(nonatomic, strong) AVCaptureSession *captureSession;
//展示layer
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property(nonatomic, strong) NSTimer *timer;
@end
@implementation QYScanerView

- (instancetype)initWithFrame:(CGRect)frame wihtDelegate:(id<QYScanerViewDelegate>)delegate
{
    self = [self initWithFrame:frame];
    if (self)
    {
        self.delegate = delegate;
        [self initScanner];
    }

    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self)
    {
        dispatchQueue = dispatch_queue_create("myQueue", NULL);
    }

    return self;
}

- (BOOL)initScanner
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scannerwillOpenCamera:)])
    {
        [self.delegate scannerwillOpenCamera:self];
    }
    [self init_scanner];

    return YES;
}

- (void)init_scanner
{
    // 1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
    captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 3.创建媒体数据输出流
    captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // 4.实例化捕捉会话
    _captureSession = [[AVCaptureSession alloc] init];
    // 6.实例化预览图层
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];

    // 7.设置预览图层填充方式
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    // 8.设置图层的frame
    [_videoPreviewLayer setFrame:self.bounds];

    // 9.将图层添加到预览view的图层上
    [self.layer addSublayer:_videoPreviewLayer];

    // 10.1.扫描框
    CGRect frame = CGRectMake((self.frame.size.width - 200) / 2.0f, (self.frame.size.height - 200) / 2.0f, 200, 200);

    CGSize size = self.bounds.size;
    CGRect cropRect = frame;
    CGFloat p1 = size.height / size.width;
    CGFloat p2 = 1920. / 1080.;  //使用了1080p的图像输出
    if (p1 < p2)
    {
        CGFloat fixHeight = self.bounds.size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height) / 2;
        captureMetadataOutput.rectOfInterest =
            CGRectMake((cropRect.origin.y + fixPadding) / fixHeight, cropRect.origin.x / size.width,
                       cropRect.size.height / fixHeight, cropRect.size.width / size.width);
    }
    else
    {
        CGFloat fixWidth = self.bounds.size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width) / 2;
        captureMetadataOutput.rectOfInterest =
            CGRectMake(cropRect.origin.y / size.height, (cropRect.origin.x + fixPadding) / fixWidth,
                       cropRect.size.height / size.height, cropRect.size.width / fixWidth);
    }

    _boxView = [[UIView alloc] initWithFrame:frame];
    _boxView.layer.borderColor = [UIColor greenColor].CGColor;
    _boxView.layer.borderWidth = 1.0f;

    [self addSubview:_boxView];
    // 10.2.扫描线
    _scanLayer = [[CALayer alloc] init];
    _scanLayer.frame = CGRectMake(0, 0, _boxView.frame.size.width, 1);
    _scanLayer.backgroundColor = [UIColor brownColor].CGColor;

    [_boxView.layer addSublayer:_scanLayer];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSError *error;

        // 2.用captureDevice创建输入流
        input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        if (!input)
        {
            NSLog(@"%@", [error localizedDescription]);
        }

        // 4.1.将输入流添加到会话
        [_captureSession addInput:input];
        _captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
        // 4.2.将媒体输出流添加到会话中
        [_captureSession addOutput:captureMetadataOutput];

        // 5.1.设置代理
        [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];

        // 5.2.设置输出媒体数据类型为QRCode
        [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];

        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{

            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(scannerDidOpenCamera:)])
            {
                [weakSelf.delegate scannerDidOpenCamera:weakSelf];
            }
            [weakSelf startReading];
        });

    });

    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                  target:self
                                                selector:@selector(moveScanLayer:)
                                                userInfo:nil
                                                 repeats:YES];

    [self.timer setFireDate:[NSDate distantFuture]];
}
#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
    didOutputMetadataObjects:(NSArray *)metadataObjects
              fromConnection:(AVCaptureConnection *)connection
{
    dispatch_async(dispatch_get_main_queue(), ^{

        //判断是否有数据
        if (metadataObjects != nil && [metadataObjects count] > 0)
        {
            AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
            [self stopReading];
            if (self.delegate && [self.delegate respondsToSelector:@selector(scaner:scannerResult:)])
            {
                [self.delegate scaner:self scannerResult:metadataObj];
            }
        }

    });
}

- (void)startReading
{
    // 10.开始扫描
    [_captureSession startRunning];
    [self.timer setFireDate:[NSDate distantPast]];
}
- (void)stopReading
{
    [_captureSession stopRunning];
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)moveScanLayer:(NSTimer *)timer
{
    __block CGRect frame = _scanLayer.frame;
    __weak typeof(_scanLayer) weakScanLayer = _scanLayer;
    if (frame.origin.y == _boxView.frame.size.height - 1)
    {
        frame.origin.y = 0;
        weakScanLayer.frame = frame;
    }
    else
    {
        CGFloat y = MIN(_boxView.frame.size.height - 1, frame.origin.y + 5);
        [UIView animateWithDuration:0.1
                         animations:^{

                             frame.origin.y = y;
                             weakScanLayer.frame = frame;
                         }];
    }
}

- (NSString *)scanerQRFromImage:(UIImage *)image
{
    if (!image)
    {
        showMsg(@"请选择一张图片");

        return @"";
    }
    else
    {
        CGRect frame = CGRectMake(0, 0, 200, 200);
        CALayer *layer = [[CALayer alloc] init];
        layer.contents = (__bridge id _Nullable)(image.CGImage);
        layer.position = CGPointMake(100, 100);
        layer.bounds = frame;
        [_boxView.layer insertSublayer:layer atIndex:0];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                                  context:nil
                                                  options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];

        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];

        if (features.count > 0)
        {
            /**结果对象 */
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            [self stopReading];
            return scannedResult;
        }
        else
        {
            showMsg(@"该图片没有二维码");
            return @"";
        }
    }
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}
- (void)dealloc { NSLog(@"扫描试图被释放"); }
@end
