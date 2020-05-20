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
#import <DTBiOSSDK/DTBiOSSDK.h>

#define kSiteID 351387
#define kAmazonAppKey @"a9_onboarding_app_id"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    ////////////////////////////////////////////////////////
    // SMART CONFIGURATION
    ////////////////////////////////////////////////////////
    
	// The site ID must be set before using the SDK, otherwise no ad will be retrieved.
    [[SASConfiguration sharedInstance] configureWithSiteId:kSiteID];
	
	// Enabling logging can be useful to get information if ads are not displayed properly.
	// Don't forget to turn the logging OFF before submitting to the App Store.
    [SASConfiguration sharedInstance].loggingEnabled = YES;
    
    ////////////////////////////////////////////////////////
    // AMAZON CONFIGURATION
    ////////////////////////////////////////////////////////
    
    [[DTBAds sharedInstance] setAppKey: kAmazonAppKey];
    [DTBAds sharedInstance].mraidPolicy = CUSTOM_MRAID;
    [DTBAds sharedInstance].mraidCustomVersions = @[@"1.0", @"2.0", @"3.0"];
    [[DTBAds sharedInstance] setUseGeoLocation:YES];
    [[DTBAds sharedInstance] setLogLevel:DTBLogLevelOff];
    [[DTBAds sharedInstance] setTestMode:YES];
        
    ////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////
    
    
    // Init Master View Controller
	MasterViewController *masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
	
    // Navigation controller
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];

    // Root VC
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
