//
//  SASAmazonBidderConfigManager.m
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 11/10/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASAmazonBidderConfigManager.h"

// Expiration interval between two configuration refresh
#define kExpirationInterval     (24*60*60)

NS_ASSUME_NONNULL_BEGIN

@interface SASAmazonBidderConfigManager ()

@property (nonatomic, nullable, strong) NSURL *configURL;

@property (nonatomic, nullable, strong) NSDate *lastSuccessfulRefreshDate;

@property (atomic, assign, getter=isRequestInProgress) BOOL requestInProgress;

@end

@implementation SASAmazonBidderConfigManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (BOOL)isReady {
    // The config manager is ready only if all the info are available
    return self.currency != nil && self.pricePointsMatrix != nil && self.adMarkup != nil;
}

- (BOOL)isExpired {
    return (self.lastSuccessfulRefreshDate == nil || [[NSDate date] timeIntervalSince1970] - [self.lastSuccessfulRefreshDate timeIntervalSince1970] > kExpirationInterval);
}

- (void)configureWithURL:(NSURL *)configURL {
    if (self.configURL == nil) {
        self.configURL = configURL;
        [self refresh]; // calling configureWithURL: will always trigger a refresh
    } else {
        NSLog(@"Error: SASAmazonBidderConfigManager is already configured!");
    }
}

- (void)refresh {
    if (!self.configURL) {
        NSLog(@"Error: configureWithURL: must be called with a valid configuration URL!");
        return;
    }
    
    if (self.isReady && !self.isExpired) {
        // If ready and not expired, no need to refresh anything
        return;
    }
    
    if (!self.isRequestInProgress) {
        self.requestInProgress = YES;
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        [[session dataTaskWithURL:self.configURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (!error && data) {
                NSError *parsingError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parsingError];
                if (!parsingError && json && [json respondsToSelector:@selector(objectForKey:)]) {
                    // Extracting the 3 raw info from a valid JSON file
                    id pricePoints = [json objectForKey:@"pricePoints"];
                    id creativeTag = [json objectForKey:@"creativeTag"];
                    id currencyCode = [json objectForKey:@"currencyCode"];
                    
                    // Checking that info are from the correct type
                    if ([pricePoints isKindOfClass:[NSString class]]
                        && [creativeTag isKindOfClass:[NSString class]]
                        && [currencyCode isKindOfClass:[NSString class]]
                        && [self pricePointsMatrixFromString:pricePoints]) {
                        
                        // Info retrieved successfully
                        self.currency = currencyCode;
                        self.pricePointsMatrix = [self pricePointsMatrixFromString:pricePoints];
                        self.adMarkup = creativeTag;
                        
                        // Store the refresh date to handle expiration
                        self.lastSuccessfulRefreshDate = [NSDate date];
                        
                        NSLog(@"Amazon bidder adapter configuration retrieved successfully");
                    }
                } else {
                    NSLog(@"Error: can't parse Amazon info retrieved from the config URL!");
                }
            } else {
                NSLog(@"Error: can't retrieve Amazon info from the config URL!");
            }
            
            self.requestInProgress = NO;
        }] resume];
    }
}

- (nullable NSDictionary <NSString *, NSNumber *> *)pricePointsMatrixFromString:(NSString *)pricePointsString {
    // Number formatter for price values
    // this formatter will always use a DOT for decimal separator to avoid conflict between locales.
    NSMutableDictionary <NSString *, NSNumber *> *pricePointsMatrix = [NSMutableDictionary dictionary];
    NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
    priceFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    [priceFormatter setDecimalSeparator:@"."];
    
    for (NSString *pricePointsItem in [pricePointsString componentsSeparatedByString:@" "]) {
        NSArray *pricePointsItemArray = [pricePointsItem componentsSeparatedByString:@":"];
        if (pricePointsItemArray.count == 2 && [priceFormatter numberFromString:pricePointsItemArray[1]] != nil) {
            [pricePointsMatrix setObject:[priceFormatter numberFromString:pricePointsItemArray[1]] forKey:pricePointsItemArray[0]];
        } else {
            // No error if a price point is invalid: it is simply ignored…
            // If you want an error in case of a single invalid price point, returns nil here
        }
    }
    
    if (pricePointsMatrix.count > 0) {
        return [NSDictionary dictionaryWithDictionary:pricePointsMatrix];
    } else {
        return nil; // no valid price points is an error
    }
}

@end

NS_ASSUME_NONNULL_END
