//
//  BannerViewController.h
//  SASHBAmazonSample
//
//  Created by Loïc GIRON DIT METAZ on 23/10/2018.
//  Copyright (c) 2018 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASBannerView.h"
#import "SASAmazonBidderAdapter.h"
#import <DTBiOSSDK/DTBiOSSDK.h>

@interface BannerViewController : UIViewController <SASAdViewDelegate, DTBAdCallback>

@property (nonatomic, strong) SASBannerView *banner;

@end
