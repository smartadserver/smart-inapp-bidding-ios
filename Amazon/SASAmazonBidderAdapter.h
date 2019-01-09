//
//  SASAmazonBidderAdapter.h
//  SmartAdServer
//
//  Created by Thomas Geley on 07/02/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SASDisplayKit/SASDisplayKit.h>

@class DTBAdResponse;

NS_ASSUME_NONNULL_BEGIN

/**
 Amazon bidder adapter that must be provided to Smart SDK to leverage its in-app bidding feature.
 */
@interface SASAmazonBidderAdapter : SASBidderAdapter

/// The width of the ad.
@property (nonatomic, strong) NSString *adWidth;

/// The height of the ad.
@property (nonatomic, strong) NSString *adHeight;

/**
 Instantiate a new instance of SASAmazonBidderAdapter using a valid Amazon ad response.
 
 @note This initializer method might fail depending of the status of the ad response
 and the SASAmazonBidderConfigManager class. You must handle this case properly.
 
 @param adResponse A valid Amazon ad response.
 @return An initialized SASAmazonBidderAdapter instance if possible, nil otherwise.
 */
- (nullable instancetype)initWithAmazonAdResponse:(DTBAdResponse *)adResponse;

@end

NS_ASSUME_NONNULL_END
