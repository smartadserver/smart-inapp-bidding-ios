//
//  SASAmazonBidderConfigManager.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 11/10/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Configuration manager in charge of retrieving from a distant URL various info that will be
 used by the Amazon bidder adapter.
 */
@interface SASAmazonBidderConfigManager : NSObject

/// The Amazon bidder config manager instance.
@property (nonatomic, readonly, class) SASAmazonBidderConfigManager *sharedInstance NS_SWIFT_NAME(shared);

/// YES if the configuration is ready to be used, false otherwise.
@property (nonatomic, readonly) BOOL isReady;

/// YES if the configuration should be refresh, false otherwise.
@property (nonatomic, readonly) BOOL isExpired;

/// The currency that should be used by the bidder adapter if any, nil otherwise.
@property (nonatomic, nullable, strong) NSString *currency;

/// The price points matrix that should be used by the bidder adapter if any, nil otherwise.
@property (nonatomic, nullable, strong) NSDictionary <NSString *, NSNumber *> *pricePointsMatrix;

/// The ad markup that should be used by the bidder adapter if any, nil otherwise.
@property (nonatomic, nullable, strong) NSString *adMarkup;

/**
 Configure the Amazon bidder adapter by retrieving the currency, ad markup and price points that
 should be used by the Amazon bidder adapter.
 
 You must call this method only once, as early as possible in your app workflow so the configuration is
 more likely to be ready when the first ad call happens.
 
 @param configURL A valid URL to the configuration file.
 */
- (void)configureWithURL:(NSURL *)configURL;

/**
 Trigger a configuration refresh if necessary (aka if the configuration is not ready yet and if there is
 no configuration refresh in progress).
 */
- (void)refresh;

@end

NS_ASSUME_NONNULL_END
