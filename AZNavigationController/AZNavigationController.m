//
//  AZNavigationController.m
//  AZNavigation
//
//  Created by Alvin on 13-10-8.
//  Copyright (c) 2013 Alvin Zhu. All rights reserved.
//

#import "AZNavigationController.h"
#import <QuartzCore/QuartzCore.h>

#define KEY_WINDOW [[UIApplication sharedApplication] keyWindow]

@interface AZNavigationController () {
    CGPoint     startPoint;
    
    UIImageView *lastScreenShotView;
    
    // zoom used
    UIView      *blackMask;
}

@property (nonatomic, strong) UIView            *backgroundView;
@property (nonatomic, strong) NSMutableArray    *screenShotsList;
@property (nonatomic, assign) BOOL              isMoving;

@end

@implementation AZNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.screenShotsList = [[NSMutableArray alloc] initWithCapacity:2];
        self.canDragBack = YES;
        self.navigationType = AZNavigationZoom;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImageView *imgLeftSideShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leftside_shadow_bg"]];
    CGFloat shadowWidth = 10;
    imgLeftSideShadow.frame = CGRectMake(-shadowWidth, 0, shadowWidth, self.view.frame.size.height);
    [self.view addSubview:imgLeftSideShadow];
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    recognizer.delaysTouchesBegan = YES;
    [self.view addGestureRecognizer:recognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - overwrite methods

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.screenShotsList addObject:[self capture]];
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    [self.screenShotsList removeLastObject];
    
    return [super popViewControllerAnimated:animated];
}

#pragma mark - handle methods

// get the current view screen shot
- (UIImage *)capture {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, [[UIScreen mainScreen] scale]);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)moveCurrentViewToX:(CGFloat)x {
    if (x > 2) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StartToMove" object:nil];
    }
    x = x > 320 ? 320 : x;
    if (x < - 50) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PopUp" object:nil];
        return;
    }
    x = x < 0 ? 0 :x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    if (self.navigationType == AZNavigationZoom) {
        
        CGFloat scale = (x / 3200) + 0.9;
        CGFloat alpha = 0.4 - (x / 800);
        lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
        blackMask.alpha = alpha;
    } else {
        
        blackMask.alpha = 0;
        frame = lastScreenShotView.frame;
        frame.origin.x = (x - self.view.bounds.size.width) / 2;
        lastScreenShotView.frame = frame;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    // if the viewControllers has only one vc or disable the interaction, then return
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    
    // get the touch position from the window's coordinate
    CGPoint touchPoint = [recognizer locationInView:KEY_WINDOW];
    
    // begin paning, show the backgrounview(last screenshot), if not exist, create it
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        _isMoving = YES;
        startPoint = touchPoint;
        
        if (!self.backgroundView) {
            CGRect frame = self.view.frame;
            
            self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            blackMask.backgroundColor = [UIColor blackColor];
            [self.backgroundView addSubview:blackMask];
        }
        
        self.backgroundView.hidden = NO;
        
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        
        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        lastScreenShotView = [[UIImageView alloc] initWithImage:lastScreenShot];
        [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
        
    // end paning, always check that if it should move right or move left automatically
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        if (touchPoint.x - startPoint.x > 50) {
            
            [UIView animateWithDuration:0.3 animations:^{
                [self moveCurrentViewToX:self.view.bounds.size.width];
            } completion:^(BOOL finished) {
                if (finished) {
                    [self popViewControllerAnimated:NO];
                    CGRect frame = self.view.frame;
                    frame.origin.x = 0;
                    self.view.frame = frame;
                    
                    _isMoving = NO;
                }
            }];
        } else {
            
            [UIView animateWithDuration:0.3 animations:^{
                [self moveCurrentViewToX:0];
            }completion:^(BOOL finished){
                if (finished) {
                    _isMoving = NO;
                    self.backgroundView.hidden = YES;
                }
            }];
        }
        return;
    
    // cancel panning, always move to left side automatically
    } else if (recognizer.state == UIGestureRecognizerStateCancelled) {
        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveCurrentViewToX:0];
        }completion:^(BOOL finished){
            if (finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }
        }];
        return;
    }
    
    // keeps move with touch
    if (_isMoving) {
        [self moveCurrentViewToX:touchPoint.x - startPoint.x];
    }
}

@end
