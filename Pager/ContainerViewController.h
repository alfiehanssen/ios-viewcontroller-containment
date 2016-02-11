//
//  ContainerViewController.h
//  Pager
//
//  Created by Alfie Hanssen on 9/17/13.
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

#import <UIKit/UIKit.h>

@protocol ContainerViewControllerDatasource <NSObject>

@required
- (UIViewController *)containerViewController:(UIViewController *)container viewControllerBeforeViewController:(UIViewController *)vc;
- (UIViewController *)containerViewController:(UIViewController *)container viewControllerAfterViewController:(UIViewController *)vc;

@end

@interface ContainerViewController : UIViewController

@property (nonatomic, assign) BOOL parallaxEnabled; // default = ON
@property (nonatomic, assign) BOOL wrappingEnabled; // default = OFF, Only applicable when initializing with setViewControllers:

@property (nonatomic, weak) id<ContainerViewControllerDatasource> datasource;

@property (nonatomic, strong, readonly) UIViewController *currentViewController;

- (void)setInitialViewController:(UIViewController *)vc;
- (void)setViewControllers:(NSMutableArray *)viewControllers;

@end
