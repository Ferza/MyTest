//
//  MenuViewController.h
//  Flats
//
//  Created by iPlusDev3 on 28.10.14.
//  Copyright (c) 2014 iPlusDev. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "FastSegue.h"
#import "FlatsViewController.h"


@interface MenuViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UILabel *lblFind;
@property NSString *cityName;
@property NSString *districtName;
@property NSString *rooms;
@property (nonatomic, weak) id  delegate;
@property NSString *btnTag;
@end
