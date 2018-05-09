//
//  MenuItem.h
//  SASHBAmazonSample
//
//  Created by Loïc GIRON DIT METAZ on 15/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuItem : NSObject

@property (strong, nonatomic) NSString *title;
@property (nonatomic, strong) NSString *controllerClass;
@property (nonatomic, strong) NSString *nib;
@property (nonatomic, assign) NSInteger type;

- (id)initWithTitle:(NSString *)title class:(NSString *)controllerClass nib:(NSString *)nib type:(NSInteger)type;
- (UIViewController *)controller;

@end
