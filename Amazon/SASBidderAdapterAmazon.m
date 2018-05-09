//
//  SASBidderAdapterAmazon.m
//  SmartAdServer
//
//  Created by Thomas Geley on 07/02/2018.
//

#import "SASBidderAdapterAmazon.h"
#import <DTBiOSSDK/DTBiOSSDK.h>

@interface SASBidderAdapterAmazon ()

// Informations to be replaced in winning ad markup
@property (nonatomic, strong) NSString *amznslots;
@property (nonatomic, strong) NSString *amzn_b;
@property (nonatomic, strong) NSString *amzn_h;

@end

@implementation SASBidderAdapterAmazon

#pragma mark - Adapter implementation

- (instancetype)initWithAmazonAdResponse:(DTBAdResponse *)adResponse pricePointsMatrix:(NSDictionary <NSString*, NSNumber*> *)pricePointsMatrix currency:(NSString *)currency {
    
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
    if ([pricePointsMatrix objectForKey:pricePoint]) {
        convertedCPM = [pricePointsMatrix objectForKey:pricePoint];
    }
    
    // No CPM found, there will be no competition
    if (!convertedCPM) {
        return nil;
    }
    
    ////////////////////////////////////////////////
    // All values are found, initialize adapter
    ////////////////////////////////////////////////
    
    self = [super initWithWinningSSPName:sspName winningCreativeID:creativeID price:[convertedCPM floatValue] currency:currency dealID:dealID];
    
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
    return @"SASBidderAdapterAmazon";
}

#pragma mark - SASBidderAdapter - Primary SDK Display

- (NSString *)bidderWinningAdMarkup {
    NSString *string = @"<div style=\"display:inline-block\">\r\n    <div id=\"__dtbAd__\" style=\"width:%%PATTERN:adWidth%%; height:%%PATTERN:adHeight%%; overflow:hidden;\">\r\n        <!--Placeholder for the Ad -->\r\n    </div>\r\n    \r\n    <script type=\"text/javascript\" src=\"https://c.amazon-adsystem.com/dtb-m.js\"></script>\r\n    <script type=\"text/javascript\">\r\n        amzn.dtb.loadAd(\"%%PATTERN:amznslots%%\", \"%%PATTERN:amzn_b%%\",\"%%PATTERN:amzn_h%%\");\r\n    </script>\r\n</div>";

    // Replace size parameters
    string = [string stringByReplacingOccurrencesOfString:@"%%PATTERN:adWidth%%" withString:self.adWidth];
    string = [string stringByReplacingOccurrencesOfString:@"%%PATTERN:adHeight%%" withString:self.adHeight];

    // Replace creative parameters
    string = [string stringByReplacingOccurrencesOfString:@"%%PATTERN:amzn_b%%" withString:self.amzn_b];
    string = [string stringByReplacingOccurrencesOfString:@"%%PATTERN:amzn_h%%" withString:self.amzn_h];
    string = [string stringByReplacingOccurrencesOfString:@"%%PATTERN:amznslots%%" withString:self.amznslots];
        
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
