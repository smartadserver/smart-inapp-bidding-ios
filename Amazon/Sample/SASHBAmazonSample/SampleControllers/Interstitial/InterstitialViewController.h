//
//  InterstitialViewController.h
//  SASHBAmazonSample
//
//  Created by Loïc GIRON DIT METAZ on 23/10/2018.
//  Copyright (c) 2018 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASInterstitialView.h"
#import "SASReward.h"
#import "SASAmazonBidderAdapter.h"
#import <DTBiOSSDK/DTBiOSSDK.h>

@interface InterstitialViewController : UIViewController <SASAdViewDelegate, DTBAdCallback>

@property (nonatomic, strong) SASInterstitialView *interstitial;
@property (nonatomic, assign) BOOL shouldHideStatusBar;

@end
