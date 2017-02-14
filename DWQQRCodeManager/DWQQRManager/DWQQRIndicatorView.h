//
//  DWQQRIndicatorView.h
//  二维码  DWQ_QRcode
//
//  Created by 杜文全 on 16/1/14.
//  Copyright © 2016年 com.sdzw.duwenquan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DWQQRPoint.h"
@interface DWQQRIndicatorView : UIView
@property (nonatomic) AVMetadataMachineReadableCodeObject *codeObject;
@property (nonatomic) double duration;

/**
 *  开始动画－－搜索
 */
- (void)indicateStart;

/**
 *  结束动画－－搜索
 */
- (void)indicateEnd;

/**
 *  锁定目标，在二维码的周边画线
 */
- (void)indicateLockInWithCompletion:(void (^)(NSString *str))completion;
@end
