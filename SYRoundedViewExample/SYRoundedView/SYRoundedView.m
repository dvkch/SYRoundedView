//
//  SYRoundedView.m
//  SYRoundedViewExample
//
//  Created by rominet on 07/12/14.
//  Copyright (c) 2014 Syan.me. All rights reserved.
//

#import "SYRoundedView.h"

#define DEBUG_MASK 0

@interface SYShapeLayer : CAShapeLayer
@property (nonatomic, assign) CGPathRef currentPath;
@property (nonatomic, assign) CGPathRef previousPath;
@property (nonatomic, assign) CGFloat currentLineWidth;
@property (nonatomic, assign) CGFloat previousLineWidth;
@property (nonatomic, assign) CGColorRef currentStrokeColor;
@property (nonatomic, assign) CGColorRef previousStrokeColor;
@end

@interface UIBezierPath (Syan)
- (void)moveToPointIfNeeded:(CGPoint)point;
- (void)addClockwiseCorner:(SYCorner)corner fromPoint:(CGPoint)from toPoint:(CGPoint)to;
@end

@interface SYRoundedView ()
@property (nonatomic, readonly) SYShapeLayer *shapeLayer;
@property (nonatomic, readonly) SYShapeLayer *maskLayer;
@property (nonatomic, assign) CGRect previousBounds;
@property (nonatomic, assign) BOOL inhibitAutoPathUpdates;
@end

@implementation SYRoundedView

+ (Class)layerClass {
    return [SYShapeLayer class];
}

- (SYShapeLayer *)shapeLayer {
    return (SYShapeLayer *)self.layer;
}

- (instancetype)init {
    self = [super init];
    if(self) { [self setup]; }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) { [self setup]; }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) { [self setup]; }
    return self;
}

- (void)setup {
    if(self.maskLayer)
        return;
    
    _maskLayer = [[SYShapeLayer alloc] init];
    self.maskLayer.frame = self.shapeLayer.bounds;
    self.maskLayer.fillColor = [UIColor blackColor].CGColor;
    self.maskLayer.strokeColor = [UIColor blackColor].CGColor;
    
    self.shapeLayer.lineWidth = 1;
    self.shapeLayer.strokeColor = [UIColor blueColor].CGColor;
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
    
#if DEBUG_MASK
    [self.shapeLayer addSublayer:self.maskLayer];
#endif
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if(CGRectEqualToRect(self.bounds, self.previousBounds))
        return;
    
    self.maskLayer.position = [self.superview convertPoint:self.center toView:self];
    self.maskLayer.bounds = self.shapeLayer.bounds;
    
    if(!self.inhibitAutoPathUpdates)
    {
        [self updateMaskPath];
        [self updateDrawnPath];
    }
}

- (void)setDrawnBorders:(SYBorder)drawnBorders {
    if(self.drawnBorders == drawnBorders)
        return;
    
    self->_drawnBorders = drawnBorders;

    if(!self.inhibitAutoPathUpdates)
        [self updateDrawnPath];
}

- (void)setDrawnCorners:(SYCorner)drawnCorners {
    if(self.drawnCorners == drawnCorners)
        return;
    
    self->_drawnCorners = drawnCorners;

    if(!self.inhibitAutoPathUpdates)
        [self updateDrawnPath];
}

- (void)setMaskCorners:(SYCorner)maskCorners {
    if(self.maskCorners == maskCorners)
        return;
    
    self->_maskCorners = maskCorners;
#if !DEBUG_MASK
    if(maskCorners == SYCornerNone && self.shapeLayer.mask != nil)
        self.shapeLayer.mask = nil;
    
    if(maskCorners != SYCornerNone && self.shapeLayer.mask == nil)
        self.shapeLayer.mask = self.maskLayer;
#endif
    if(!self.inhibitAutoPathUpdates)
        [self updateMaskPath];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if(self.cornerRadius == cornerRadius)
        return;
    
    self->_cornerRadius = cornerRadius;

    if(!self.inhibitAutoPathUpdates)
    {
        [self updateMaskPath];
        [self updateDrawnPath];
    }
}

- (void)setBorderColor:(UIColor *)borderColor {
    if([self.borderColor isEqual:borderColor])
        return;
    
    self->_borderColor = borderColor;
    self.shapeLayer.strokeColor = borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    if(self.borderWidth == borderWidth)
        return;
    
    self->_borderWidth = borderWidth;
    self.maskLayer.currentLineWidth = borderWidth;
    self.shapeLayer.currentLineWidth = borderWidth;
}

