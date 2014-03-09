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

@interface AppDelegate () <ContainerViewControllerDatasource>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    ContainerViewController *containerViewController = [[ContainerViewController alloc] init];
    containerViewController.view.frame = self.window.bounds;
    
    // Setup #1
    [containerViewController setViewControllers:[self viewControllersArray]];

    // Setup #2
//    containerViewController.datasource = self;
//    [containerViewController setInitialViewController:[ContentViewController new]];
    
    [self.window setRootViewController:containerViewController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (NSArray *)viewControllersArray
{
    NSInteger count = 5;
    NSMutableArray *viewControllers = [NSMutableArray array];
    
    for (NSInteger i = 0; i < count; i++)
    {
        ContentViewController * new = [ContentViewController new];
        viewControllers[i] = new;
    }
    
    return viewControllers;
}

#pragma mark - ContainerViewController Datasource

- (UIViewController *)containerViewController:(ContainerViewController *)container viewControllerBeforeViewController:(UIViewController *)vc
{
    ContentViewController * new = [ContentViewController new];
    
    return new;
}

- (UIViewController *)containerViewController:(ContainerViewController *)container viewControllerAfterViewController:(UIViewController *)vc
{
    ContentViewController * new = [ContentViewController new];
    
    return new;
}

@end
