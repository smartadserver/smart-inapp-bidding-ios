//
//  MasterViewController.m
//  SASHBAmazonSample
//
//  Created by Loïc GIRON DIT METAZ on 15/01/13.
//  Copyright (c) 2013 Smart AdServer. All rights reserved.
//

#import "MasterViewController.h"
#import "MenuItem.h"

@interface MasterViewController () {
	NSMutableArray *_items;
}
@end

@implementation MasterViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil    {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
		self.title = @"Amazon HB Sample";
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
		[self initializeItems];
    }
    
    return self;
}

#pragma mark - Generating menu items & child controllers

- (void)initializeItems {
	_items = [[NSMutableArray alloc] init];
	
	[self createItemWithTitle:@"Banner" class:@"BannerViewController" nib:@"BannerViewController"];
	[self createItemWithTitle:@"Interstitial" class:@"InterstitialViewController" nib:@"InterstitialViewController"];
}


- (void)createItemWithTitle:(NSString *)title class:(NSString *)controllerClass nib:(NSString *)nib {
    MenuItem *item = [[MenuItem alloc] initWithTitle:title class:controllerClass nib:nib type:0];
    [_items addObject:item];
}


- (void)createItemWithTitle:(NSString *)title class:(NSString *)controllerClass nib:(NSString *)nib type:(NSInteger)type {
    MenuItem *item = [[MenuItem alloc] initWithTitle:title class:controllerClass nib:nib type:type];
	[_items addObject:item];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Choose an integration:";
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"\nThis sample demonstrates how to implement the Smart AdServer SDK in-app bidding with the Amazon Adapter.";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	[cell.textLabel setText:[[_items objectAtIndex:indexPath.row] title]];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MenuItem * item = [_items objectAtIndex:indexPath.row];
    UIViewController *controller = [item controller];
	if (controller != nil) {
		[self.navigationController pushViewController:controller animated:YES];
	}
}

@end
