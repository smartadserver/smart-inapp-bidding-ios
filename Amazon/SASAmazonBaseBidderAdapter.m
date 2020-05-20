//
//  SASBaseAmazonBidderAdapter.m
//  AdViewer
//
//  Created by Thomas Geley on 20/04/2020.
//  Copyright © 2020 Smart AdServer. All rights reserved.
//

#import "SASAmazonBaseBidderAdapter.h"

@implementation SASAmazonBaseBidderAdapter

#pragma mark - Adapter implementation

- (nullable instancetype)initWithAmazonAdResponse:(DTBAdResponse *)adResponse {
     
    // If no adSizes in the adResponse, return nil, there is no winning ad.
    if ([adResponse.adSizes count] == 0) {
        return nil;
    }
    
    ///////////////////////////////////////////
    // Find values for super initialization
    ///////////////////////////////////////////
    
    NSString *sspName = @"Amazon"; // Use "Amazon" as SSP name since amazon will never return the real name of the winning ssp.
    NSString *creativeID = adResponse.bidId; // Use bidId as identifier.

    // Retrieve targetingInfos
    NSDictionary *customTargeting = [adResponse customTargeting];
    NSString *slot = [customTargeting objectForKey:@"amznslots"];
    if (!slot) {
        return nil;
    }
    NSString *keyword = [NSString stringWithFormat:@"amznslots=%@", slot];
    
    ////////////////////////////////////////////////
    // All values are found, initialize adapter
    ////////////////////////////////////////////////
    
    self = [super initWithWinningSSPName:sspName winningCreativeID:creativeID keyword:keyword dealID:nil];
    
    if (self) {
        // Fill ad response parameters
        self.amzn_h = [customTargeting objectForKey:@"amzn_h"];
        self.amzn_b = [customTargeting objectForKey:@"amzn_b"];
        self.amznslots = [customTargeting objectForKey:@"amznslots"];
        self.bidInfos = adResponse.bidInfo;
    }
    
    return self;
}

#pragma mark - SASBidderAdapter Protocol

#pragma mark - SASBidderAdapter informations

- (SASBidderAdapterCreativeRenderingType)creativeRenderingType {
    // Amazon SDK is responsible for the rendering of the winning ad.
    return SASBidderAdapterCreativeRenderingTypeMediation;
}

- (SASBidderAdapterCompetitionType)competitionType {
    // Competition is based on keyword for insertion selection
    return SASBidderAdapterCompetitionTypeKeyword;
}

- (NSString *)adapterName {
    // SAS defined name for this adapter. You may change it went creating your own adapter.
    return @"Amazon";
}

#pragma mark - Win notification callback

- (void)primarySDKLostBidCompetition {
    NSLog(@"SASBaseAmazonBidderAdapter: Primary SDK Lost Bid Competition, we will render the client-side bidding ad.");
}

#pragma mark - Smart Display SDK Creative Rendering

- (NSString *)bidderWinningAdMarkup {
    // Nothing to return here, it is a SASBidderAdapterCreativeRenderingTypeMediation rendering
    return nil;
}

- (void)primarySDKDisplayedBidderAd {
    // Nothing to do here, it is a SASBidderAdapterCreativeRenderingTypeMediation rendering
}


- (void)primarySDKClickedBidderAd {
    // Nothing to do here, it is a SASBidderAdapterCreativeRenderingTypeMediation rendering
}

#pragma mark - Third party Creative Rendering

- (void)primarySDKRequestedThirdPartyRendering {
    // Nothing to do here, it is a SASBidderAdapterCreativeRenderingTypeMediation rendering
}

#pragma mark - Bidder SDK Mediation Rendering - Banner

- (void)loadBidderBannerAdInView:(UIView *)view delegate:(nullable id <SASBannerBidderAdapterDelegate>)delegate {
    NSAssert(NO, @"- [SASBaseAmazonBidderAdapter loadBidderBannerAdInView:delegate:] method must be overriden!");
}

#pragma mark - Bidder SDK Mediation Rendering - Interstitial

- (void)loadBidderInterstitialWithDelegate:(nullable id <SASInterstitialBidderAdapterDelegate>)delegate {
    NSAssert(NO, @"- [SASBaseAmazonBidderAdapter loadBidderInterstitialWithDelegate:] method must be overriden!");
}

- (void)showBidderInterstitialFromViewController:(UIViewController *)viewController delegate:(nullable id <SASInterstitialBidderAdapterDelegate>)delegate{
    NSAssert(NO, @"- [SASBaseAmazonBidderAdapter showBidderInterstitialFromViewController:delegate:] method must be overriden!");
}

- (BOOL)isInterstitialAdReady {
     NSAssert(NO, @"- [SASBidderAdapter isInterstitialAdReady] method must be overriden!");
    return NO;
}

@end
