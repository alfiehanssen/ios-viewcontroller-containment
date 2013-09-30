//
//  ContainerViewController.m
//  Pager
//
//  Created by Alfie Hanssen on 9/17/13.
//  Copyright (c) 2013 Alfie Hanssen. All rights reserved.
//

#import "ContainerViewController.h"
#import "ContentViewController.h"
#import "PanGestureRecognizer.h"

#define PARALLAX_SCALAR 0.5f
#define TRANSITION_DURATION 0.15f
#define PAN_COMPLETION_THRESHOLD 0.5f
#define VELOCITY_THRESHOLD 400.0f

@interface ContainerViewController ()
@property (nonatomic, strong) NSMutableArray * viewControllers;
@end

@implementation ContainerViewController

- (void)dealloc
{
    self.datasource = nil;
    self.delegate = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.parallaxEnabled = YES;
        self.viewControllers = [NSMutableArray arrayWithCapacity:3];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PanGestureRecognizer * pan = [[PanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    pan.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:pan];

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
}

- (void)setInitialViewController:(ContentViewController *)vc
{
    NSAssert(vc != nil, @"Initial viewController must not be nil");
    
    vc.view.frame = self.view.bounds;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    self.currentViewController = vc;
    [self.viewControllers addObject:self.currentViewController];
}

#pragma mark - UIGestureRecognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL shouldBegin = YES;
    
//    if ([gestureRecognizer isKindOfClass:[PanGestureRecognizer class]]) {
//        PanDirection direction = ((PanGestureRecognizer *)gestureRecognizer).panDirection;
//        if (direction == PanDirectionBack && self.currentViewController.index == 0) {
//            shouldBegin = NO;
//        } else if (direction == PanDirectionForward && self.currentViewController.index == [self.contentArray count] - 1) {
//            shouldBegin = NO;
//        }
//    }
    
    return shouldBegin;
}

#pragma mark - Gestures

- (void)tap:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.view];
    if (location.x < self.view.bounds.size.width / 2) {
        [self transitionToPrevious];
    } else {
        [self transitionToNext];
    }
}

- (void)pan:(PanGestureRecognizer *)recognizer
{
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        ContentViewController * vc = nil;
//        if (recognizer.panDirection == PanDirectionBack) {
//            vc = [self.datasource containerViewController:self viewControllerBeforeViewController:self.currentViewController];
//        } else if (recognizer.panDirection == PanDirectionForward) {
//            vc = [self.datasource containerViewController:self viewControllerAfterViewController:self.currentViewController];
//        }
//        vc.view.frame = [self frameForDirection:recognizer.panDirection obeyParallax:NO];
//        [self addChildViewController:vc];
//        [self.view addSubview:vc.view];
//    }
//    
//    if (recognizer.panDidChangeDirection) {
//        if ((recognizer.panDirection == PanDirectionBack && self.currentViewController.view.frame.origin.x <= 0.0f) || (recognizer.panDirection == PanDirectionForward && self.currentViewController.view.frame.origin.x >= 0.0f)) {
//            self.currentViewController.view.frame = (CGRect){0.0f, 0.0f, self.currentViewController.view.bounds.size};
//            if (recognizer.state == UIGestureRecognizerStateEnded) {
//                [self.nextViewController.view removeFromSuperview];
//                [self.nextViewController removeFromParentViewController];
//                self.nextViewController = nil;
//            }
//            return;
//        }
//    }
//    
//    CGPoint translation = [recognizer translationInView:self.view];
//    
//    float adjustedTranslation = (self.parallaxEnabled) ? translation.x * PARALLAX_SCALAR : translation.x;
//    self.currentViewController.view.frame = (CGRect){adjustedTranslation, 0, self.currentViewController.view.bounds.size};
//
//    float originX = (recognizer.panDirection == PanDirectionForward) ? self.view.bounds.size.width : 0 - self.view.bounds.size.width;
//    self.nextViewController.view.frame = (CGRect){originX + translation.x, 0, self.nextViewController.view.bounds.size};
//    
//    if (recognizer.state == UIGestureRecognizerStateEnded) {
//        CGPoint velocity = [recognizer velocityInView:self.view];
//        if (ABS(translation.x) > self.view.bounds.size.width * PAN_COMPLETION_THRESHOLD || ABS(velocity.x) > 500.0f) {
//            [self finishPanInDirection:recognizer.panDirection withVelocity:velocity toViewController:self.nextViewController];
//        } else {
//            [self cancelPanInDirection:recognizer.panDirection toViewController:self.nextViewController];
//        }
//    }
}

