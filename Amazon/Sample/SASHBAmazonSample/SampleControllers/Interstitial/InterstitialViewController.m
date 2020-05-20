//
//  InterstitialViewController.m
//  SASHBAmazonSample
//
//  Created by Loïc GIRON DIT METAZ on 23/10/2018.
//  Copyright (c) 2018 Smart AdServer. All rights reserved.
//

#import "InterstitialViewController.h"
#import "SASAmazonInterstitialBidderAdapter.h"

#define kAmazonInterstitialUUID     @"6b964bfb-6c2c-4589-a049-23ecaada4f52"
#define kSASSiteId                  351387
#define kSASPageId                  1231282
#define kSASFormatId                90739

/**
 * The purpose of this sample is to display a simple interstitial using in-app bidding with Amazon.
 */
@implementation InterstitialViewController

#pragma mark - Controller Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		self.title = @"Interstitial";
    }
	
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self activateShowButton:NO];
}

#pragma mark - Interstitial Load Logic

- (IBAction)loadPlacement:(id)sender {
    // Cleaning old interstitial manager
    self.interstitialManager.delegate = nil;
    
    // Perform a request to Amazon SDK first so that bidding competition can happen when asking Smart for an interstitial
	[self loadAmazonInterstitial];
}

- (void)loadAmazonInterstitial {
    // Interstitial Size
    NSString *slotUUID = kAmazonInterstitialUUID; // Replace with your own slotUUID
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
    
    // If the bidding SDK can load an ad, the response must be converted into a valid bidder adapter and then
    // provided to Smart Display SDK so the Bidding competition can take place server side.
    // Here we generate an adapter from Amazon response
    [self loadSmartInterstitial:[self adapterForResponse:adResponse]];
}


- (void)onFailure:(DTBAdError)error {
    NSLog(@"Amazon failed to load with error: %d", error);
    
    // If the bidding SDK cannot load any ad, Smart Display SDK can still be called as usual.
    // Without bidder adapter: no bidding competition will be used.
    [self loadSmartInterstitial:nil];
}

#pragma mark - Smart Ad Loading

- (void)loadSmartInterstitial:(SASAmazonInterstitialBidderAdapter *)bidderAdapter {
    // Initialize Smart's interstitial
    SASAdPlacement *adPlacement = [SASAdPlacement adPlacementWithSiteId:kSASSiteId pageId:kSASPageId formatId:kSASFormatId];
    self.interstitialManager = [[SASInterstitialManager alloc] initWithPlacement:adPlacement delegate:self];
    [self.interstitialManager loadWithBidderAdapter:bidderAdapter];
}

#pragma mark - Bidder initialization

- (SASAmazonInterstitialBidderAdapter *)adapterForResponse:(DTBAdResponse *)response {
    if (!response) {
        return nil;
    }
    
    // Process DTB response
    return [[SASAmazonInterstitialBidderAdapter alloc] initWithAmazonAdResponse:response];
}

#pragma mark - SASAdView delegate

- (void)interstitialManager:(SASInterstitialManager *)manager didLoadAd:(SASAd *)ad {
    if (manager == self.interstitialManager) {
        NSLog(@"Interstitial ad has been loaded");
        [self activateShowButton:YES];
    }
}

- (void)interstitialManager:(SASInterstitialManager *)manager didFailToLoadWithError:(NSError *)error {
    if (manager == self.interstitialManager) {
        NSLog(@"Interstitial ad did fail to load: %@", error);
    }
}

- (void)interstitialManager:(SASInterstitialManager *)manager didFailToShowWithError:(NSError *)error {
    if (manager == self.interstitialManager) {
        NSLog(@"Interstitial ad did fail to show: %@", error);
    }
}

- (void)interstitialManager:(SASInterstitialManager *)manager didAppearFromViewController:(UIViewController *)viewController {
    if (manager == self.interstitialManager) {
        NSLog(@"Interstitial ad did appear");
        [self activateShowButton:NO];
    }
}

- (void)interstitialManager:(SASInterstitialManager *)manager didDisappearFromViewController:(UIViewController *)viewController {
    if (manager == self.interstitialManager) {
        NSLog(@"Interstitial ad did disappear");
    }
}

#pragma mark - Show logic

- (IBAction)showInterstitial:(id)sender {
    if (self.interstitialManager) {
        [self.interstitialManager showFromViewController:self];
    }
}

- (void)activateShowButton:(BOOL)activate {
    if (activate) {
        self.showButton.enabled = YES;
        self.showButton.hidden = FALSE;
    } else {
        self.showButton.enabled = NO;
        self.showButton.hidden = YES;
    }
}

@end
