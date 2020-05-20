//
//  SASAmazonInterstitialBidderAdapter.m
//  AdViewer
//
//  Created by Thomas Geley on 20/04/2020.
//  Copyright © 2020 Smart AdServer. All rights reserved.
//

#import "SASAmazonInterstitialBidderAdapter.h"

@interface SASAmazonInterstitialBidderAdapter () <DTBAdInterstitialDispatcherDelegate>
// Smart Integration
@property (nonatomic, weak, nullable) id <SASInterstitialBidderAdapterDelegate> delegate;
@property (nonatomic, strong, nullable) UIViewController *viewController;
@property (nonatomic, strong, nullable) DTBAdInterstitialDispatcher *interstitialDispatcher;
@end

@implementation SASAmazonInterstitialBidderAdapter

#pragma mark - Bidder SDK Mediation Rendering - Banner

- (void)loadBidderBannerAdInView:(UIView *)view delegate:(nullable id <SASBannerBidderAdapterDelegate>)delegate {
    // Nothing to do here, it is an interstitial
}

#pragma mark - Bidder SDK Mediation Rendering - Interstitial

- (void)loadBidderInterstitialWithDelegate:(nullable id <SASInterstitialBidderAdapterDelegate>)delegate {
    self.delegate = delegate;
    
    self.interstitialDispatcher = [[DTBAdInterstitialDispatcher alloc] initWithDelegate:self];
    [self.interstitialDispatcher fetchAd:self.bidInfos];
}

- (void)showBidderInterstitialFromViewController:(UIViewController *)viewController delegate:(nullable id <SASInterstitialBidderAdapterDelegate>)delegate {
    self.viewController = viewController;
    self.delegate = delegate;
    
    [self.interstitialDispatcher showFromController:viewController];
}

- (BOOL)isInterstitialAdReady {
    if (self.interstitialDispatcher) {
        return self.interstitialDispatcher.interstitialLoaded;
    }
    return NO;
}

#pragma mark - Amazon Interstitial Delegate

/// Sent when an interstitial ad has loaded.
- (void)interstitialDidLoad:(nullable DTBAdInterstitialDispatcher *)interstitial {
    // Notify delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialBidderAdapterDidLoad:)]) {
        [self.delegate interstitialBidderAdapterDidLoad:self];
    }
}

- (void)interstitial:(nullable DTBAdInterstitialDispatcher *)interstitial didFailToLoadAdWithErrorCode:(DTBAdErrorCode)errorCode {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerBidderAdapter:didFailToLoadWithError:)]) {
        NSError *error = [NSError errorWithDomain:@"SASAmazonInterstitialBidderAdapterErrorDomain" code:errorCode userInfo:nil];
        [self.delegate interstitialBidderAdapter:self didFailToLoadWithError:error];
    }
}

- (void)interstitialWillPresentScreen:(nullable DTBAdInterstitialDispatcher *)interstitial {
    // No equivalent on Smart Display SDK
}

- (void)interstitialDidPresentScreen:(nullable DTBAdInterstitialDispatcher *)interstitial {
    // Notify Delegate
     if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialBidderAdapterDidShow:)]) {
        [self.delegate interstitialBidderAdapterDidShow:self];
    }
}

- (void)interstitialWillDismissScreen:(nullable DTBAdInterstitialDispatcher *)interstitial {
    // No equivalent on Smart Display SDK
}

- (void)interstitialDidDismissScreen:(nullable DTBAdInterstitialDispatcher *)interstitial {
    // Notify delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialBidderAdapterDidClose:)]) {
        [self.delegate interstitialBidderAdapterDidClose:self];
    }
}

- (void)interstitialWillLeaveApplication:(nullable DTBAdInterstitialDispatcher *)interstitial {
    // Notify delegate that a click has been received
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialBidderAdapterDidReceiveAdClickedEvent:)]) {
        [self.delegate interstitialBidderAdapterDidReceiveAdClickedEvent:self];
    }
}

- (void)showFromRootViewController:(UIViewController *)controller {
    // Useless? Bug?
}

- (void)impressionFired {
    // Impression is triggered on show by Smart Display SDK
}

@end
