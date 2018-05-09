//
//  InfiniteBannerInTableViewController.m
//  ObjCSample
//
//  Created by Thomas Geley on 04/10/2016.
//  Copyright © 2016 Smart AdServer. All rights reserved.
//

#import "InfiniteBannerInTableViewController.h"
#import "SASAd.h"
#import "SASAdViewContainerCell.h"

#define kBannerRotation 20
#define kDefaultCellHeight  50

@interface InfiniteBannerInTableViewController ()
@property (nonatomic, assign) BOOL bannerIsStuckToTop;
@end

@implementation InfiniteBannerInTableViewController

#pragma mark - Object lifecycle

- (void)dealloc {
    //Make sure to remove banner from superview (especially in a tableview implementation with reused cells
    //And to make .modalParentViewController and .delegate nil also to avoid any unexpected retained references.
    [self removeBanner:_banner];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(createBanners) forControlEvents:UIControlEventValueChanged];
    
    self.title = @"Pull to refresh";
    
    // Create the banners
    [self createBanner];
}

- (void)createBanner {
    // Remove banners if exist
    [self removeBanner:_banner];
    _banner = [self createBanner:@"663530"];
}


- (SASTableBannerView *)createBanner:(NSString *) pageID {
    SASTableBannerView *banner = [[SASTableBannerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kDefaultCellHeight)];
    banner.delegate = self;
    banner.modalParentViewController = self;
    [banner loadFormatId:15140 pageId:pageID master:YES target:nil];
    
    return banner;
}


- (void)removeBanner:(SASTableBannerView *) banner {
    [banner removeFromSuperview];
    banner.modalParentViewController = nil;
    banner.delegate = nil;
    banner.loaded = NO;
}

#pragma mark - Table view data source

- (BOOL)cellAtIndexIsAdCell:(NSInteger)index {
    return (index > 0 && (index % kBannerRotation == 0));
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 500;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self cellAtIndexIsAdCell:indexPath.row]) {
        return [_banner optimalAdViewHeightForContainer:tableView];
    } else {
        return kDefaultCellHeight;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self cellAtIndexIsAdCell:indexPath.row]) {
        return [SASAdViewContainerCell cellForAdView:_banner inTableView:tableView];
    } else {
        NSString *dummyCellIdentifier = @"dummyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dummyCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dummyCellIdentifier];
        }
        cell.textLabel.text = @"Lorem ipsum dolor sit amet";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Deselect the cell if it's an ad to avoid messing with the ad creative.
    if ([self cellAtIndexIsAdCell:indexPath.row]) {
        //Ad Cell was selected, nothing to do here.
    } else {
        //Your normal behavior on cell click like pushing a new VC
        [self pushNewViewController];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (void)pushNewViewController {
    UIViewController *controller = [[UIViewController alloc] init];
    controller.navigationItem.title = @"Details";
    controller.view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:controller.view.bounds];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Detail view controller";
    [controller.view addSubview:label];
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - SASAdView delegate

- (void)adView:(SASAdView *)adView didDownloadAd:(SASAd *)ad {
    [self.tableView reloadData];
}


- (void)adViewDidLoad:(SASAdView *)adView {
    NSLog(@"Banner has been loaded");
    SASTableBannerView *banner = (SASTableBannerView *)adView;
    banner.loaded = YES;
    
    if (_banner.loaded) {
        [self.refreshControl endRefreshing];
    }
}


- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error {
    NSLog(@"Banner has failed to load with error: %@", [error description]);
    SASTableBannerView *banner = (SASTableBannerView *)adView;
    banner.loaded = YES;
    
    if (_banner.loaded) {
        [self.refreshControl endRefreshing];
    }
}


- (void)adView:(SASAdView *)adView didSendVideoEvent:(SASVideoEvent)videoEvent {
    // This delegate can be used to listen for events if the ad is a video (banner or interstitial).
    
    // For instance, you can use these events to check if the video has been played until the end
    // by listening to the event 'SASVideoEventComplete'
    
    if (videoEvent == SASVideoEventComplete) {
        NSLog(@"The video has been played until the end");
    }
}


- (void)adView:(SASAdView *)adView withStickyView:(nonnull UIView *)stuckView didStick:(BOOL)stuck withFrame:(CGRect)stickyFrame {
    //_bannerIsStuckToTop = stuck;
}


- (BOOL)adViewCanStickToTop:(nonnull SASAdView *)adView {
    return !_bannerIsStuckToTop;
}


@end
