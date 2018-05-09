//
//  InterstitialViewController.h
//  SASHBAmazonSample
//
//  Created by Loïc GIRON DIT METAZ on 16/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASInterstitialView.h"
#import "SASReward.h"
#import "SASBidderAdapterAmazon.h"
#import <DTBiOSSDK/DTBiOSSDK.h>

@interface InterstitialViewController : UIViewController <SASAdViewDelegate, DTBAdCallback>

@property (nonatomic, strong) SASInterstitialView *interstitial;
@property (nonatomic, assign) BOOL shouldHideStatusBar;

@end
