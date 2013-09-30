//
//  UIColor+Random.m
//  Dynamics
//
//  Created by Alfie Hanssen on 9/27/13.
//  Copyright (c) 2013 Alfred Hanssen. All rights reserved.
//

#import "UIColor+Random.h"

#define ARC4RANDOM_MAX 0x100000000

@implementation UIColor (Random)

+ (UIColor *)randomColor
{
    float r = ((float)arc4random() / ARC4RANDOM_MAX);
    float g = ((float)arc4random() / ARC4RANDOM_MAX);
    float b = ((float)arc4random() / ARC4RANDOM_MAX);
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

@end
