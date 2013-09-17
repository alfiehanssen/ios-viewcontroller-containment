//
//  ContainerViewController.m
//  Pager
//
//  Created by Alfie Hanssen on 9/17/13.
//  Copyright (c) 2013 Alfie Hanssen. All rights reserved.
//

#import "ContainerViewController.h"
#import "ContentViewController.h"

@interface ContainerViewController ()
@property (nonatomic, assign) int index;
@property (nonatomic, strong) NSMutableArray * contentArray;
@end

@implementation ContainerViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.index = 0;
        self.loopingEnabled = NO;
        self.contentArray = [NSMutableArray arrayWithCapacity:5];
        [self.contentArray addObject:@"0000000"];
        [self.contentArray addObject:@"1111111"];
        [self.contentArray addObject:@"2222222"];
        [self.contentArray addObject:@"3333333"];
        [self.contentArray addObject:@"4444444"];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISwipeGestureRecognizer * swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer * swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];

    // Add initial contentViewController
    NSString * content = [self.contentArray objectAtIndex:self.index];
    ContentViewController * vc = [[ContentViewController alloc] initWithContent:content];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gestures

- (void)swipeLeft:(UISwipeGestureRecognizer *)gesture
{
    int index = 0;

    if (self.loopingEnabled) {
        index = (self.index + 1 >= [self.contentArray count]) ? 0 : self.index + 1;
    } else {
        index = MIN(self.index + 1, [self.contentArray count] - 1);
    }
    
    if (index != self.index) {
        self.index = index;
        ContentViewController * new = [self newViewController];
        ContentViewController * current = [self currentViewController];
        [self cycleInDirection:gesture.direction fromViewController:current toViewController:new];
    }
}

- (void)swipeRight:(UISwipeGestureRecognizer *)gesture
{
    int index = 0;
    
    if (self.loopingEnabled) {
        index = (self.index - 1 < 0) ? [self.contentArray count] - 1 : self.index - 1;
    } else {
        index = MAX(0, self.index - 1);
    }

    if (index != self.index) {
        self.index = index;
        ContentViewController * new = [self newViewController];
        ContentViewController * current = [self currentViewController];
        [self cycleInDirection:gesture.direction fromViewController:current toViewController:new];
    }
}

#pragma mark - Containment

- (ContentViewController *)newViewController
{
    NSString * content = [self.contentArray objectAtIndex:self.index];
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
    return (CGRect){self.view.bounds.size.width * 0.5f, 0, self.view.bounds.size};
}

- (CGRect)previousEndFrame
{
    return (CGRect){0 - self.view.bounds.size.width * 0.5f, 0, self.view.bounds.size};
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
        [self transitionFromViewController:old toViewController:new duration:0.25f options:0 animations:^{
            
            new.view.frame = weakSelf.view.bounds;
            old.view.frame = oldFrame;
            
        } completion:^(BOOL finished) {
            [old removeFromParentViewController];
            [new didMoveToParentViewController:self];
            
            NSLog(@"contentViewControllers: %i", [self.childViewControllers count]);
        }];
    }
}

@end
