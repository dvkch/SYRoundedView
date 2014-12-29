//
//  SYRoundedView.h
//  SYRoundedViewExample
//
//  Created by rominet on 07/12/14.
//  Copyright (c) 2014 Syan.me. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SYCornerNone        = 0,
    SYCornerTopLeft     = UIRectCornerTopLeft,
    SYCornerTopRight    = UIRectCornerTopRight,
    SYCornerBottomLeft  = UIRectCornerBottomLeft,
    SYCornerBottomRight = UIRectCornerBottomRight,
    SYCornerAll         = UIRectCornerAllCorners,
} SYCorner;

typedef enum: NSUInteger {
    SYBorderNone   = 0,
    SYBorderTop    = 1L << 0,
    SYBorderLeft   = 1L << 1,
    SYBorderRight  = 1L << 2,
    SYBorderBottom = 1L << 3,
    SYBorderAll = SYBorderTop|SYBorderLeft|SYBorderRight|SYBorderBottom,
} SYBorder;

@interface SYRoundedView : UIView
@property (nonatomic, assign) SYCorner maskCorners;
@property (nonatomic, assign) SYCorner drawnCorners;
@property (nonatomic, assign) SYBorder drawnBorders;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) BOOL animatePaths;
#warning animate paths option

- (UIBezierPath *)maskPath;
- (UIBezierPath *)drawnPath;

- (void)animateWithDuration:(NSTimeInterval)duration
                      curve:(UIViewAnimationCurve)curve
                 animations:(void(^)(void))animations
                 completion:(void(^)(void))completion;

- (void)applyChangesInASingleCommit:(void(^)(void))block;

- (void)animateStrokeFrom:(CGFloat)from
                       to:(CGFloat)to
                 duration:(NSTimeInterval)duration
              strokeStart:(BOOL)strokeStart
                  reverse:(BOOL)reverse
                maxRepeat:(NSUInteger)maxRepeat
  removePreviousAnimation:(BOOL)removePreviousAnimation;

@end
