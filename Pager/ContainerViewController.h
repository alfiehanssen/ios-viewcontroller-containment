//
//  ContainerViewController.h
//  Pager
//
//  Created by Alfie Hanssen on 9/17/13.
//  Copyright (c) 2013 Alfie Hanssen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContainerViewController;

@protocol ContainerViewControllerDatasource <NSObject>

@required
- (UIViewController *)containerViewController:(UIViewController *)container viewControllerBeforeViewController:(UIViewController *)vc;
- (UIViewController *)containerViewController:(UIViewController *)container viewControllerAfterViewController:(UIViewController *)vc;

@end

@interface ContainerViewController : UIViewController

@property (nonatomic, assign) BOOL parallaxEnabled;
@property (nonatomic, assign) BOOL wrappingEnabled;

@property (nonatomic, strong, readonly) UIViewController *currentViewController;
@property (nonatomic, weak) id<ContainerViewControllerDatasource> datasource;

- (void)setInitialViewController:(UIViewController *)vc;
- (void)setViewControllers:(NSArray *)viewControllers;

@end
