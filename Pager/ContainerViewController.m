//
//  ContainerViewController.m
//  Pager
//
//  Created by Alfie Hanssen on 9/17/13.
//  Copyright (c) 2013 Alfie Hanssen. All rights reserved.
//

#import "ContainerViewController.h"
#import "ContentViewController.h"

typedef enum {
    PanDirectionBack,
    PanDirectionForward
} PanDirection;

@interface ContainerViewController ()
@property (nonatomic, assign) int index;
@property (nonatomic, strong) NSMutableArray * contentArray;
@property (nonatomic, strong) ContentViewController * nextViewController;
@end

@implementation ContainerViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.index = 0;
        self.loopingEnabled = NO;
        self.gestureMode = GestureModePan;
        self.contentArray = [NSMutableArray arrayWithCapacity:5];
        [self.contentArray addObject:@"0000000"];
        [self.contentArray addObject:@"1111111"];
        [self.contentArray addObject:@"2222222"];
        [self.contentArray addObject:@"3333333"];
        [self.contentArray addObject:@"4444444"];
    }
    return self;
}

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
    [self.view addGestureRecognizer:pan];

    UISwipeGestureRecognizer * swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.delegate = self;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer * swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRight.delegate = self;
    [self.view addGestureRecognizer:swipeRight];

    // Add initial contentViewController
    NSString * content = [self.contentArray objectAtIndex:self.index];
    ContentViewController * vc = [[ContentViewController alloc] initWithContent:content];
    vc.view.frame = self.view.bounds;
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
}

#pragma mark - UIGestureRecognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL shouldBegin = YES;
    if (self.gestureMode == GestureModePan) {
        if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
            shouldBegin = NO;
        }
    } else if (self.gestureMode == GestureModeSwipe) {
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            shouldBegin = NO;
        }
    }
    return shouldBegin;
}

#pragma mark - Gestures

- (void)pan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    PanDirection direction = (translation.x > 0) ? PanDirectionBack : PanDirectionForward;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self setupNextViewController:direction]; // self.nextViewController is destroyed in the transition methods
    }
    
    ContentViewController * current = [self currentViewController]; //TODO: should currentViewController be an @property?
    current.view.frame = (CGRect){translation.x, 0, current.view.frame.size};

    float originX = (direction == PanDirectionForward) ? self.view.frame.size.width : 0 - self.view.frame.size.width;
    self.nextViewController.view.frame = (CGRect){originX + translation.x, 0, self.nextViewController.view.frame.size};
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (ABS(translation.x) > self.view.frame.size.width * 0.5f) {
            [self finishPanInDirection:direction fromViewController:current toViewController:self.nextViewController];
        } else {
            [self cancelPanInDirection:direction fromViewController:current toViewController:self.nextViewController];
        }
    }
}

- (void)cancelPanInDirection:(PanDirection)direction fromViewController:(UIViewController *)old toViewController:(UIViewController *)new
{
    if (old && new) {
        
        CGRect newFrame = CGRectZero;
        if (direction == PanDirectionForward) {
            newFrame = [self nextEndFrame];
        } else {
            newFrame = [self previousEndFrame];
        }
        
        __weak ContainerViewController * weakSelf = self;
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            new.view.frame = newFrame;
            old.view.frame = weakSelf.view.bounds;
            
        } completion:^(BOOL finished) {
            [new.view removeFromSuperview];
            [new removeFromParentViewController];
            self.nextViewController = nil;
            NSLog(@"contentViewControllers: %i", [self.childViewControllers count]);
        }];
    }
}

- (void)finishPanInDirection:(PanDirection)direction fromViewController:(UIViewController *)old toViewController:(UIViewController *)new
{
    if (old && new) {
        
        [old willMoveToParentViewController:nil];
        
        CGRect oldFrame = CGRectZero;
        if (direction == PanDirectionForward) {
            self.index = [self nextIndex];
            oldFrame = [self previousEndFrame];
        } else {
            self.index = [self previousIndex];
            oldFrame = [self nextEndFrame];
        }
        
        __weak ContainerViewController * weakSelf = self;
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            old.view.frame = oldFrame;
            new.view.frame = weakSelf.view.bounds;
            
        } completion:^(BOOL finished) {
            [old.view removeFromSuperview];
            [old removeFromParentViewController];
            [new didMoveToParentViewController:self];
            self.nextViewController = nil;
            NSLog(@"contentViewControllers: %i", [self.childViewControllers count]);
        }];
    }
}

