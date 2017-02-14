//
//  DWQQRImageHelper.h
//  二维码  DWQ_QRcode
//
//  Created by 杜文全 on 16/1/14.
//  Copyright © 2016年 com.sdzw.duwenquan. All rights reserved..
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface DWQQRImageHelper : NSObject
/**
 *  根据字符串生成相应的二维码图片
 *
 *  @param str  字符串
 *  @param size 要生成的二维码图片的尺寸
 *
 *  @return 生成的二维码图片
 */
+ (UIImage *)generateImageWithStr:(NSString *)str size:(CGFloat)size;

/**
 *  从相册中选择图片并解码
 *
 *  @param controller        视图控制器
 *  @param completionHandler 选择好图片并解码后的block回调
 */
+ (void)getQRStrByPickImageWithController:(UIViewController *)controller completionHandler:(void (^)(CIImage *image, NSString *decodeStr))completionHandler;

/**
 *  解码图片
 *
 *  @param image 要解码的图片
 *
 *  @return 解码图片得到的字符串
 */
+ (NSString *)decodeImage:(CIImage *)image;

@end
