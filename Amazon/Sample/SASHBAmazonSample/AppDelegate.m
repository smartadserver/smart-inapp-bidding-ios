//
//  AppDelegate.m
//  SASHBAmazonSample
//
//  Created by Loïc GIRON DIT METAZ on 15/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "SASAdView.h"
#import <DTBiOSSDK/DTBiOSSDK.h>

#define kSiteID 104808
#define kBaseURL @"https://mobile.smartadserver.com"
#define kAmazonAppKey @"4852afca9a904e46a680b34b7f0aab8f"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    ////////////////////////////////////////////////////////
    // SMART CONFIGURATION
    ////////////////////////////////////////////////////////
    
	// The site ID and the base URL must be set before using the SDK, otherwise no ad will be retrieved.
	[SASAdView setSiteID:kSiteID baseURL:kBaseURL];
	
	// Enabling logging can be useful to get information if ads are not displayed properly.
	// Don't forget to turn the logging OFF before submitting to the App Store.
	[SASAdView setLoggingEnabled:YES];
    
    ////////////////////////////////////////////////////////
    // AMAZON CONFIGURATION
    ////////////////////////////////////////////////////////
    
    // Amazon SDK configuration for the in-app bidding
    [[DTBAds sharedInstance] setAppKey:kAmazonAppKey];
    [[DTBAds sharedInstance] setUseGeoLocation:YES];
    [[DTBAds sharedInstance] setLogLevel:DTBLogLevelAll];
    [[DTBAds sharedInstance] setTestMode:YES];
    
    
    ////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////
    
    
    // Init Master View Controller
	MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
	
    // Navigation controller
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    [[UINavigationBar appearance] setBarTintColor: [UIColor colorWithRed:117./255 green:209./255. blue:180./255. alpha:1]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];

    // Root VC
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
