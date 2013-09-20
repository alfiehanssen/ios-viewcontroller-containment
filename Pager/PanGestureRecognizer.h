//
//  PanGestureRecognizer.h
//  Pager
//
//  Created by Alfred Hanssen on 9/18/13.
//  Copyright (c) 2013 Alfie Hanssen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PanDirectionNone,
    PanDirectionBack,
    PanDirectionForward
} PanDirection;

@interface PanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, assign) PanDirection panDirection;
@property (nonatomic, assign) BOOL panDidChangeDirection;

@end
