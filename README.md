ios-viewcontroller-containment
==============================

A simple `UIViewController containment` implementation of something akin to the standard iOS 7 `UINavigationController` and `UIPageViewController` classes except that it supports:

- interactive gesture-based paging in both directions
- ability to enable/disable wrapping (moving from page 0 to lastIndex and back)
- ability to enable/disable parallax paging  


Usage

    ContainerViewController *containerViewController = [[ContainerViewController alloc] init];
    containerViewController.view.frame = self.window.bounds;
    [containerViewController setViewControllers:@[...];
    [self.window setRootViewController:containerViewController];

Or

    ContainerViewController *containerViewController = [[ContainerViewController alloc] init];
    containerViewController.view.frame = self.window.bounds;
    containerViewController.datasource = self;
    [containerViewController setInitialViewController:[UIViewController new]];
    [self.window setRootViewController:containerViewController];

    #pragma mark - ContainerViewController Datasource

    - (UIViewController *)containerViewController:(ContainerViewController *)container viewControllerBeforeViewController:(UIViewController *)vc
    {
        UIViewController * new = [UIViewController new];
        return new;
    }
    
    - (UIViewController *)containerViewController:(ContainerViewController *)container viewControllerAfterViewController:(UIViewController *)vc
    {
        UIViewController * new = [UIViewController new];
        return new;
    }

Configuration

    self.parallaxEnabled = YES;
    self.wrappingEnabled = YES;
    
