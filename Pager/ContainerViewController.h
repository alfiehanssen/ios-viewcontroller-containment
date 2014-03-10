//
//  ContainerViewController.h
//  Pager
//
//  Created by Alfie Hanssen on 9/17/13.
//  Copyright (c) 2013 Alfie Hanssen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContainerViewControllerDatasource <NSObject>

@required
- (UIViewController *)containerViewController:(UIViewController *)container viewControllerBeforeViewController:(UIViewController *)vc;
- (UIViewController *)containerViewController:(UIViewController *)container viewControllerAfterViewController:(UIViewController *)vc;

@end

@interface ContainerViewController : UIViewController

@property (nonatomic, assign) BOOL parallaxEnabled; // default = ON
@property (nonatomic, assign) BOOL wrappingEnabled; // default = OFF, Only applicable when initializing with setViewControllers:

@property (nonatomic, weak) id<ContainerViewControllerDatasource> datasource;

@property (nonatomic, strong, readonly) UIViewController *currentViewController;

- (void)setInitialViewController:(UIViewController *)vc;
- (void)setViewControllers:(NSMutableArray *)viewControllers;

@end
