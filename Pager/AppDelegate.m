//
//  AppDelegate.m
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

#import "AppDelegate.h"
#import "ContainerViewController.h"
#import "ContentViewController.h"

@interface AppDelegate () <ContainerViewControllerDatasource>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    ContainerViewController *containerViewController = [ContainerViewController new];
    containerViewController.view.frame = self.window.bounds;
    
    // Setup #1
//    [containerViewController setViewControllers:[self viewControllersArray]];

    // Setup #2
    containerViewController.datasource = self;
    [containerViewController setInitialViewController:[ContentViewController new]];
    
    [self.window setRootViewController:containerViewController];
    [self.window makeKeyAndVisible];
    
    return YES;
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

#pragma mark - Convenience

- (NSMutableArray *)viewControllersArray
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

@end
