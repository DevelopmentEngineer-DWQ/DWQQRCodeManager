//
//  DWQQRImageHelper.m
//  二维码  DWQ_QRcode
//
//  Created by 杜文全 on 16/1/14.
//  Copyright © 2016年 com.sdzw.duwenquan. All rights reserved.
//

#import "DWQQRImageHelper.h"
@interface DWQQRImageHelper () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, copy) void (^completionHandler)(CIImage *image, NSString *decodeStr);
@end

@implementation DWQQRImageHelper
static DWQQRImageHelper *_imageHelper = nil;

// 根据字符串生成二维码
// 1. 导入CoreImage框架
// 2. 创建过滤器并设置属性
// 3. 设置内容
// 4. 获取输出文件
+ (UIImage *)generateImageWithStr:(NSString *)str size:(CGFloat)size {
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    if (str.length > 0) {
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [filter setValue:data forKey:@"inputMessage"];
        CIImage *ciImage = [filter outputImage];
        if (size == 0) {
            return [UIImage imageWithCIImage:ciImage];
        } else {
            return [self createNonInterpolatedUIImageFormCIImage:ciImage withSize:size];
        }
    }
    return nil;
}

/**
 * 根据CIImage生成指定大小的UIImage(否则生成的二维码图片可能不是很清晰，这里自己重绘图片)
 *
 * @param image CIImage
 * @param size 图片宽度
 */
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent          = CGRectIntegral(image.extent);
    CGFloat scale          = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1. 创建bitmap
    size_t width           = CGRectGetWidth(extent) * scale;
    size_t height          = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs     = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context     = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2. 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

// 解码图片
+ (void)getQRStrByPickImageWithController:(UIViewController *)controller completionHandler:(void (^)(CIImage *image, NSString *decodeStr))completionHandler {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        DWQQRImageHelper *helper  = [DWQQRImageHelper sharedImageHelper];
        helper.completionHandler = completionHandler;
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate                 = helper;
        imagePicker.allowsEditing            = YES;
        imagePicker.sourceType               = UIImagePickerControllerSourceTypePhotoLibrary;
        [controller presentViewController:imagePicker animated:YES completion:nil];
    }
}

+ (instancetype)sharedImageHelper {
    @synchronized(self) {
        if (_imageHelper == nil) {
            _imageHelper = [[DWQQRImageHelper alloc] init];
        }
    }
    return _imageHelper;
}

/**
 *  解码图片
 *
 *  @param ciImage 图片
 *  @return 根据image返回的相应二维码字符串内容
 */
+ (NSString *)decodeImage:(CIImage *)ciImage {
    NSDictionary *options = @{CIDetectorAccuracy : CIDetectorAccuracyHigh};
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:options];
    NSArray *features = [detector featuresInImage:ciImage];
    for (CIFeature *feature in features) {
        if ([feature isKindOfClass:[CIQRCodeFeature class]]) {
            CIQRCodeFeature *qrFeature = (CIQRCodeFeature *)feature;
            return qrFeature.messageString;
        }
    }
    return nil;
}

#pragma mark - <UIImagePickerControllerDelegate>
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:NO completion:^{
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        CIImage *ciImage = [[CIImage alloc] initWithCGImage:editedImage.CGImage options:nil];
        NSString *str = [DWQQRImageHelper decodeImage:ciImage]; // editedImage.CIImage 只有在UIImage是由CIImage提供时（比如它是由imageWithCIImage:生成的）， UIImage 的 CIImage才不会是空值         if (self.completionHandler) {
            self.completionHandler(ciImage, str);
        }
        _imageHelper = nil;
    }];
}

/**
 - (CIImage *)prepareRectangleDetector:(CIImage *)ciImage {
 NSDictionary *options = @{CIDetectorAccuracy : CIDetectorAccuracyHigh, CIDetectorAspectRatio : @1.0};
 CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:options];
 NSArray *features = [detector featuresInImage:ciImage];
 CIImage *resultImage;
 for (CIFeature *feature in features) {
 if ([feature isKindOfClass:[CIRectangleFeature class]]) {
 CIRectangleFeature *rectangleFeature = (CIRectangleFeature *)feature;
 resultImage = [self drawHighlightOverlayForImage:ciImage feature:rectangleFeature];
 }
 }
 return resultImage;
 }
 
 // This method creates a colored image, and then uses the perspective transform filter to map it to the points provided. It then creates a new CIImage by overlaying this colored image with the source image.
 - (CIImage *)drawHighlightOverlayForImage:(CIImage *)ciImage feature:(CIRectangleFeature *)feature {
 CIImage *overlay = [CIImage imageWithColor:[CIColor colorWithRed:1.0 green:0 blue:0 alpha:0.5]];
 overlay          = [overlay imageByCroppingToRect:[ciImage extent]];
 overlay          = [overlay imageByApplyingFilter:@"CIPerspectiveTransformWithExtent" withInputParameters:
 @{@"inputExtent"  : [CIVector vectorWithCGRect:[ciImage extent]],
 @"inputTopLeft" : [CIVector vectorWithCGPoint:feature.topLeft],
 @"inputTopRight" : [CIVector vectorWithCGPoint:feature.topRight],
 @"inputBottomLeft" : [CIVector vectorWithCGPoint:feature.bottomLeft],
 @"inputBottomRight" : [CIVector vectorWithCGPoint:feature.bottomRight]}];
 return [overlay imageByCompositingOverImage:ciImage];
 }
 
 - (void)drawHighlightOverlayForPoints:(CIImage *)image topLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight {
 
 }
 */

- (void)dealloc {
}

@end
