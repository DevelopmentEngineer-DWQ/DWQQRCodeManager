//
//  DWQQRScanner.m
//  二维码  DWQ_QRcode
//
//  Created by 杜文全 on 16/1/14.
//  Copyright © 2016年 com.sdzw.duwenquan. All rights reserved.
//

#import "DWQQRScanner.h"
@interface DWQQRScanner () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, copy) DWQQRScannerResultType resultHandler;
@end

@implementation DWQQRScanner
- (void)startScanInView:(UIView *)view resultHandler:(DWQQRScannerResultType)resultHandler {
    [self startScanInView:view machineReadableCodeObjects:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeFace] resultHandler:resultHandler];
}

- (void)startScanInView:(UIView *)view machineReadableCodeObjects:(NSArray *)codeObjects resultHandler:(DWQQRScannerResultType)resultHandler {
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        return;
    }
    self.session = [[AVCaptureSession alloc] init];
    [self.session addInput:input];
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:output];
    [output setMetadataObjectTypes:codeObjects];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill; // The videoGravity property is used to specify how the video should appear within the bounds of the layer. Since the aspect-ratio of the video is not equal to that of the screen, we want to chop off the edges of the video so that it appears to fill the entire screen, hence the use of AVLayerVideoGravityResizeAspectFill.
    self.preview.frame = view.bounds;
    [view.layer insertSublayer:self.preview atIndex:0];
    self.resultHandler = resultHandler;
    [self.session startRunning];
}

#pragma mark - <AVCaptureMetadataOutputObjectsDelegate>
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    for (AVMetadataObject *metadata in metadataObjects) {
        if ([metadata isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            AVMetadataMachineReadableCodeObject *machineCodeObject = (AVMetadataMachineReadableCodeObject *)[self.preview transformedMetadataObjectForMetadataObject:metadata];
            [self.session stopRunning];
            if (self.resultHandler) {
                self.resultHandler(self, machineCodeObject);
            }
            return;
        }
    }
    /**
     [self.session stopRunning];
     AVMetadataObject *metadata = [metadataObjects objectAtIndex:0];
     AVMetadataMachineReadableCodeObject *machineCodeObject = (AVMetadataMachineReadableCodeObject *)[self.preview transformedMetadataObjectForMetadataObject:metadata];
     if (self.resultHandler) {
     self.resultHandler(self, machineCodeObject);
     }*/
}

/**
 - (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
 {
 [self stopScan];
 AVMetadataObject *metadata = [metadataObjects objectAtIndex:0];
 [self.preview transformedMetadataObjectForMetadataObject:metadata];
 CGRect interestRect = [machineCodeObject bounds];
 NSLog(@"%@", NSStringFromCGRect(interestRect));
 NSString *codeStr  = nil;
 if ([metadata respondsToSelector:@selector(stringValue)]) {
 codeStr = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
 }
 if (self.resultHandler) {
 self.resultHandler(self, interestRect, codeStr);
 }
 }
 */

/**
 for (AVMetadataObject *object in metadataObjects) {
 if ([object.type isEqual:AVMetadataObjectTypeFace]) {
 AVMetadataFaceObject *face = (AVMetadataFaceObject *)object;
 CMTime timestamp = [face time];
 CGRect faceRectangle = face.bounds;
 //        NSInteger faceID = face.faceID;
 CGFloat rollAngle = face.rollAngle;
 CGFloat yawAngle = face.yawAngle;
 AVMetadataFaceObject *adjusted = (AVMetadataFaceObject *)[self.preview transformedMetadataObjectForMetadataObject:face];
 }
 }
 */

- (BOOL)isScanning {
    return self.session.isRunning;
}

- (void)stopScan {
    [self.session stopRunning];
}

- (void)resumeScan {
    [self.session startRunning];
}

- (void)dealloc {
    // NSLog(@"内存没有问题");
    // NSLog(@"%s", __func__);
}


@end
