//
//  SASBaseAmazonBidderAdapter.h
//  AdViewer
//
//  Created by Thomas Geley on 20/04/2020.
//  Copyright © 2020 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SASDisplayKit/SASDisplayKit.h>
#import <DTBiOSSDK/DTBiOSSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface SASAmazonBaseBidderAdapter : SASBidderAdapter

// Amazon Details
@property (nonatomic, strong) NSString *amznslots;
@property (nonatomic, strong) NSString *amzn_b;
@property (nonatomic, strong) NSString *amzn_h;
@property (nonatomic, strong) NSString *bidInfos;

/**
 Instantiate a new instance of SASBaseAmazonBidderAdapter using a valid Amazon ad response.
 
 @note This initializer method might fail depending of the status of the ad response
 and the SASAmazonBidderConfigManager class. You must handle this case properly.
 
 @param adResponse A valid Amazon ad response.
 @return An initialized SASAmazonBidderAdapter instance if possible, nil otherwise.
 */
- (nullable instancetype)initWithAmazonAdResponse:(DTBAdResponse *)adResponse;

@end

NS_ASSUME_NONNULL_END
