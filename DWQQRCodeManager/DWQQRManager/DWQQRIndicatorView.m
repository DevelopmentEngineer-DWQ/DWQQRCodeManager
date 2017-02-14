//
//  DWQQRIndicatorView.m
//  二维码  DWQ_QRcode
//
//  Created by 杜文全 on 16/1/14.
//  Copyright © 2016年 com.sdzw.duwenquan. All rights reserved.
//

#import "DWQQRIndicatorView.h"
#define FPS 60
@interface DWQQRIndicatorView ()

/**
 *  刷新屏幕, FPS: 60
 */
@property (nonatomic) CADisplayLink *link;

/**
 *  步进量数组
 */
@property (nonatomic) NSMutableArray *stepPoints;

/**
 *  临界值
 */
@property (nonatomic) double criticalValue;

/**
 *  步进量总值，如果步进量超过临界值，停止
 */
@property (nonatomic) double stepTotalValue;

/**
 *  动画视图，不断的扩大和缩小
 */
@property (nonatomic) UIView *animationView;

@property (nonatomic) NSArray<DWQQRPoint *> *fromPoints;
@property (nonatomic) NSArray<DWQQRPoint *> *toPoints;
@property (nonatomic, copy) void (^lockInCompletion)(NSString *str);
@end

@implementation DWQQRIndicatorView

- (double)duration {
    if (!_duration) {
        _duration = 0.25;
    }
    return _duration;
}

// Only override drawRect: if you perform custom drawing.
- (void)drawRect:(CGRect)rect {
    if (self.fromPoints == nil || self.fromPoints.count != self.toPoints.count) {
        return;
    }
    NSUInteger count = self.fromPoints.count;
    CGPoint cgPointArr[count];
    for (NSUInteger i = 0; i < count; i++) {
        DWQQRPoint *stepPoint = self.stepPoints[i];
        if (i == 0) {
            self.stepTotalValue += fabs(stepPoint.x);
        }
        cgPointArr[i] = [[self.fromPoints[i] addPoint:stepPoint] cgPoint];
        // NSLog(@"%lf %lf", cgPointArr[i].x, cgPointArr[i].y);
    }
    
    CGContextRef ctf = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctf, [[UIColor whiteColor] CGColor]);
    CGContextSetLineWidth(ctf, 2.0);
    CGContextAddLines(ctf, cgPointArr, count);
    CGContextClosePath(ctf);
    CGContextStrokePath(ctf);
    
    if (self.stepTotalValue >=  self.criticalValue) {
        // self.link.paused = YES;
        [self.link invalidate];
        [self performSelector:@selector(callback) withObject:nil afterDelay:.75];
    }
}

- (void)callback {
    if (self.lockInCompletion) {
        self.lockInCompletion([self.codeObject stringValue]);
    }
}

/**
 *  开始动画－－搜索
 */
- (void)indicateStart {
    CGFloat length            = self.bounds.size.width / 2;
    self.animationView        = [[DWQQRIndicatorView alloc] initWithFrame:CGRectMake(0, 0, length, length)];
    self.animationView.backgroundColor = [UIColor clearColor];
    self.animationView.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
    self.animationView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.animationView.layer.borderWidth = 1.0;
    [self addSubview:self.animationView];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.duration     = 1.48;
    scaleAnimation.fromValue    = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
    scaleAnimation.toValue      = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 0.5, 1.0)];
    // scaleAnimation.delegate  = self;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.repeatCount  = MAXFLOAT;
    [self.animationView.layer addAnimation:scaleAnimation forKey:@"ScaleAnimationKey"];
}

- (void)indicateEnd {
    [self.animationView removeFromSuperview];
    // [self.animationView.layer removeAnimationForKey:@"ScaleAnimationKey"];
}

/**
 *  锁定目标，在二维码的周边画线
 *  扫描二维码后得到的四个角的点有可能不是一个矩形，而是一个有四条边的不规则图形
 *  AVMetadataMachineReadableCodeObject对象的corners属性是个数组，它包含了这4个点的具体坐标，我们根据这4个点的坐标把这个不规则图形画出来，这4个点的顺序如下：
 ⚫️1-------------4⚫️
 \                |
 \               |
 \              |
 \             |
 ⚫️2----------3⚫️
 */
- (void)indicateLockInWithCompletion:(void (^)(NSString *str))completion {
    self.lockInCompletion = completion;
    
    self.fromPoints = [DWQQRPoint pointsWithRect:self.animationView.frame];
    [self.animationView removeFromSuperview];
    self.toPoints = [DWQQRPoint pointsWithCorners:self.codeObject.corners];
    
    // 取临界值
    self.criticalValue = fabs(self.toPoints[0].x - self.fromPoints[0].x);
    NSInteger count = self.fromPoints.count;
    if (count != self.toPoints.count) {
        @throw [NSException exceptionWithName:NSStringFromSelector(_cmd) reason:@"起始点和终点个数不匹配" userInfo:nil];
    }
    self.stepPoints = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        DWQQRPoint *fromPoint = self.fromPoints[i];
        DWQQRPoint *toPoint   = self.toPoints[i];
        // 1秒60次刷新 FPS: 60
        CGPoint cgPoint      = CGPointMake((toPoint.x - fromPoint.x)/(self.duration*FPS), (toPoint.y - fromPoint.y)/(self.duration*FPS));
        DWQQRPoint *stepPoint = [[DWQQRPoint alloc] initWithCGPoint:cgPoint];// 步进量
        self.stepPoints[i]   = stepPoint;
    }
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

#pragma mark - animation delegate
/**
 - (void)animationDidStop:(CAAnimation*)anim finished:(BOOL)flag {
 if ([anim isKindOfClass:[CABasicAnimation class]]) {
 CABasicAnimation *animation = (CABasicAnimation *)anim;
 if ([animation.keyPath isEqualToString:@"bounds"] && self.resultHandler) {
 // self.resultHandler(self, self.result);
 }
 }
 
 // [self.layer removeAnimationForKey:@"ScaleAnimationKey"];  // 这会导致 _view1回到原来的位置
 // CAAnimation *animation = [self.layer animationForKey:@"my_key"];
 // NSLog(@"stop animation: %@", NSStringFromCGPoint(_placeholderView.layer.position));
 }
 
 - (void)animationDidStart:(CAAnimation*)anim {
 // NSLog(@"start animation...");
 }
 */

- (void)dealloc {
    // NSLog(@"%s", __func__);
}


@end
