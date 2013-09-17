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
@property (nonatomic, strong) NSString * content;
@end

@implementation ContentViewController

- (id)initWithContent:(NSString *)content
{
    self = [super init];
    if (self) {
        self.content = content;
    }
    return self;
}

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
    self.view.alpha = 0.75f;

    UILabel * label = [[UILabel alloc] initWithFrame:self.view.bounds];
    int fontSize = arc4random() % 40 + 30;
    label.font = [UIFont boldSystemFontOfSize:fontSize];
    label.text = self.content;
    NSDictionary * attributes = @{NSFontAttributeName:label.font};
    CGSize size = [label.text sizeWithAttributes:attributes];
    label.frame = (CGRect){0, 0, size};
    label.center = self.view.center;
    [self.view addSubview:label];
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
