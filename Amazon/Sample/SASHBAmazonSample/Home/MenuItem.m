//
//  MenuItem.m
//  SASHBAmazonSample
//
//  Created by Loïc GIRON DIT METAZ on 15/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import "MenuItem.h"

#import "BannerViewController.h"
#import "InterstitialViewController.h"

@implementation MenuItem

- (id)initWithTitle:(NSString *)title class:(NSString *)controllerClass nib:(NSString *)nib type:(NSInteger)type; {
	self = [super init];
	
	if (self) {
		_title = title;
        _controllerClass = controllerClass;
        _nib = nib;
        _type = type;
	}
	return self;
}


- (UIViewController *)controller {

    Class classFromString = NSClassFromString(_controllerClass);
    assert([classFromString instancesRespondToSelector:@selector(initWithNibName:bundle:)]);
    id newController;
    if (_nib) {
        newController = [[classFromString alloc] initWithNibName:_nib bundle:nil];
    } else {
        newController = [[classFromString alloc] init];
    }
    return (UIViewController *)newController;
    
}

@end