#pragma mark - Transitions

- (void)jumpToIndex:(int)index
{
    if (index == self.currentViewController.index) {
        return;
    }

    ContentViewController * new = [self.datasource containerViewController:self viewControllerForIndex:index];
    new.view.frame = self.view.bounds;
    
    [self addChildViewController:new];
    [self.currentViewController willMoveToParentViewController:nil];
    
    [self.view addSubview:new.view];
    [self.currentViewController.view removeFromSuperview];
    
    [new didMoveToParentViewController:self];
    [self.currentViewController removeFromParentViewController];
    
    self.currentViewController = new;
}

- (void)transitionToPrevious
{
    ContentViewController * previous = [self previousViewController]; //[self.datasource containerViewController:self viewControllerBeforeViewController:self.currentViewController];
    if (previous) {
        previous.view.frame = [self frameForDirection:PanDirectionBack obeyParallax:NO];
        
        [self addChildViewController:previous];
        [self.currentViewController willMoveToParentViewController:nil];
        
        CGRect oldFrame = [self frameForDirection:PanDirectionForward obeyParallax:YES];
        
        __weak ContainerViewController * weakSelf = self;
        [self transitionFromViewController:self.currentViewController toViewController:previous duration:TRANSITION_DURATION options:0 animations:^{
            weakSelf.currentViewController.view.frame = oldFrame;
            previous.view.frame = weakSelf.view.bounds;
            
        } completion:^(BOOL finished) {
            [previous didMoveToParentViewController:weakSelf];
            [weakSelf.currentViewController removeFromParentViewController];
            weakSelf.currentViewController = previous;
            
            [weakSelf previousViewController];
        }];
    }
}

- (void)transitionToNext
{
    ContentViewController * next = [self nextViewController]; //[self.datasource containerViewController:self viewControllerAfterViewController:self.currentViewController];
    if (next) {
        next.view.frame = [self frameForDirection:PanDirectionForward obeyParallax:NO];
        
        [self addChildViewController:next];
        [self.currentViewController willMoveToParentViewController:nil];
        
        CGRect oldFrame = [self frameForDirection:PanDirectionBack obeyParallax:YES];
        
        __weak ContainerViewController * weakSelf = self;
        [self transitionFromViewController:self.currentViewController toViewController:next duration:TRANSITION_DURATION options:0 animations:^{
            weakSelf.currentViewController.view.frame = oldFrame;
            next.view.frame = weakSelf.view.bounds;
            
        } completion:^(BOOL finished) {
            [next didMoveToParentViewController:weakSelf];
            [weakSelf.currentViewController removeFromParentViewController];
            weakSelf.currentViewController = next;

            [weakSelf nextViewController];
        }];
    }
}

- (ContentViewController *)previousViewController
{
    ContentViewController * previous = nil;

    int index = [self.viewControllers indexOfObjectIdenticalTo:self.currentViewController] - 1;
    if (index >= 0 && index < [self.viewControllers count]) {
        previous = [self.viewControllers objectAtIndex:index];
    }

    if (!previous) {
        previous = [self.datasource containerViewController:self viewControllerBeforeViewController:self.currentViewController];
        if (previous) {
            [self.viewControllers insertObject:previous atIndex:0];
        }
    }
    
    if ([self.viewControllers count] > 3) {
        [self.viewControllers removeLastObject];
    }

    NSLog(@"viewControllers: %@", self.viewControllers);

    return previous;
}

