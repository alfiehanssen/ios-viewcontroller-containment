//
//  ContainerViewController.m
//  Pager
//
//  Created by Alfie Hanssen on 9/17/13.
//  Copyright (c) 2016 Alfie Hanssen. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "ContainerViewController.h"
#import "PanGestureRecognizer.h"

static const CGFloat ParallaxScalar = 0.5f;
static const CGFloat TransitionDuration = 0.2f;
static const CGFloat PanCompletionThreshold = 0.5f;
static const CGFloat VelocityThreshold = 500.0f;

typedef NS_ENUM(NSInteger, ContainerViewControllerMode)
{
    ContainerViewControllerModeNone,
    ContainerViewControllerModeStatic,
    ContainerViewControllerModeDynamic
};

@interface ContainerViewController ()

@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, assign) ContainerViewControllerMode mode;

@end

@implementation ContainerViewController

- (void)dealloc
{
    _datasource = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _mode = ContainerViewControllerModeNone;
        _parallaxEnabled = YES;
        _wrappingEnabled = NO;
        _viewControllers = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PanGestureRecognizer * pan = [[PanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.maximumNumberOfTouches = 1;
    pan.minimumNumberOfTouches = 1;
    [self.view addGestureRecognizer:pan];

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
}

#pragma mark - Setup

- (void)setViewControllers:(NSMutableArray *)viewControllers
{
    NSAssert(viewControllers != nil, @"viewControllers argument must be non nil");
    
    _viewControllers = [viewControllers mutableCopy];
    
    self.mode = ContainerViewControllerModeStatic;
    
    UIViewController *viewController = viewControllers[0];
    viewController.view.frame = self.view.bounds;
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    self.currentViewController = viewController;
}

- (void)setInitialViewController:(UIViewController *)viewController
{
    NSAssert(viewController != nil, @"viewController argument must be non nil");
    
    self.mode = ContainerViewControllerModeDynamic;
    
    viewController.view.frame = self.view.bounds;
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    self.currentViewController = viewController;
    [self.viewControllers addObject:self.currentViewController];
}

#pragma mark - Tap Navigation

- (void)tap:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.view];
    if (location.x < self.view.bounds.size.width / 2)
    {
        [self transitionToPrevious];
    }
    else
    {
        [self transitionToNext];
    }
}

- (void)transitionToPrevious
{
    UIViewController * previous = [self previousViewController];
    if (previous)
    {
        previous.view.frame = [self frameForDirection:PanDirectionBack obeyParallax:NO];
        [self addChildViewController:previous];
        [self.currentViewController willMoveToParentViewController:nil];
        
        __weak ContainerViewController * weakSelf = self;
        [self transitionFromViewController:self.currentViewController toViewController:previous duration:TransitionDuration options:0 animations:^{
            
            CGRect oldFrame = [weakSelf frameForDirection:PanDirectionForward obeyParallax:YES];
            weakSelf.currentViewController.view.frame = oldFrame;
            previous.view.frame = weakSelf.view.bounds;
            
        } completion:^(BOOL finished) {
            
            [previous didMoveToParentViewController:weakSelf];
            [weakSelf.currentViewController removeFromParentViewController];
            weakSelf.currentViewController = previous;
            
        }];
    }
}

- (void)transitionToNext
{
    UIViewController *next = [self nextViewController];
    if (next)
    {
        next.view.frame = [self frameForDirection:PanDirectionForward obeyParallax:NO];
        [self addChildViewController:next];
        [self.currentViewController willMoveToParentViewController:nil];
        
        __weak ContainerViewController * weakSelf = self;
        [self transitionFromViewController:self.currentViewController toViewController:next duration:TransitionDuration options:0 animations:^{
            
            CGRect oldFrame = [weakSelf frameForDirection:PanDirectionBack obeyParallax:YES];
            weakSelf.currentViewController.view.frame = oldFrame;
            next.view.frame = weakSelf.view.bounds;
            
        } completion:^(BOOL finished) {
            
            [next didMoveToParentViewController:weakSelf];
            [weakSelf.currentViewController removeFromParentViewController];
            weakSelf.currentViewController = next;
        
        }];
    }
}

#pragma mark - Pan Navigation

- (void)pan:(PanGestureRecognizer *)recognizer
{
    UIViewController * vc = nil;
    if (recognizer.panDirection == PanDirectionBack)
    {
        vc = [self previousViewController];
    }
    else if (recognizer.panDirection == PanDirectionForward)
    {
        vc = [self nextViewController];
    }
    
    if (!vc)
    {
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        vc.view.frame = [self frameForDirection:recognizer.panDirection obeyParallax:NO];
        [self addChildViewController:vc];
        [self.view addSubview:vc.view];
    }
    
    if (recognizer.panDidChangeDirection)
    {
        if ((recognizer.panDirection == PanDirectionBack && self.currentViewController.view.frame.origin.x <= 0.0f) || (recognizer.panDirection == PanDirectionForward && self.currentViewController.view.frame.origin.x >= 0.0f))
        {
            self.currentViewController.view.frame = (CGRect){0.0f, 0.0f, self.currentViewController.view.bounds.size};
            if (recognizer.state == UIGestureRecognizerStateEnded)
            {
                [vc.view removeFromSuperview];
                [vc removeFromParentViewController];
            }
            
            return;
        }
    }
    
    CGPoint translation = [recognizer translationInView:self.view];
    
    CGFloat adjustedTranslation = (self.parallaxEnabled) ? translation.x * ParallaxScalar : translation.x;
    self.currentViewController.view.frame = (CGRect){adjustedTranslation, 0, self.currentViewController.view.bounds.size};

    CGFloat originX = (recognizer.panDirection == PanDirectionForward) ? self.view.bounds.size.width : 0 - self.view.bounds.size.width;
    vc.view.frame = (CGRect){originX + translation.x, 0, vc.view.bounds.size};
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint velocity = [recognizer velocityInView:self.view];
        if (ABS(translation.x) > self.view.bounds.size.width * PanCompletionThreshold || ABS(velocity.x) > VelocityThreshold)
        {
            [self finishPanInDirection:recognizer.panDirection withVelocity:velocity toViewController:vc];
        }
        else
        {
            [self cancelPanInDirection:recognizer.panDirection toViewController:vc];
        }
    }
}

