//
//  BannerViewController.m
//  SASHBAmazonSample
//
//  Created by Loïc GIRON DIT METAZ on 23/10/2018.
//  Copyright (c) 2018 Smart AdServer. All rights reserved.
//

#import "BannerViewController.h"

/**
 * The purpose of this sample is to display a simple banner using in-app bidding with Amazon.
 */
@implementation BannerViewController

#pragma mark - Controller Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		self.title = @"Banner";
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
	
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	[self loadAmazonBanner];
	[self createReloadButton];
}


- (void)createReloadButton {
	UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStylePlain target:self action:@selector(reload)];
    reloadButton.accessibilityLabel = @"reloadButton";
	self.navigationItem.rightBarButtonItem = reloadButton;
}

#pragma mark - Banner Action

- (void)reload {
    if (self.banner) {
        self.banner.delegate = nil;
        self.banner.modalParentViewController = nil;
        [self.banner removeFromSuperview];
    }
    
    // Perform a request to amazon first so that bidding competition can happen when asking Smart for a banner
	[self loadAmazonBanner];
}

#pragma mark - Amazon Ad Loading

- (void)loadAmazonBanner {
    // Banner size
    CGSize bannerSize = CGSizeMake(300, 250);
    
    // Create an Ad size to be loaded from Amazon
    NSString *slotUUID = @"591e251f-3854-4777-89bb-d545fb71e341"; // Replace with your own slotUUID
    DTBAdSize *size = [[DTBAdSize alloc] initBannerAdSizeWithWidth:bannerSize.width height:bannerSize.height andSlotUUID:slotUUID];
    
    // Create an Amazon Ad Loader
    DTBAdLoader *adLoader = [DTBAdLoader new];
    [adLoader setSizes:size, nil];
    
    // Load Amazon Ad with self as the delegate
    [adLoader loadAd:self];
}

#pragma mark - Amazon delegate

- (void)onSuccess:(DTBAdResponse *)adResponse {
    NSLog(@"Amazon received an ad response");
    
    // If the third party SDK can load an ad, the response must be converted into a valid bidder adapter and then
    // provided to the Smart SDK so the Bidding competition can take place server side.
    // Here we generate an adapter from Amazon response
    SASAmazonBidderAdapter *amazonAdapter = [self adapterForResponse:adResponse];
    
    // Load Smart ad and passing the amazon adapter so competition can occur server side
    [self loadSmartBanner:amazonAdapter];
}


- (void)onFailure:(DTBAdError)error {
    NSLog(@"Amazon failed to load with error: %d", error);
    
    // If the third party SDK cannot load any ad, Smart SDK can still be called as usual.
    // Without bidder adapter: no bidding competition will be used.
    [self loadSmartBanner:nil];
}


#pragma mark - Smart Ad Loading

- (void)loadSmartBanner:(SASAmazonBidderAdapter *)bidderAdapter {
    // Initialize Smart's banner
    self.banner = [[SASBannerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 250) loader:SASLoaderActivityIndicatorStyleWhite];
    self.banner.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.banner.delegate = self;
    self.banner.modalParentViewController = self;
    
    // Set correct size on the adapter for display to occur properly if Amazon wins the bidding competition
    if (bidderAdapter) {
        bidderAdapter.adWidth = [NSString stringWithFormat:@"%0.fpx", self.banner.frame.size.width];
        bidderAdapter.adHeight = [NSString stringWithFormat:@"%0.fpx", self.banner.frame.size.height];
    }
    
    // Load Smart's banner, passing the bidderAdapter that will forward the Amazon's creative price to Smart Ad Server
    [self.banner loadWithPlacement:[SASAdPlacement adPlacementWithSiteId:104808 pageId:936820 formatId:15140] bidderAdapter:bidderAdapter];

    // The placement used here will has an insertion with a €0.50 CPM.
    // In this case, Amazon will win if the CPM of the returned creative if higher.
    [self.view addSubview:self.banner];
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

#pragma mark - SASAdView Delegate

- (void)bannerViewDidLoad:(SASBannerView *)bannerView {
    NSLog(@"Smart banner has been loaded");
}

- (void)bannerView:(SASBannerView *)bannerView didFailToLoadWithError:(NSError *)error {
    NSLog(@"Smart banner has failed to load with error: %@", [error description]);
}

@end
