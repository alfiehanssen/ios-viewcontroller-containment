//
//  PanGestureRecognizer.m
//  Pager
//
//  Created by Alfred Hanssen on 9/18/13.
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
