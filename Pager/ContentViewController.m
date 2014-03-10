//
//  ContentViewController.m
//  Pager
//
//  Created by Alfie Hanssen on 9/17/13.
//  Copyright (c) 2013 Alfie Hanssen. All rights reserved.
//

#import "ContentViewController.h"

#define ARC4RANDOM_MAX 0x100000000

@implementation ContentViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    float r = ((float)arc4random() / ARC4RANDOM_MAX);
    float g = ((float)arc4random() / ARC4RANDOM_MAX);
    float b = ((float)arc4random() / ARC4RANDOM_MAX);
    self.view.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

@end
