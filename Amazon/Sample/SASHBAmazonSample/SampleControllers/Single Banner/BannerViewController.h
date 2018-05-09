//
//  BannerViewController.h
//  SASHBAmazonSample
//
//  Created by Loïc GIRON DIT METAZ on 15/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASBannerView.h"
#import "SASBidderAdapterAmazon.h"
#import <DTBiOSSDK/DTBiOSSDK.h>

@interface BannerViewController : UIViewController <SASAdViewDelegate, DTBAdCallback>

@property (nonatomic, strong) SASBannerView *banner;

@end
