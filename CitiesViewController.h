//
//  CitiesViewController.h
//  Flats
//
//  Created by iPlusDev3 on 13.10.14.
//  Copyright (c) 2014 iPlusDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CItem.h"

@class CitiesViewController;

@protocol CitiesViewControllerDelegate 

-(void)getCityName:(CitiesViewController*)controller city:(NSString*)cityName isCity:(BOOL)isCity;

-(void)getRooms:(CitiesViewController*)controller rooms:(NSString*)rooms;
@end

@interface CitiesViewController : UITableViewController<NSXMLParserDelegate>{
    NSString *val;
    int i;
    NSXMLParser * _rssParser;
    CItem* _currentItem;
    NSMutableArray* _bashItems;
    NSString* _currentProperty;
    NSMutableString* _currentValue;
    NSIndexPath *lastIndexPath;
    NSString *DistrictName;
}
@property (strong, nonatomic) NSMutableArray *myList;
@property (strong, nonatomic) NSString *cValue;
@property (nonatomic, weak) id  delegate;
@property (strong, nonatomic) NSString *cityName;
@property (strong, nonatomic) NSString *addVC;
@property (strong, nonatomic) NSString *district;
@end
