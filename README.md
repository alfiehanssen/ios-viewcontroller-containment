ios-viewcontroller-containment
==============================

A simple `UIViewController` containment implementation of something akin to the standard iOS 7 `UINavigationController` and `UIPageViewController` classes except that it supports:

- interactive gesture-based paging in both directions
- ability to enable/disable wrapping (moving from page 0 to lastIndex and back)
- ability to enable/disable parallax paging  

Usage #1

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        ContainerViewController *containerViewController = [ContainerViewController new];
        containerViewController.view.frame = self.window.bounds;
        [containerViewController setViewControllers:@[...];
        [self.window setRootViewController:containerViewController];
        
        [self.window makeKeyAndVisible];
    
        return YES;
    }
Usage #2

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        ContainerViewController *containerViewController = [ContainerViewController new];
        containerViewController.view.frame = self.window.bounds;
        containerViewController.datasource = self;
        [containerViewController setInitialViewController:[UIViewController new]];
        [self.window setRootViewController:containerViewController];
        
        [self.window makeKeyAndVisible];
    
        return YES;
    }
    
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
    
TODO:

- There's a lot of duplicate logic in the finish and cancelTransition code, this should be anstracted & condensed
