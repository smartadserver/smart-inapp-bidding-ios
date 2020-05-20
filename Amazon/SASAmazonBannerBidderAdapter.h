//
//  SASAmazonBannerBidderAdapter.h
//  AdViewer
//
//  Created by Thomas Geley on 20/04/2020.
//  Copyright © 2020 Smart AdServer. All rights reserved.
//

#import "SASAmazonBaseBidderAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface SASAmazonBannerBidderAdapter : SASAmazonBaseBidderAdapter

/// The width of the ad.
@property (nonatomic, assign) float adWidth;

/// The height of the ad.
@property (nonatomic, assign) float adHeight;

@end

NS_ASSUME_NONNULL_END
