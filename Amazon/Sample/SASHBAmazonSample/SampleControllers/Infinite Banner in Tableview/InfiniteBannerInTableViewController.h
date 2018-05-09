//
//  InfiniteBannerInTableViewController.h
//  ObjCSample
//
//  Created by Thomas Geley on 04/10/2016.
//  Copyright © 2016 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASTableBannerView.h"

@interface InfiniteBannerInTableViewController : UITableViewController <SASAdViewDelegate>
@property (nonatomic, retain) SASTableBannerView *banner;
@end
