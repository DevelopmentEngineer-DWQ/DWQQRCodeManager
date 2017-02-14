//
//  DWQQRScanViewController.h
//  二维码  DWQ_QRcode
//
//  Created by 杜文全 on 16/1/14.
//  Copyright © 2016年 com.sdzw.duwenquan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWQQRScanViewController;

@interface DWQQRScanViewController : UIViewController
@property (nonatomic, copy) void (^resultHandler)(DWQQRScanViewController *controller, NSString *result);
- (void)setResultHandler:(void (^)(DWQQRScanViewController *controller, NSString *result))resultHandler;
@end
