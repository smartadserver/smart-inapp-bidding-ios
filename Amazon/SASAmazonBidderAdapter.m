//
//  SASAmazonBidderAdapter.m
//  SmartAdServer
//
//  Created by Thomas Geley on 07/02/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAmazonBidderAdapter.h"
#import "SASAmazonBidderConfigManager.h"
#import <DTBiOSSDK/DTBiOSSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface SASAmazonBidderAdapter ()

// Informations to be replaced in winning ad markup
@property (nonatomic, strong) NSString *amznslots;
@property (nonatomic, strong) NSString *amzn_b;
@property (nonatomic, strong) NSString *amzn_h;

@end

@implementation SASAmazonBidderAdapter

#pragma mark - Adapter implementation

- (nullable instancetype)initWithAmazonAdResponse:(DTBAdResponse *)adResponse {
    
    // Checking if the configuration is ready
    if (![SASAmazonBidderConfigManager sharedInstance].isReady) {
        // if not ready, trigger a refresh and stop the loading…
        [[SASAmazonBidderConfigManager sharedInstance] refresh];
        return nil;
    }
    
    // Checking if the configuration is expired
    if ([SASAmazonBidderConfigManager sharedInstance].isExpired) {
        // in this case, a refresh is triggered but the old configuration can still be used…
        [[SASAmazonBidderConfigManager sharedInstance] refresh];
    }
    
    // If no adSizes in the adResponse, return nil, there is no winning ad.
    if ([adResponse.adSizes count] == 0) {
        return nil;
    }
    
    ///////////////////////////////////////////
    // Find values for super initialization
    ///////////////////////////////////////////
    
    NSString *sspName = @"Amazon"; // Use "Amazon" as SSP name since amazon will never return the real name of the winning ssp.
    NSString *creativeID = adResponse.bidId; // Use bidId as identifier.
    NSString *dealID = nil; // No dealID set
    
    // Get first returned adSize
    DTBAdSize *adSize = adResponse.adSizes.firstObject;
    
    // Get price point for this ad and convert it to a CPM for Holistic+ competition to be possible
    NSString *pricePoint = [adResponse pricePoints:adSize];
    NSNumber *convertedCPM = nil;
    if ([[SASAmazonBidderConfigManager sharedInstance].pricePointsMatrix objectForKey:pricePoint]) {
        convertedCPM = [[SASAmazonBidderConfigManager sharedInstance].pricePointsMatrix objectForKey:pricePoint];
    }
    
    // No CPM found, there will be no competition
    if (!convertedCPM) {
        return nil;
    }
    
    ////////////////////////////////////////////////
    // All values are found, initialize adapter
    ////////////////////////////////////////////////
    
    self = [super initWithWinningSSPName:sspName winningCreativeID:creativeID price:[convertedCPM floatValue] currency:[SASAmazonBidderConfigManager sharedInstance].currency dealID:dealID];
    
    if (self) {
        
        // Retrieve size parameters
        if (adSize) {
            if (adSize.width >= 9999 && adSize.height >= 9999) { // Interstitial
                self.adWidth = @"100%";
                self.adHeight = @"auto";
            } else { // Banner
                self.adWidth = [NSString stringWithFormat:@"%ldpx", (long)adSize.width];
                self.adHeight = [NSString stringWithFormat:@"%ldpx", (long)adSize.height];
            }
        }
        
        // Fill creative parameters
        NSDictionary *customTargeting = [adResponse customTargetting];
        self.amzn_h = [customTargeting objectForKey:@"amzn_h"];
        self.amzn_b = [customTargeting objectForKey:@"amzn_b"];
        self.amznslots = [customTargeting objectForKey:@"amznslots"];
    }
    
    return self;
}

#pragma mark - SASBidderAdapter Protocol
#pragma mark - SASBidderAdapter informations

- (SASBidderAdapterCreativeRenderingType)creativeRenderingType {
    // Primary SDK is responsible for the rendering of the winning ad.
    return SASBidderAdapterCreativeRenderingTypePrimarySDK;
}


- (NSString *)adapterName {
    // SAS defined name for this adapter. You may change it went creating your own adapter.
    return @"SASAmazonBidderAdapter";
}

#pragma mark - SASBidderAdapter - Primary SDK Display

- (NSString *)bidderWinningAdMarkup {
    NSString *string = [SASAmazonBidderConfigManager sharedInstance].adMarkup;

    // Replace size parameters
    string = [string stringByReplacingOccurrencesOfString:@"%%KEYWORD:adWidth%%" withString:self.adWidth];
    string = [string stringByReplacingOccurrencesOfString:@"%%KEYWORD:adHeight%%" withString:self.adHeight];

    // Replace creative parameters
    string = [string stringByReplacingOccurrencesOfString:@"%%KEYWORD:amzn_b%%" withString:self.amzn_b];
    string = [string stringByReplacingOccurrencesOfString:@"%%KEYWORD:amzn_h%%" withString:self.amzn_h];
    string = [string stringByReplacingOccurrencesOfString:@"%%KEYWORD:amznslots%%" withString:self.amznslots];
        
    return string;
}


- (void)primarySDKDisplayedBidderAd {
    // Nothing to do here unless you want to count impressions on your side.
    NSLog(@"Primary SDK Displayed Bidder Ad");
}


- (void)primarySDKClickedBidderAd {
    // Nothing to do here unless you want to count clicks on your side.
    NSLog(@"Primary SDK Clicked Bidder Ad");
}

#pragma mark - SASBidderAdapter - Third party SDK Display

- (void)primarySDKLostBidCompetition {
    // Nothing to do here, primary SDK is responsible for creative display and will get the bidderWinningAdMarkup.
    NSLog(@"Primary SDK Lost Bid competition");
}

@end

NS_ASSUME_NONNULL_END
