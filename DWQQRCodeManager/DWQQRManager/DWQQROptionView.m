//
//  DWQQROptionView.m
//  二维码  DWQ_QRcode
//
//  Created by 杜文全 on 16/1/14.
//  Copyright © 2016年 com.sdzw.duwenquan. All rights reserved.
//

#import "DWQQROptionView.h"

@interface DWQQROptionView ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@end

@implementation DWQQROptionView

+ (instancetype)optionViewWithFrame:(CGRect)frame {
    DWQQROptionView *optionView = [[DWQQROptionView alloc] initWithFrame:frame];
    CGFloat width    = 65.0;
    CGFloat yPadding = 6.0;
    CGFloat height   = frame.size.height - 2 * yPadding;
    CGFloat xPadding = 20.0f;
    
    // 相册
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    photoButton.frame = CGRectMake(xPadding, yPadding, width, height);
    [photoButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_photo_nor.png"] forState:UIControlStateNormal];
    [photoButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_photo_down.png"] forState:UIControlStateHighlighted];
    [photoButton addTarget:optionView action:@selector(photoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [optionView addSubview:photoButton];
    
    // 开灯
    UIButton *lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lightButton.frame     = CGRectMake(0, 0, width, height);
    lightButton.center    = CGPointMake(frame.size.width/2.0, frame.size.height/2.0);
    [lightButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_nor.png"] forState:UIControlStateNormal];
    [lightButton setImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_down.png"] forState:UIControlStateSelected];
    [lightButton addTarget:optionView action:@selector(lightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [optionView addSubview:lightButton];
    
    // 取消
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelButton.frame = CGRectMake(frame.size.width - yPadding - width, yPadding, width, height);
    [cancelButton setTitleColor:[UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1.0] forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:optionView action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [optionView addSubview:cancelButton];
    
    return optionView;
}

- (void)photoButtonClick:(UIButton *)button {
    [self buttonClick:0];
}

- (void)lightButtonClick:(UIButton *)button {
    [self buttonClick:1];
}

- (void)cancelButtonClick:(UIButton *)button {
    [self buttonClick:2];
}

- (void)buttonClick:(NSInteger)index {
    if (self.callbackHandler) {
        self.callbackHandler(index);
    }
}


@end
