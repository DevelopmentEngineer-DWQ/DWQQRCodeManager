//
//  DWQQRPoint.m
//  二维码  DWQ_QRcode
//
//  Created by 杜文全 on 16/1/14.
//  Copyright © 2016年 com.sdzw.duwenquan. All rights reserved.
//

#import "DWQQRPoint.h"

@implementation DWQQRPoint
- (CGPoint)cgPoint {
    return CGPointMake(self.x, self.y);
}

- (DWQQRPoint *)initWithCGPoint:(CGPoint)cgPoint {
    if (self = [super init]) {
        self.x = cgPoint.x;
        self.y = cgPoint.y;
    }
    return self;
}

+ (NSArray<DWQQRPoint *> *)pointsWithRect:(CGRect)rect {
    DWQQRPoint *point_1  = [[DWQQRPoint alloc] initWithCGPoint:rect.origin];
    DWQQRPoint *point_2  = [[DWQQRPoint alloc] initWithCGPoint:CGPointMake(rect.origin.x, CGRectGetMaxY(rect))];
    DWQQRPoint *point_3  = [[DWQQRPoint alloc] initWithCGPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))];
    DWQQRPoint *point_4  = [[DWQQRPoint alloc] initWithCGPoint:CGPointMake(CGRectGetMaxX(rect), rect.origin.y)];
    return @[point_1, point_2, point_3, point_4];
}

+ (NSArray<DWQQRPoint *> *)pointsWithCorners:(NSArray *)points {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:points.count];
    for (id obj in points) {
        CGPoint p;
        CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)obj, &p);
        DWQQRPoint *point = [[DWQQRPoint alloc] initWithCGPoint:p];
        [arr addObject:point];
    }
    return arr;
}

- (DWQQRPoint *)addPoint:(DWQQRPoint *)point {
    self.x += point.x;
    self.y += point.y;
    return self;
}

@end
