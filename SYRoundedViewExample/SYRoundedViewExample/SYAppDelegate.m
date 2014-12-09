//
//  SYAppDelegate.m
//  SYRoundedViewExample
//
//  Created by rominet on 07/12/14.
//  Copyright (c) 2014 Syan.me. All rights reserved.
//

#import "SYAppDelegate.h"
#import "SYViewController.h"

@interface SYAppDelegate ()

@end

@implementation SYAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_window setBackgroundColor:[UIColor whiteColor]];
    [_window.layer setMasksToBounds:YES];
    [_window.layer setOpaque:NO];
    [_window setRootViewController:[[SYViewController alloc] init]];
    [_window makeKeyAndVisible];

    return YES;
}

@end
