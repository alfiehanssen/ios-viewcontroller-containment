//
//  ContainerViewController.h
//  Pager
//
//  Created by Alfie Hanssen on 9/17/13.
//  Copyright (c) 2013 Alfie Hanssen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentViewController.h"

@class ContainerViewController;

@protocol ContainerViewControllerDatasource <NSObject>

@required
- (ContentViewController *)containerViewController:(ContainerViewController *)container viewControllerBeforeViewController:(ContentViewController *)vc;
- (ContentViewController *)containerViewController:(ContainerViewController *)container viewControllerAfterViewController:(ContentViewController *)vc;
- (ContentViewController *)containerViewController:(ContainerViewController *)container viewControllerForIndex:(int)index;

@end


@protocol ContainerViewControllerDelegate <NSObject>

// TODO: call these delegate methods
@required
- (void)containerViewController:(ContainerViewController *)container willTransitionFromViewController:(ContentViewController *)fromVC toViewController:(ContentViewController *)toVC;
- (void)containerViewController:(ContainerViewController *)container didTransitionFromViewController:(ContentViewController *)fromVC toViewController:(ContentViewController *)toVC;

@end


@interface ContainerViewController : UIViewController

@property (nonatomic, weak) id<ContainerViewControllerDatasource> datasource;
@property (nonatomic, weak) id<ContainerViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL parallaxEnabled; // YES = default

@property (nonatomic, strong) ContentViewController * currentViewController;

- (void)setInitialViewController:(ContentViewController *)vc;

@end
