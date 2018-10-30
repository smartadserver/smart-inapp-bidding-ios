//
//  InterstitialViewController.m
//  SASHBAmazonSample
//
//  Created by Loïc GIRON DIT METAZ on 23/10/2018.
//  Copyright (c) 2018 Smart AdServer. All rights reserved.
//

#import "InterstitialViewController.h"

/**
 * The purpose of this sample is to display a simple interstitial using in-app bidding with Amazon.
 */
@implementation InterstitialViewController

#pragma mark - Controller Lifecycle

- (void)dealloc {
    // Reset interstitial delegate and modalParentViewController
    self.interstitial.delegate = nil;
    self.interstitial.modalParentViewController = nil;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		self.title = @"Interstitial";
    }
	
    return self;
}

#pragma mark - Interstitial Load Logic

- (IBAction)loadPlacement:(id)sender {
    self.interstitial.delegate = nil;
    self.interstitial.modalParentViewController = nil;
	
    // Perform a request to amazon first so that bidding competition can happen when asking Smart for an interstitial
	[self loadAmazonInterstitial];
}


- (void)loadAmazonInterstitial {
    // Interstitial Size
    NSString *slotUUID = @"3b7de139-bc75-4502-a9c7-69b496f3be90"; // Replace with your own slotUUID
    DTBAdSize *size = [[DTBAdSize alloc] initInterstitialAdSizeWithSlotUUID:slotUUID];
    
    // Create Amazon Ad Loader
    DTBAdLoader *adLoader = [DTBAdLoader new];
    [adLoader setSizes:size, nil];
    
    // Load the Amazon ad with self as the delegate
    [adLoader loadAd:self];
}

#pragma mark - Amazon delegate

- (void)onSuccess:(DTBAdResponse *)adResponse {
    NSLog(@"Amazon received an ad response");
    
    // If the third party SDK can load an ad, the response must be converted into a valid bidder adapter and then
    // provided to the Smart SDK so the Bidding competition can take place server side.
    // Here we generate an adapter from Amazon response
    [self loadSmartInterstitial:[self adapterForResponse:adResponse]];
}


- (void)onFailure:(DTBAdError)error {
    NSLog(@"Amazon failed to load with error: %d", error);
    
    // If the third party SDK cannot load any ad, Smart SDK can still be called as usual.
    // Without bidder adapter: no bidding competition will be used.
    [self loadSmartInterstitial:nil];
}

#pragma mark - Smart Ad Loading

- (void)loadSmartInterstitial:(SASAmazonBidderAdapter *)bidderAdapter {
    // Initialize Smart's interstitial
	self.interstitial = [[SASInterstitialView alloc] initWithFrame:self.navigationController.view.bounds loader:SASLoaderActivityIndicatorStyleBlack];
    self.interstitial.delegate = self;
    self.interstitial.modalParentViewController = self;
    [self.interstitial loadFormatId:15140 pageId:@"936821" master:YES target:nil bidderAdapter:bidderAdapter];
    
    // The placement used here will always have an insertion with a €0.50 CPM.
    // In this case, it will be easy to predict who will win using the Amazon ad response.	
	[self.navigationController.view addSubview:self.interstitial];
	[self setStatusBarHidden:YES];
}

#pragma mark - Bidder initialization

- (SASAmazonBidderAdapter *)adapterForResponse:(DTBAdResponse *)response {
    if (!response) {
        return nil;
    }
    
    // Process DTB response
    SASAmazonBidderAdapter *adapter = [[SASAmazonBidderAdapter alloc] initWithAmazonAdResponse:response];
    
    return adapter;
}

#pragma mark - SASAdView delegate

- (void)adViewDidLoad:(SASAdView *)adView {
	NSLog(@"Interstitial has been loaded");
	[self setStatusBarHidden:YES];
}


- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error {
	NSLog(@"Interstitial has failed to load with error: %@", [error description]);
	[self setStatusBarHidden:NO];
}


- (void)adViewDidDisappear:(SASAdView *)adView {
	NSLog(@"Interstitial has disappeared");
	[self setStatusBarHidden:NO];
}

#pragma mark - iOS 7 status bar handling

- (void)setStatusBarHidden:(BOOL)hidden {
	self.shouldHideStatusBar = hidden;
	if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
		[self setNeedsStatusBarAppearanceUpdate];
	}
}

- (BOOL)prefersStatusBarHidden {
	return self.shouldHideStatusBar || [super prefersStatusBarHidden];
}

@end
