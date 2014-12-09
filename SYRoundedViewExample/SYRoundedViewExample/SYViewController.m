//
//  SYViewController.m
//  SYRoundedViewExample
//
//  Created by rominet on 07/12/14.
//  Copyright (c) 2014 Syan.me. All rights reserved.
//

#import "SYViewController.h"
#import "SYRoundedView.h"

@interface SYViewController ()
@property (nonatomic, strong) SYRoundedView *roundedView;
@end

@implementation SYViewController

- (void)loadView {
    [super loadView];
    
    self.roundedView = [[SYRoundedView alloc] initWithFrame:CGRectZero];
    self.roundedView.backgroundColor = [UIColor lightGrayColor];
    self.roundedView.maskCorners  = SYCornerNone;
    self.roundedView.drawnCorners = SYCornerNone;
    self.roundedView.drawnBorders = SYBorderNone;
    self.roundedView.borderWidth  = 2;
    self.roundedView.borderColor  = [UIColor redColor];
    self.roundedView.cornerRadius = 30;
    [self.view addSubview:self.roundedView];
    
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animateStyle];
}

- (void)applyStaticStyle {
    self.roundedView.borderWidth  = 10;
    self.roundedView.borderColor  = [UIColor redColor];
    self.roundedView.cornerRadius = 30;
    self.roundedView.drawnBorders = SYBorderAll;
    self.roundedView.drawnCorners = SYCornerBottomLeft | SYCornerTopLeft;
    self.roundedView.maskCorners  = SYCornerBottomLeft | SYCornerTopLeft;
    self.roundedView.frame        = CGRectInset(self.view.bounds, 30, 30);
    
    [self.roundedView animateStrokeFrom:0 to:1 duration:2 strokeStart:YES reverse:NO maxRepeat:2 removePreviousAnimation:YES];
}

- (void)animateStyle {
    CGRect frame = CGRectInset(self.view.bounds, 40, 40);
    
    frame.origin.x += arc4random() % 50;
    frame.origin.y += arc4random() % 50;
    frame.size.width  -= arc4random() % 100;
    frame.size.height -= arc4random() % 100;
    
    SYCorner corners = SYCornerNone;
    if(arc4random() % 2) corners |= SYCornerTopLeft;
    if(arc4random() % 2) corners |= SYCornerTopRight;
    if(arc4random() % 2) corners |= SYCornerBottomLeft;
    if(arc4random() % 2) corners |= SYCornerBottomRight;
    
    [self.roundedView animateWithDuration:1 curve:UIViewAnimationCurveEaseInOut animations:^{
        self.roundedView.borderWidth  = arc4random() % 30;
        self.roundedView.borderColor  = arc4random() % 2 ? [UIColor redColor] : [UIColor blueColor];
        self.roundedView.cornerRadius = arc4random() % 30;
        self.roundedView.drawnBorders = SYBorderAll;
        self.roundedView.drawnCorners = corners;
        self.roundedView.maskCorners  = corners;
        [self.roundedView setFrame:CGRectInset(self.view.bounds, 30, 30)];
    } completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animateStyle];
    });
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.roundedView animateWithDuration:duration curve:UIViewAnimationCurveEaseInOut animations:^{
        [self.roundedView setFrame:CGRectInset([self boundsForOrientation:toInterfaceOrientation], 40, 40)];
    } completion:nil];
}

- (CGRect)boundsForOrientation:(UIInterfaceOrientation)orientation {
    UIScreen *screen = [UIScreen mainScreen];
    CGRect bounds = screen.bounds;
    
    if ([screen respondsToSelector:@selector(fixedCoordinateSpace)]) {
        bounds = [screen.coordinateSpace convertRect:bounds toCoordinateSpace:screen.fixedCoordinateSpace];
    }
    
    if(UIInterfaceOrientationIsLandscape(orientation))
        bounds.size = CGSizeMake(bounds.size.height, bounds.size.width);
    
    return bounds;
}


@end
