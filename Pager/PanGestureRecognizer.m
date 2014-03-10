//
//  PanGestureRecognizer.m
//  Pager
//
//  Created by Alfred Hanssen on 9/18/13.
//  Copyright (c) 2013 Alfie Hanssen. All rights reserved.
//

#import "PanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation PanGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self)
    {
        _panDirection = PanDirectionNone;
        _panDidChangeDirection = NO;
    }
    
    return self;
}

- (void)reset
{
    [super reset];
    
    self.panDirection = PanDirectionNone;
    self.panDidChangeDirection = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
 
    CGPoint velocity = [self velocityInView:self.view];

    if (self.state == UIGestureRecognizerStatePossible || self.state == UIGestureRecognizerStateBegan)
    {
        if (velocity.x > 0.0f)
        {
            self.panDirection = PanDirectionBack;
        }
        else
        {
            self.panDirection = PanDirectionForward;
        }
    }
    else
    {
        PanDirection currentDirection = (velocity.x > 0.0f) ? PanDirectionBack : PanDirectionForward;
        if (self.panDirection != currentDirection)
        {
            self.panDidChangeDirection = YES;
        }
    }
}

@end
