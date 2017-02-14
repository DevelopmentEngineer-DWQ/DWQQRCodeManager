//
//  DWQQROptionView.h
//  二维码  DWQ_QRcode
//
//  Created by 杜文全 on 16/1/14.
//  Copyright © 2016年 com.sdzw.duwenquan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWQQROptionView : UIView
@property (nonatomic, copy) void (^callbackHandler)(NSInteger index);

+ (instancetype)optionViewWithFrame:(CGRect)frame;
@end