- (void)setupNextViewController:(PanDirection)direction
{
    int index = 0;
    CGRect frame = CGRectZero;
    if (direction == PanDirectionForward) {
        index = [self nextIndex];
        frame = [self nextStartFrame];
    } else {
        index = [self previousIndex];
        frame = [self previousStartFrame];
    }
    
    self.nextViewController = [self newViewControllerForIndex:index];
    self.nextViewController.view.frame = frame;
    [self addChildViewController:self.nextViewController];
    [self.view addSubview:self.nextViewController.view];
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)gesture
{
    int index = [self nextIndex];
    if (index != self.index) {
        self.index = index;
        ContentViewController * new = [self newViewControllerForIndex:self.index];
        ContentViewController * current = [self currentViewController];
        [self cycleInDirection:gesture.direction fromViewController:current toViewController:new];
    }
}

- (void)swipeRight:(UISwipeGestureRecognizer *)gesture
{
    int index = [self previousIndex];
    if (index != self.index) {
        self.index = index;
        ContentViewController * new = [self newViewControllerForIndex:self.index];
        ContentViewController * current = [self currentViewController];
        [self cycleInDirection:gesture.direction fromViewController:current toViewController:new];
    }
}

- (int)nextIndex
{
    int index = 0;
    if (self.loopingEnabled) {
        index = (self.index + 1 >= [self.contentArray count]) ? 0 : self.index + 1;
    } else {
        index = MIN(self.index + 1, [self.contentArray count] - 1);
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

#pragma mark - Containment

- (ContentViewController *)newViewControllerForIndex:(int)index
{
    NSString * content = [self.contentArray objectAtIndex:index];
    ContentViewController * new = [[ContentViewController alloc] initWithContent:content];
    return new;
}

- (ContentViewController *)currentViewController
{
    ContentViewController * vc = nil;
    if ([self.childViewControllers count]) {
        vc = [self.childViewControllers objectAtIndex:0];
    }
    return vc;
}

- (void)cycleInDirection:(UISwipeGestureRecognizerDirection)direction fromViewController:(UIViewController *)old toViewController:(UIViewController *)new
{
    if (old && new) {
        
        CGRect oldFrame = CGRectZero;
        
        if (direction == UISwipeGestureRecognizerDirectionLeft) {
            new.view.frame = [self nextStartFrame];
            oldFrame = [self previousEndFrame];
        } else {
            new.view.frame = [self previousStartFrame];
            oldFrame = [self nextEndFrame];
        }
        
        [old willMoveToParentViewController:nil];
        [self addChildViewController:new];
        
        __weak ContainerViewController * weakSelf = self;
        [self transitionFromViewController:old toViewController:new duration:0.25f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            new.view.frame = weakSelf.view.bounds;
            old.view.frame = oldFrame;
            
        } completion:^(BOOL finished) {
            [old removeFromParentViewController];
            [new didMoveToParentViewController:self];
            
            NSLog(@"contentViewControllers: %i", [self.childViewControllers count]);
        }];
    }
}

#pragma mark - Frames

- (CGRect)nextStartFrame
{
    return (CGRect){self.view.bounds.size.width, 0, self.view.bounds.size};
}

- (CGRect)previousStartFrame
{
    return (CGRect){0 - self.view.bounds.size.width, 0, self.view.bounds.size};
}

- (CGRect)nextEndFrame
{
    return (CGRect){self.view.bounds.size.width, 0, self.view.bounds.size};
}

- (CGRect)previousEndFrame
{
    return (CGRect){0 - self.view.bounds.size.width, 0, self.view.bounds.size};
}

@end
