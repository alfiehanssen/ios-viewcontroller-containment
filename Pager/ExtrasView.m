//
//  ExtrasView.m
//  Pager
//
//  Created by Alfie Hanssen on 9/30/13.
//  Copyright (c) 2013 Alfie Hanssen. All rights reserved.
//

#import "ExtrasView.h"

@implementation ExtrasView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Frames

+ (float)defaultWidth
{
    return 140.0f;
}

+ (CGRect)frameWhenHidden
{
    return (CGRect){[UIScreen mainScreen].bounds.size.width, 0, [ExtrasView defaultWidth], [UIScreen mainScreen].bounds.size.height};
}

@end