- (ContentViewController *)nextViewController
{
    ContentViewController * next = nil;

    int index = [self.viewControllers indexOfObjectIdenticalTo:self.currentViewController] + 1;
    if (index >= 0 && index < [self.viewControllers count]) {
        next = [self.viewControllers objectAtIndex:index];
    }
    
    if (!next) {
        next = [self.datasource containerViewController:self viewControllerAfterViewController:self.currentViewController];
        if (next) {
            [self.viewControllers addObject:next];
        }
    }
    
    if ([self.viewControllers count] > 3) {
        [self.viewControllers removeObjectAtIndex:0];
    }

    NSLog(@"viewControllers: %@", self.viewControllers);

    return next;
}

//- (void)finishPanInDirection:(PanDirection)direction withVelocity:(CGPoint)velocity toViewController:(UIViewController *)new
//{
//    [self.currentViewController willMoveToParentViewController:nil];
//    
//    PanDirection oppositeDirection = direction == PanDirectionBack ? PanDirectionForward : PanDirectionBack;
//    CGRect oldFrame = [self frameForDirection:oppositeDirection obeyParallax:YES];
//    self.index = [self indexForDirection:direction];
//    
//    float duration = TRANSITION_DURATION;
//    if (ABS(velocity.x) > VELOCITY_THRESHOLD) {
//        duration = TRANSITION_DURATION * (ABS(new.view.frame.origin.x) / new.view.frame.size.width);
//    }
//    
//    __weak ContainerViewController * weakSelf = self;
//    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//        weakSelf.currentViewController.view.frame = oldFrame;
//        new.view.frame = weakSelf.view.bounds;
//        
//    } completion:^(BOOL finished) {
//        [weakSelf.currentViewController.view removeFromSuperview];
//        [weakSelf.currentViewController removeFromParentViewController];
//        [new didMoveToParentViewController:weakSelf];
//        weakSelf.currentViewController = weakSelf.nextViewController;
//        weakSelf.nextViewController = nil;
//    }];
//}
//
//- (void)cancelPanInDirection:(PanDirection)direction toViewController:(UIViewController *)new
//{
//    __weak ContainerViewController * weakSelf = self;
//    [UIView animateWithDuration:TRANSITION_DURATION delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//        new.view.frame = [weakSelf frameForDirection:direction obeyParallax:NO];;
//        weakSelf.currentViewController.view.frame = weakSelf.view.bounds;
//        
//    } completion:^(BOOL finished) {
//        [new.view removeFromSuperview];
//        [new removeFromParentViewController];
//        weakSelf.nextViewController = nil;
//    }];
//}

#pragma mark - Frames

- (CGRect)frameForDirection:(PanDirection)direction obeyParallax:(BOOL)obeyParallax
{
    CGRect rect = CGRectZero;
    if (direction == PanDirectionBack) {
        rect = [self previousFrame:obeyParallax];
    } else {
        rect = [self nextFrame:obeyParallax];
    }
    return rect;
}

- (CGRect)nextFrame:(BOOL)obeyParallax
{
    CGRect rect = CGRectZero;
    if (self.parallaxEnabled && obeyParallax) {
        rect = (CGRect){self.view.bounds.size.width * PARALLAX_SCALAR, 0, self.view.bounds.size};
    } else {
        rect = (CGRect){self.view.bounds.size.width, 0, self.view.bounds.size};
    }
    return rect;
}

- (CGRect)previousFrame:(BOOL)obeyParallax
{
    CGRect rect = CGRectZero;
    if (self.parallaxEnabled && obeyParallax) {
        rect = (CGRect){0 - self.view.bounds.size.width * PARALLAX_SCALAR, 0, self.view.bounds.size};
    } else {
        rect = (CGRect){0 - self.view.bounds.size.width, 0, self.view.bounds.size};;
    }
    return rect;
}

@end
