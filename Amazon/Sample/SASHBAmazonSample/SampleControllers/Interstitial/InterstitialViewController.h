//
//  InterstitialViewController.h
//  SASHBAmazonSample
//
//  Created by Loïc GIRON DIT METAZ on 23/10/2018.
//  Copyright (c) 2018 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SASDisplayKit/SASDisplayKit.h>
#import <SASDisplayKit/SASDisplayKit.h>
#import "SASAmazonBidderAdapter.h"
#import <DTBiOSSDK/DTBiOSSDK.h>

@interface InterstitialViewController : UIViewController <SASInterstitialManagerDelegate, DTBAdCallback>

@property (nonatomic, strong) SASInterstitialManager *interstitialManager;
@property (nonatomic, assign) BOOL shouldHideStatusBar;

@end
