//
//  AppDelegate.m
//  Pager
//
//  Created by Alfie Hanssen on 9/17/13.
//  Copyright (c) 2013 Alfie Hanssen. All rights reserved.
//

#import "AppDelegate.h"
#import "ContainerViewController.h"
#import "ContentViewController.h"

@interface AppDelegate () <ContainerViewControllerDatasource, ContainerViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray * contentArray;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.contentArray = [NSMutableArray arrayWithCapacity:5];
    [self.contentArray addObject:@"0000000"];
    [self.contentArray addObject:@"1111111"];
    [self.contentArray addObject:@"2222222"];
    [self.contentArray addObject:@"3333333"];
    [self.contentArray addObject:@"4444444"];

    ContainerViewController * vc = [[ContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil];
    vc.datasource = self;
    vc.delegate = self;
    vc.parallaxEnabled = YES;
    [vc setInitialViewController:[self viewControllerForIndex:0]];
    
    vc.view.frame = self.window.bounds;
    [self.window setRootViewController:vc];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - ContainerViewController Datasource

- (ContentViewController *)containerViewController:(ContainerViewController *)container viewControllerForIndex:(int)index
{
    ContentViewController * new = [self viewControllerForIndex:index];
    return new;
}

- (UIViewController *)containerViewController:(ContainerViewController *)container viewControllerBeforeViewController:(UIViewController *)vc
{
    ContentViewController * new = nil;
    int currentIndex = ((ContentViewController *)vc).index;
    int index = [self indexBeforeIndex:currentIndex];
    if (index != currentIndex) {
        new = [self viewControllerForIndex:index];
    }
    return new;
}

- (UIViewController *)containerViewController:(ContainerViewController *)container viewControllerAfterViewController:(UIViewController *)vc
{
    ContentViewController * new = nil;
    int currentIndex = ((ContentViewController *)vc).index;
    int index = [self indexAfterIndex:currentIndex];
    if (index != currentIndex) {
        new = [self viewControllerForIndex:index];
    }
    return new;
}

- (ContentViewController *)viewControllerForIndex:(int)index
{
    ContentViewController * vc = nil;
    
    if (index >= 0 && index < [self.contentArray count]) {
        NSString * content = [self.contentArray objectAtIndex:index];
        vc = [[ContentViewController alloc] initWithNibName:@"ContentViewController" bundle:nil];
        vc.index = index;
        vc.content = content;
    }
    
    return vc;
}

- (int)indexAfterIndex:(int)oldIndex
{
    int index = (int)MIN(oldIndex + 1, [self.contentArray count] - 1);
    return index;
}

- (int)indexBeforeIndex:(int)oldIndex
{
    int index = MAX(0, oldIndex - 1);
    return index;
}

#pragma mark - ContainerViewController Delegate

- (void)containerViewController:(ContainerViewController *)container willTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    NSLog(@"will transition");
}

- (void)containerViewController:(ContainerViewController *)container didTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    NSLog(@"did transition");
}

@end
