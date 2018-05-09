//
//  SASBidderAdapterAmazon.h
//  SmartAdServer
//
//  Created by Thomas Geley on 07/02/2018.
//

#import <Foundation/Foundation.h>
#import "SASBidderAdapter.h"

@class DTBAdResponse;

@interface SASBidderAdapterAmazon : SASBidderAdapter

@property (nonatomic, strong) NSString *adWidth;
@property (nonatomic, strong) NSString *adHeight;

- (instancetype)initWithAmazonAdResponse:(DTBAdResponse *)adResponse pricePointsMatrix:(NSDictionary <NSString*, NSNumber*> *)pricePointsMatrix currency:(NSString *)currency;

@end
