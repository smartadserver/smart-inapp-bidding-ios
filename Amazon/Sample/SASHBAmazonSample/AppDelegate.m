//
//  AppDelegate.m
//  SASHBAmazonSample
//
//  Created by Loïc GIRON DIT METAZ on 15/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import <SASDisplayKit/SASDisplayKit.h>
#import "SASAmazonBidderConfigManager.h"
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
    [[SASConfiguration sharedInstance] configureWithSiteId:kSiteID baseURL:kBaseURL];
	
	// Enabling logging can be useful to get information if ads are not displayed properly.
	// Don't forget to turn the logging OFF before submitting to the App Store.
    [SASConfiguration sharedInstance].loggingEnabled = YES;
    
    ////////////////////////////////////////////////////////
    // SMART AMAZON BIDDER CONFIGURATION
    ////////////////////////////////////////////////////////
    
    // Fetch JSON Amazon config (price points, creative tag and currency code) for this network
    [[SASAmazonBidderConfigManager sharedInstance] configureWithURL:[NSURL URLWithString:@"https://mobile.smartadserver.com/ac?siteid=104808&pgid=1005469&fmtid=15140"]];
    
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
