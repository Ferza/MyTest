//
//  FlatsViewController.h
//  Flats
//
//  Created by iPlusDev3 on 13.10.14.
//  Copyright (c) 2014 iPlusDev. All rights reserved.
//

#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#import <UIKit/UIKit.h>
#import "CitiesViewController.h"
#import "AppDelegate.h"
#import "PhotosViewController.h"
#import "AddViewController.h"
#import "MenuViewController.h"
#import "AFNetworking.h"

@interface FlatsViewController : UITableViewController<UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate,NSXMLParserDelegate, UITextViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) CitiesViewController *cityViewController;
@property (strong,nonatomic)NSMutableArray *myList;
@property (strong,nonatomic)NSMutableArray *myPhoto;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;
- (IBAction)segControlChange:(id)sender;

@property UIButton *btnLike;
@property UIButton *btnDelete;
@property NSString *rooms;
//@property UILabel *lblDescript;
@property UITextView *tvDescript;
@property (strong, nonatomic) NSString *cityName;
@property (strong, nonatomic) NSString *districtName;
@property NSString *btnTag;
@property (strong, nonatomic) IBOutlet UIButton *btnElse;
- (IBAction)btnElseClick:(id)sender;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@property int cValue;
@property (strong, nonatomic) NSPredicate *mainPredicate;
@end