- (UIBezierPath *)createBezierPathWithCorners:(SYCorner)corners borders:(SYBorder)borders closePath:(BOOL)closePath
{
    CGFloat radiusTopLeft     = corners & SYCornerTopLeft     ? self.cornerRadius : CGFLOAT_MIN;
    CGFloat radiusTopRight    = corners & SYCornerTopRight    ? self.cornerRadius : CGFLOAT_MIN;
    CGFloat radiusBottomLeft  = corners & SYCornerBottomLeft  ? self.cornerRadius : CGFLOAT_MIN;
    CGFloat radiusBottomRight = corners & SYCornerBottomRight ? self.cornerRadius : CGFLOAT_MIN;
    
    CGPoint pointT1 = CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds));
    CGPoint pointTM = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds));
    CGPoint pointT2 = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds));
    CGPoint pointB1 = CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds));
    CGPoint pointB2 = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds));
    CGPoint pointL1 = pointT1;
    CGPoint pointL2 = pointB1;
    CGPoint pointR1 = pointT2;
    CGPoint pointR2 = pointB2;
    
    pointT1.x += radiusTopLeft;
    pointL1.y += radiusTopLeft;

    pointT2.x -= radiusTopRight;
    pointR1.y += radiusTopRight;
    
    pointB1.x += radiusBottomLeft;
    pointL2.y -= radiusBottomLeft;
    
    pointB2.x -= radiusBottomRight;
    pointR2.y -= radiusBottomRight;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointTM];
    
    if(borders & SYBorderTop) {
        [path moveToPointIfNeeded:pointTM];
        [path addLineToPoint:pointT2];
    }
    
    // addArc is ignored for small radii, making the number of segment and control points
    // different from a path to another, leading to weird animations
    [path addClockwiseCorner:SYCornerTopRight fromPoint:pointT2 toPoint:pointR1];
    
    if(borders & SYBorderRight) {
        [path moveToPointIfNeeded:pointR1];
        [path addLineToPoint:pointR2];
    }
    
    [path addClockwiseCorner:SYCornerBottomRight fromPoint:pointR2 toPoint:pointB2];
    
    if(borders & SYBorderBottom) {
        [path moveToPointIfNeeded:pointB2];
        [path addLineToPoint:pointB1];
    }
    
    [path addClockwiseCorner:SYCornerBottomLeft fromPoint:pointB1 toPoint:pointL2];
    
    if(borders & SYBorderLeft) {
        [path moveToPointIfNeeded:pointL2];
        [path addLineToPoint:pointL1];
    }
    
    [path addClockwiseCorner:SYCornerTopLeft fromPoint:pointL1 toPoint:pointT1];
    
    if(borders & SYBorderTop) {
        [path moveToPointIfNeeded:pointT1];
        [path addLineToPoint:pointTM];
    }
    
    if(closePath) {
        [path closePath];
    }
    
    return path;
}

- (void)updateMaskPath {
    self.maskLayer.currentPath = [self createBezierPathWithCorners:self.maskCorners borders:SYBorderAll closePath:YES].CGPath;
}

- (void)updateDrawnPath {
    self.shapeLayer.currentPath = [self createBezierPathWithCorners:self.drawnCorners borders:self.drawnBorders closePath:NO].CGPath;
}

- (UIBezierPath *)maskPath {
    return [self createBezierPathWithCorners:self.maskCorners borders:SYBorderAll closePath:YES];
}

- (UIBezierPath *)drawnPath {
    return [self createBezierPathWithCorners:self.drawnCorners borders:self.drawnBorders closePath:NO];
}

- (void)animateStrokeFrom:(CGFloat)from
                       to:(CGFloat)to
                 duration:(NSTimeInterval)duration
              strokeStart:(BOOL)strokeStart
                  reverse:(BOOL)reverse
                maxRepeat:(NSUInteger)maxRepeat
  removePreviousAnimation:(BOOL)removePreviousAnimation
{
    NSString *keyPath = (strokeStart ? @"strokeStart" : @"strokeEnd");
    NSString *animationName = [NSString stringWithFormat:@"SYRoundedView-%@", keyPath];
    if(removePreviousAnimation)
        [self.shapeLayer removeAnimationForKey:animationName];
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:keyPath];
    anim.fromValue      = @(from);
    anim.toValue        = @(to);
    anim.duration       = duration;
    anim.repeatCount    = HUGE_VALF;
    anim.repeatDuration = maxRepeat * duration;
    anim.autoreverses   = reverse;
    [self.shapeLayer addAnimation:anim forKey:animationName];
}

