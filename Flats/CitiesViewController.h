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

-(void)getCityName:(CitiesViewController*)controller city:(NSString*)cityNameIs district:(NSString *)districtNameIs valueIs:(int)value;
-(void)getDistrictName:(CitiesViewController*)controller district:(NSString*)districtNameIs valueIs:(int)value;

-(void)getRooms:(CitiesViewController*)controller rooms:(NSString*)roomsCount index:(NSIndexPath *)indexPath;
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
}
@property (strong, nonatomic) NSMutableArray *myList;
@property (nonatomic, weak) id  delegate;
@property (strong, nonatomic) NSString *cityName;
- (IBAction)btnSubwayClick:(id)sender;
@property (strong, nonatomic) NSString *addVC;
@property (strong, nonatomic) IBOutlet UIButton *btnSubway;
@property (strong, nonatomic) NSString *districtName;
@property int cValue;
//@property UIButton *radioBtn;
@property (strong, nonatomic) NSIndexPath *roomsIndex;

@end
