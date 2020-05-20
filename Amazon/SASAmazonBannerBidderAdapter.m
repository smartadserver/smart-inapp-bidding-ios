//
//  SASAmazonBannerBidderAdapter.m
//  AdViewer
//
//  Created by Thomas Geley on 20/04/2020.
//  Copyright © 2020 Smart AdServer. All rights reserved.
//

#import "SASAmazonBannerBidderAdapter.h"

@interface SASAmazonBannerBidderAdapter () <DTBAdBannerDispatcherDelegate>
// Smart Integration
@property (nonatomic, weak, nullable) id <SASBannerBidderAdapterDelegate> delegate;
@property (nonatomic, strong, nullable) UIView *view;
@end

@implementation SASAmazonBannerBidderAdapter

#pragma mark - Init

- (nullable instancetype)initWithAmazonAdResponse:(DTBAdResponse *)adResponse {
     
    self = [super initWithAmazonAdResponse:adResponse];
    
    if (self) {
        // Get first returned adSize
        DTBAdSize *adSize = adResponse.adSizes.firstObject;
        if (adSize) {
            self.adWidth = adSize.width;
            self.adHeight = adSize.height;
        }
    }
    
    return self;
}

#pragma mark - Bidder SDK Mediation Rendering - Banner

- (void)loadBidderBannerAdInView:(UIView *)view delegate:(nullable id <SASBannerBidderAdapterDelegate>)delegate {
    // Store delegate
    self.delegate = delegate;
    
    //Load banner ad
    DTBAdBannerDispatcher *dispatch = [[DTBAdBannerDispatcher alloc] initWithAdFrame:CGRectMake(0,0,self.adWidth, self.adHeight) delegate:self];
    [dispatch fetchBannerAd:self.bidInfos];
}

#pragma mark - Bidder SDK Mediation Rendering - Interstitial

- (void)loadBidderInterstitialWithDelegate:(nullable id <SASInterstitialBidderAdapterDelegate>)delegate {
    // Nothing to do here, it's a banner adapter
}

- (void)showBidderInterstitialFromViewController:(UIViewController *)viewController delegate:(nullable id <SASInterstitialBidderAdapterDelegate>)delegate {
   // Nothing to do here, it's a banner adapter
}

#pragma mark - Amazon Banner Delegate

- (void)adDidLoad:(UIView *)adView {
    // No need to add to superview, this will be done by Smart Display SDK.
    
    // Transfert to delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerBidderAdapter:didLoadBanner:)]) {
        [self.delegate bannerBidderAdapter:self didLoadBanner:adView];
    }
}

- (void)adFailedToLoad:(nullable UIView *)banner errorCode:(NSInteger)errorCode {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerBidderAdapter:didFailToLoadWithError:)]) {
        NSError *error = [NSError errorWithDomain:@"SASAmazonBannerBidderAdapterErrorDomain" code:errorCode userInfo:nil];
        [self.delegate bannerBidderAdapter:self didFailToLoadWithError:error];
    }
}

- (void)bannerWillLeaveApplication:(UIView *)adView {
    // Notify delegate that a click has been received
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerBidderAdapterDidReceiveAdClickedEvent:)]) {
        [self.delegate bannerBidderAdapterDidReceiveAdClickedEvent:self];
    }
}

- (void)impressionFired {
    // Nothing to do here, impression is triggered when ad is loaded for banners
}


@end
