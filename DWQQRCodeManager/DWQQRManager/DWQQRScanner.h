//
//  DWQQRScanner.h
//  二维码  DWQ_QRcode
//
//  Created by 杜文全 on 16/1/14.
//  Copyright © 2016年 com.sdzw.duwenquan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class DWQQRScanner;
typedef void (^DWQQRScannerResultType)(DWQQRScanner *scanner, AVMetadataMachineReadableCodeObject *codeObject);

@interface DWQQRScanner : NSObject

@property (nonatomic, readonly) BOOL isScanning;

- (void)startScanInView:(UIView *)view resultHandler:(DWQQRScannerResultType)resultHandler;
- (void)startScanInView:(UIView *)view machineReadableCodeObjects:(NSArray *)codeObjects resultHandler:(DWQQRScannerResultType)resultHandler;
- (void)stopScan;
- (void)resumeScan;


@end