- (void)animateWithDuration:(NSTimeInterval)duration
                      curve:(UIViewAnimationCurve)curve
                 animations:(void (^)(void))animations
                 completion:(void (^)(void))completion
{
    if(!animations)
        return;
    
    NSString *timing = nil;
    UIViewAnimationOptions option;
    
    switch (curve) {
        case UIViewAnimationCurveEaseIn:
            timing = kCAMediaTimingFunctionEaseIn;
            option = UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseInOut:
            timing = kCAMediaTimingFunctionEaseInEaseOut;
            option = UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseOut:
            timing = kCAMediaTimingFunctionEaseOut;
            option = UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            timing = kCAMediaTimingFunctionLinear;
            option = UIViewAnimationOptionCurveLinear;
            break;
    }
    
    [UIView animateWithDuration:duration delay:0 options:option animations:^{
        [CATransaction begin];
        [CATransaction setAnimationDuration:duration];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:timing]];
        self.inhibitAutoPathUpdates = YES;
        animations();
        [self updateDrawnPath];
        [self updateMaskPath];
        self.inhibitAutoPathUpdates = NO;
        [CATransaction commit];
    } completion:^(BOOL finished) {
        if(completion)
            completion();
    }];
}

@end

@implementation UIBezierPath (Syan)

- (void)moveToPointIfNeeded:(CGPoint)point {
    if(fabs(self.currentPoint.x - point.x) <= 2 * CGFLOAT_MIN &&
       fabs(self.currentPoint.y - point.y) <= 2 * CGFLOAT_MIN)
        return;
    [self moveToPoint:point];
}

- (void)addClockwiseCorner:(SYCorner)corner fromPoint:(CGPoint)from toPoint:(CGPoint)to {
    CGPoint controlPoint1;
    CGPoint controlPoint2;
    
    switch (corner) {
        case SYCornerBottomLeft:
        case SYCornerTopRight:
            controlPoint1 = CGPointMake(from.x + (to.x - from.x) * 0.555, from.y);
            controlPoint2 = CGPointMake(to.x, to.y + (from.y - to.y) * 0.555);
            break;
        case SYCornerBottomRight:
        case SYCornerTopLeft:
            controlPoint1 = CGPointMake(from.x, from.y + (to.y - from.y) * 0.555);
            controlPoint2 = CGPointMake(to.x + (from.x - to.x) * 0.555, to.y);
            break;
        default:
            break;
    }
    
    [self moveToPointIfNeeded:from];
    [self addCurveToPoint:to controlPoint1:controlPoint1 controlPoint2:controlPoint2];
}

@end

@implementation SYShapeLayer

- (void)setCurrentPath:(CGPathRef)currentPath {
    self.previousPath = self.path;
    self->_currentPath = currentPath;
    [self setPath:currentPath];
}

- (void)setCurrentLineWidth:(CGFloat)currentLineWidth {
    self.previousLineWidth = self.lineWidth;
    self->_currentLineWidth = currentLineWidth;
    [self setLineWidth:currentLineWidth];
}

- (void)setCurrentStrokeColor:(CGColorRef)currentStrokeColor {
    self.previousStrokeColor = self.strokeColor;
    self->_currentStrokeColor = currentStrokeColor;
    [self setStrokeColor:currentStrokeColor];
}

- (id<CAAction>)actionForKey:(NSString *)event {
    if([event isEqualToString:@"path"]) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:event];
        anim.fromValue = (__bridge id)(self.previousPath);
        anim.toValue   = (__bridge id)(self.currentPath);
        return anim;
    }
    if([event isEqualToString:@"lineWidth"]) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:event];
        anim.fromValue = @(self.previousLineWidth);
        anim.toValue   = @(self.currentLineWidth);
        return anim;
    }
    if([event isEqualToString:@"strokeColor"]) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:event];
        anim.fromValue = (__bridge id)(self.previousStrokeColor);
        anim.toValue   = (__bridge id)(self.currentStrokeColor);
        return anim;
    }
    return [super actionForKey:event];
}

@end