- (void)finishPanInDirection:(PanDirection)direction withVelocity:(CGPoint)velocity toViewController:(UIViewController *)new
{
    [self.currentViewController willMoveToParentViewController:nil];
    
    PanDirection oppositeDirection = direction == PanDirectionBack ? PanDirectionForward : PanDirectionBack;
    CGRect oldFrame = [self frameForDirection:oppositeDirection obeyParallax:YES];
    
    float duration = TransitionDuration;
    if (ABS(velocity.x) > VelocityThreshold)
    {
        duration = TransitionDuration * (ABS(new.view.frame.origin.x) / new.view.frame.size.width);
    }
    
    __weak ContainerViewController * weakSelf = self;
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        weakSelf.currentViewController.view.frame = oldFrame;
        new.view.frame = weakSelf.view.bounds;
        
    } completion:^(BOOL finished) {
        
        [weakSelf.currentViewController.view removeFromSuperview];
        [weakSelf.currentViewController removeFromParentViewController];
        [new didMoveToParentViewController:weakSelf];
        weakSelf.currentViewController = new;
    
    }];
}

- (void)cancelPanInDirection:(PanDirection)direction toViewController:(UIViewController *)new
{
    __weak ContainerViewController * weakSelf = self;
    [UIView animateWithDuration:TransitionDuration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        new.view.frame = [weakSelf frameForDirection:direction obeyParallax:NO];
        weakSelf.currentViewController.view.frame = weakSelf.view.bounds;
        
    } completion:^(BOOL finished) {
        
        [new.view removeFromSuperview];
        [new removeFromParentViewController];
    
    }];
}

#pragma mark - Page Accessors

- (UIViewController *)previousViewController
{
    UIViewController *previous = nil;

    int index = [self.viewControllers indexOfObjectIdenticalTo:self.currentViewController] - 1;
    if (self.mode == ContainerViewControllerModeStatic && self.wrappingEnabled)
    {
        if (index < 0)
        {
            index = [self.viewControllers count] - 1;
        }
    }
    
    if (index >= 0 && index < [self.viewControllers count])
    {
        previous = [self.viewControllers objectAtIndex:index];
    }

    if (!previous && self.mode == ContainerViewControllerModeDynamic)
    {
        previous = [self.datasource containerViewController:self viewControllerBeforeViewController:self.currentViewController];
        if (previous)
        {
            [self.viewControllers insertObject:previous atIndex:0];
        }
    }
    
    if ([self.viewControllers count] > 3 && self.mode == ContainerViewControllerModeDynamic)
    {
        [self.viewControllers removeLastObject];
    }

    return previous;
}

- (UIViewController *)nextViewController
{
    UIViewController *next = nil;

    int index = [self.viewControllers indexOfObjectIdenticalTo:self.currentViewController] + 1;
    if (self.mode == ContainerViewControllerModeStatic && self.wrappingEnabled)
    {
        if (index >= [self.viewControllers count])
        {
            index = 0;
        }
    }

    if (index >= 0 && index < [self.viewControllers count])
    {
        next = [self.viewControllers objectAtIndex:index];
    }
    
    if (!next && self.mode == ContainerViewControllerModeDynamic)
    {
        next = [self.datasource containerViewController:self viewControllerAfterViewController:self.currentViewController];
        if (next)
        {
            [self.viewControllers addObject:next];
        }
    }
    
    if ([self.viewControllers count] > 3 && self.mode == ContainerViewControllerModeDynamic)
    {
        [self.viewControllers removeObjectAtIndex:0];
    }

    return next;
}

#pragma mark - Frames

- (CGRect)frameForDirection:(PanDirection)direction obeyParallax:(BOOL)obeyParallax
{
    CGRect rect = CGRectZero;
    
    if (direction == PanDirectionBack)
    {
        rect = [self previousFrame:obeyParallax];
    }
    else
    {
        rect = [self nextFrame:obeyParallax];
    }
    
    return rect;
}

- (CGRect)nextFrame:(BOOL)obeyParallax
{
    CGRect rect = CGRectZero;
    
    if (self.parallaxEnabled && obeyParallax)
    {
        rect = (CGRect){self.view.bounds.size.width * ParallaxScalar, 0, self.view.bounds.size};
    }
    else
    {
        rect = (CGRect){self.view.bounds.size.width, 0, self.view.bounds.size};
    }
    
    return rect;
}

- (CGRect)previousFrame:(BOOL)obeyParallax
{
    CGRect rect = CGRectZero;
    
    if (self.parallaxEnabled && obeyParallax)
    {
        rect = (CGRect){0 - self.view.bounds.size.width * ParallaxScalar, 0, self.view.bounds.size};
    }
    else
    {
        rect = (CGRect){0 - self.view.bounds.size.width, 0, self.view.bounds.size};;
    }
    
    return rect;
}

@end
