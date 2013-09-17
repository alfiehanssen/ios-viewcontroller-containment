//
//  ContainerViewController.h
//  Pager
//
//  Created by Alfie Hanssen on 9/17/13.
//  Copyright (c) 2013 Alfie Hanssen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContainerViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL loopingEnabled; // NO = default
@property (nonatomic, assign) BOOL parallaxEnabled; // YES = default

@end
