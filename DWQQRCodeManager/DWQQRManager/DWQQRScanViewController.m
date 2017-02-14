//
//  DWQQRScanViewController.m
//  二维码  DWQ_QRcode
//
//  Created by 杜文全 on 16/1/14.
//  Copyright © 2016年 com.sdzw.duwenquan. All rights reserved.
//

#import "DWQQRScanViewController.h"
#import "DWQQRScanner.h"
#import "DWQQROptionView.h"
#import "DWQQRIndicatorView.h"
#import "DWQQRImageHelper.h"
@interface DWQQRScanViewController ()
@property (nonatomic) DWQQRIndicatorView *indicatorView; // 指示视图，缩放并定位到二维码具体区域
@property (nonatomic) DWQQRScanner *scanner;
@property (nonatomic) NSString *result;
@end

@implementation DWQQRScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     [self initUI];
}
- (void)initUI {
    // 指示视图
    self.indicatorView = [[DWQQRIndicatorView alloc] initWithFrame:self.view.bounds];
    self.indicatorView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_indicatorView];
    
    // 选项视图：二维码扫描/读取相册/开灯
    DWQQROptionView *optionView = [DWQQROptionView optionViewWithFrame:CGRectMake(0, self.view.bounds.size.height-100, [[UIScreen mainScreen] bounds].size.width, 100)];
    [self.view addSubview:optionView];
    
    __weak __typeof(self) weakself = self;
    optionView.callbackHandler = ^(NSInteger index) {
        switch (index) {
            case 0: { // 相册
                [DWQQRImageHelper getQRStrByPickImageWithController:self completionHandler:^(CIImage *image, NSString *decodeStr) {
                    NSLog(@"%@", decodeStr);
                    if (decodeStr == nil) {
                        NSLog(@"不是合法的二维码图片");
                        return ;
                    }
                    if (self.resultHandler) {
                        self.resultHandler(self, decodeStr);
                    }
                }];
                break;
            }
            case 1: { // 开灯
                [weakself lightOn];
                break;
            }
            case 2: { // 取消
                [weakself cancel];
                break;
            }
            default:
                break;
        }
    };
}

/**
 *  开灯
 */
- (void)lightOn {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (captureDevice.torchMode == AVCaptureTorchModeOff) {
        [captureDevice lockForConfiguration:nil];
        captureDevice.torchMode = AVCaptureTorchModeOn; // 开启闪光灯
    } else {
        captureDevice.torchMode = AVCaptureTorchModeOff; // 关闭闪光灯
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startScan];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopScan];
}

- (void)stopScan {
    [self.indicatorView indicateEnd];
    [self.scanner stopScan];
    // self.scanner = nil;
}

- (void)startScan {
    [self.indicatorView indicateStart];
    
    if (self.scanner != nil) {
        [self.scanner resumeScan];
        return;
    }
    
    // 判断是否允许使用相机 iOS7 and later 设置--隐私--相机
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            NSString*str = [NSString stringWithFormat:@"请在系统设置－%@－相机中打开允许使用相机",  [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey]];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:str delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return ;
        }
    }
    
    self.scanner = [[DWQQRScanner alloc] init];
    __weak __typeof(self) weakself = self;
    [self.scanner startScanInView:weakself.view resultHandler:^(DWQQRScanner *scanner, AVMetadataMachineReadableCodeObject *codeObject) {
        // weakself.indicatorView.duration = 2.0; // 默认0.25
        weakself.indicatorView.codeObject  = codeObject;
        [weakself.indicatorView indicateLockInWithCompletion:^(NSString *str) {
            if (weakself.resultHandler) {
                weakself.resultHandler(weakself, str);
            }
        }];
    }];
    
    /**
     [self.scanner startScanInView:weakself.view resultHandler:^(ZZQRScanner *scanner, CGRect interestRect, NSString *result) {
     
     weakself.result                  = result;
     CABasicAnimation *frameAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
     frameAnimation.duration          = 0.4f;
     frameAnimation.timingFunction    = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
     frameAnimation.fromValue         = [NSValue valueWithCGRect:weakself.indicatorView.frame];
     frameAnimation.toValue           = [NSValue valueWithCGRect:interestRect];
     frameAnimation.delegate          = weakself;
     weakself.indicatorView = [];
     [weakself.indicatorView setFrame:interestRect];
     [weakself.indicatorView.layer addAnimation:frameAnimation forKey:@"MoveAnimationKey"];
     
     NSLog(@"\n(%lf,%lf) (%lf,%lf) (%lf,%lf), (%lf,%lf)\n", interestRect.origin.x, interestRect.origin.y, interestRect.origin.x, CGRectGetMaxY(interestRect), CGRectGetMaxX(interestRect), CGRectGetMaxY(interestRect), CGRectGetMaxX(interestRect), interestRect.origin.y);
     }];
     */
}

- (void)cancel {
    [self.scanner stopScan];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 解码二维码图片
// https://www.shinobicontrols.com/blog/ios8-day-by-day-day-13-coreimage-detectors
- (CIImage *)prepareRectangleDetector:(CIImage *)ciImage {
    NSDictionary *options = @{CIDetectorAccuracy : CIDetectorAccuracyHigh};
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:options];
    NSArray *features = [detector featuresInImage:ciImage];
    for (CIFeature *feature in features) {
        if ([feature isKindOfClass:[CIQRCodeFeature class]]) {
            CIQRCodeFeature *qrFeature = (CIQRCodeFeature *)feature;
            //CIRectangleFeature *rectangleFeature = (CIRectangleFeature *)feature;
            //resultImage = [self drawHighlightOverlayForImage:ciImage feature:rectangleFeature];
            [qrFeature messageString];
        }
    }
    return nil;
}

#pragma mark -

- (void)dealloc {
    // NSLog(@"内存没有问题");
    // NSLog(@"%s", __func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
