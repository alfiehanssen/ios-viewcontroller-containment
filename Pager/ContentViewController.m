//
//  ContentViewController.m
//  Pager
//
//  Created by Alfie Hanssen on 9/17/13.
//  Copyright (c) 2013 Alfie Hanssen. All rights reserved.
//

#import "ContentViewController.h"

#define ARC4RANDOM_MAX 0x100000000

@interface ContentViewController ()
@property (nonatomic, strong) IBOutlet UILabel * label;
@end

@implementation ContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.content = @"Default Content";
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%d", self.index];
}

//- (id)initWithContent:(NSString *)content
//{
//    self = [super init];
//    if (self) {
//        self.content = content;
//    }
//    return self;
//}

#pragma mark - View Lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    float r = ((float)arc4random() / ARC4RANDOM_MAX);
    float g = ((float)arc4random() / ARC4RANDOM_MAX);
    float b = ((float)arc4random() / ARC4RANDOM_MAX);
    self.view.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];

    int fontSize = arc4random() % 40 + 30;
    self.label.font = [UIFont boldSystemFontOfSize:fontSize];
    self.label.text = self.content;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    NSLog(@"viewWillAppear");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    NSLog(@"viewDidAppear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    NSLog(@"viewWillDisappear");
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    NSLog(@"viewDidDisappear");
}

@end
