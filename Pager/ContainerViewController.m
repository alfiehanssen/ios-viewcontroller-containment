//
//  ContainerViewController.m
//  Pager
//
//  Created by Alfie Hanssen on 9/17/13.
//  Copyright (c) 2013 Alfie Hanssen. All rights reserved.
//

#import "ContainerViewController.h"
#import "ContentViewController.h"

#define PARALLAX_SCALAR 0.5f
#define TRANSITION_DURATION 0.25f
#define PAN_COMPLETION_THRESHOLD 0.5f
#define VELOCITY_THRESHOLD 300.0f

typedef enum {
    PanDirectionBack,
    PanDirectionForward
} PanDirection;

@interface ContainerViewController ()
@property (nonatomic, assign) int index;
@property (nonatomic, strong) NSMutableArray * contentArray;
@property (nonatomic, strong) ContentViewController * currentViewController;
@property (nonatomic, strong) ContentViewController * nextViewController;
@end

@implementation ContainerViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.index = 0;
        self.loopingEnabled = NO;
        self.parallaxEnabled = YES;
        self.contentArray = [NSMutableArray arrayWithCapacity:5];
        [self.contentArray addObject:@"0000000"];
        [self.contentArray addObject:@"1111111"];
        [self.contentArray addObject:@"2222222"];
        [self.contentArray addObject:@"3333333"];
        [self.contentArray addObject:@"4444444"];
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
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    pan.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:pan];

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tap];
    
    self.currentViewController = [self viewControllerForIndex:self.index];
    self.currentViewController.view.frame = self.view.bounds;
    [self addChildViewController:self.currentViewController];
    [self.view addSubview:self.currentViewController.view];
    [self.currentViewController didMoveToParentViewController:self];
}

#pragma mark - UIGestureRecognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL shouldBegin = YES;
    
    if (!self.loopingEnabled) {
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.view];
            PanDirection direction = (translation.x > 0) ? PanDirectionBack : PanDirectionForward;
            if (direction == PanDirectionBack && self.index == 0) {
                shouldBegin = NO;
            } else if (direction == PanDirectionForward && self.index == [self.contentArray count] - 1) {
                shouldBegin = NO;
            }
        }
    }
    
    return shouldBegin;
}

#pragma mark - Gestures

- (void)tap:(UITapGestureRecognizer *)recognizer
{
    int index = (self.index + 2 >= [self.contentArray count]) ? [self.contentArray count] - 1 : self.index + 2;
    
    if (self.index == index) {
        return;
    }
    
    if (ABS(self.index - index) == 1) {
        [self transitionToIndex:index];
    } else {
        [self jumpToIndex:index];
    }
}

- (void)pan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    PanDirection direction = (translation.x > 0) ? PanDirectionBack : PanDirectionForward;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        int index = [self indexForDirection:direction];
        self.nextViewController = [self viewControllerForIndex:index]; // self.nextViewController is destroyed in the transition methods
        self.nextViewController.view.frame = [self frameForDirection:direction obeyParallax:NO];
        [self addChildViewController:self.nextViewController];
        [self.view addSubview:self.nextViewController.view];
    }
    
    ContentViewController * current = [self currentViewController];
    float adjustedTranslation = (self.parallaxEnabled) ? translation.x * PARALLAX_SCALAR : translation.x;
    current.view.frame = (CGRect){adjustedTranslation, 0, current.view.frame.size};

    float originX = (direction == PanDirectionForward) ? self.view.frame.size.width : 0 - self.view.frame.size.width;
    self.nextViewController.view.frame = (CGRect){originX + translation.x, 0, self.nextViewController.view.frame.size};
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (ABS(translation.x) > self.view.frame.size.width * PAN_COMPLETION_THRESHOLD) {
            [self finishPanInDirection:direction withVelocity:[recognizer velocityInView:self.view] toViewController:self.nextViewController];
        } else {
            [self cancelPanInDirection:direction toViewController:self.nextViewController];
        }
    }
}

#pragma mark - Containment

- (void)jumpToIndex:(int)index
{
    ContentViewController * new = [self viewControllerForIndex:index];
    new.view.frame = self.view.bounds;
    
    [self addChildViewController:new];
    [self.currentViewController willMoveToParentViewController:nil];
    
    [self.view addSubview:new.view];
    [self.currentViewController.view removeFromSuperview];
    
    [new didMoveToParentViewController:self];
    [self.currentViewController removeFromParentViewController];
    
    self.currentViewController = new;
    
    self.index = index;
}

