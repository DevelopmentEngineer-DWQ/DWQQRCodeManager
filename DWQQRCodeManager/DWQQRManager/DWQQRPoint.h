//
//  DWQQRPoint.h
//  二维码  DWQ_QRcode
//
//  Created by 杜文全 on 16/1/14.
//  Copyright © 2016年 com.sdzw.duwenquan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface DWQQRPoint : NSObject
@property (nonatomic) double x;
@property (nonatomic) double y;

- (CGPoint)cgPoint;
- (DWQQRPoint *)initWithCGPoint:(CGPoint)cgPoint;
+ (NSArray<DWQQRPoint *> *)pointsWithRect:(CGRect)rect;
+ (NSArray<DWQQRPoint *> *)pointsWithCorners:(NSArray *)points;
//+ (CGPoint *)cgPointsWithPoints:(NSArray<ZZQRPoint *> *)points;
//+ (NSArray<ZZQRPoint *> *)pointsWithCGPoints:(CGPoint *)cgPoints;

- (DWQQRPoint *)addPoint:(DWQQRPoint *)point;
@end