- (void)transitionToIndex:(int)index
{
    ContentViewController * new = [self viewControllerForIndex:index];
    
    PanDirection direction = (self.index - index) > 0 ? PanDirectionBack : PanDirectionForward;
    new.view.frame = (direction == PanDirectionBack) ? [self previousFrame:NO] : [self nextFrame:NO];
    
    [self addChildViewController:new];
    [self.currentViewController willMoveToParentViewController:nil];
    
    self.index = index;
    PanDirection oppositeDirection = direction == PanDirectionBack ? PanDirectionForward : PanDirectionBack;
    CGRect oldFrame = [self frameForDirection:oppositeDirection obeyParallax:YES];

    __weak ContainerViewController * weakSelf = self;
    [self transitionFromViewController:self.currentViewController toViewController:new duration:TRANSITION_DURATION options:0 animations:^{
        weakSelf.currentViewController.view.frame = oldFrame;
        new.view.frame = weakSelf.view.bounds;

    } completion:^(BOOL finished) {
        [new didMoveToParentViewController:self];
        [weakSelf.currentViewController removeFromParentViewController];
        weakSelf.currentViewController = new;
    }];
}

- (void)finishPanInDirection:(PanDirection)direction withVelocity:(CGPoint)velocity toViewController:(UIViewController *)new
{
    [self.currentViewController willMoveToParentViewController:nil];
    
    PanDirection oppositeDirection = direction == PanDirectionBack ? PanDirectionForward : PanDirectionBack;
    CGRect oldFrame = [self frameForDirection:oppositeDirection obeyParallax:YES];
    self.index = [self indexForDirection:direction];
    
    float duration = TRANSITION_DURATION;
    if (ABS(velocity.x) > VELOCITY_THRESHOLD) {
        duration = TRANSITION_DURATION * (ABS(new.view.frame.origin.x) / new.view.frame.size.width);
    }
    
    __weak ContainerViewController * weakSelf = self;
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        weakSelf.currentViewController.view.frame = oldFrame;
        new.view.frame = weakSelf.view.bounds;
        
    } completion:^(BOOL finished) {
        [weakSelf.currentViewController.view removeFromSuperview];
        [weakSelf.currentViewController removeFromParentViewController];
        [new didMoveToParentViewController:weakSelf];
        weakSelf.currentViewController = weakSelf.nextViewController;
        weakSelf.nextViewController = nil;
    }];
}

- (void)cancelPanInDirection:(PanDirection)direction toViewController:(UIViewController *)new
{
    __weak ContainerViewController * weakSelf = self;
    [UIView animateWithDuration:TRANSITION_DURATION delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        new.view.frame = [weakSelf frameForDirection:direction obeyParallax:NO];;
        weakSelf.currentViewController.view.frame = weakSelf.view.bounds;
        
    } completion:^(BOOL finished) {
        [new.view removeFromSuperview];
        [new removeFromParentViewController];
        weakSelf.nextViewController = nil;
    }];
}

- (ContentViewController *)viewControllerForIndex:(int)index
{
    NSString * content = [self.contentArray objectAtIndex:index];
    ContentViewController * new = [[ContentViewController alloc] initWithContent:content];
    return new;
}

#pragma mark - Indexing

- (int)indexForDirection:(PanDirection)direction
{
    int index = 0;
    if (direction == PanDirectionBack) {
        index = [self previousIndex];
    } else {
        index = [self nextIndex];
    }
    return index;
}

- (int)nextIndex
{
    int index = 0;
    if (self.loopingEnabled) {
        index = (self.index + 1 >= [self.contentArray count]) ? 0 : self.index + 1;
    } else {
        index = (int)MIN(self.index + 1, [self.contentArray count] - 1);
    }
    return index;
}

- (int)previousIndex
{
    int index = 0;
    if (self.loopingEnabled) {
        index = (self.index - 1 < 0) ? [self.contentArray count] - 1 : self.index - 1;
    } else {
        index = MAX(0, self.index - 1);
    }
    return index;
}

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
