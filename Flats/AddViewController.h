//
//  AddViewController.h
//  Flats
//
//  Created by iPlusDev3 on 12.10.14.
//  Copyright (c) 2014 iPlusDev. All rights reserved.
//
#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#import <UIKit/UIKit.h>
#import <sys/xattr.h>
#import "CitiesViewController.h"
#import "AppDelegate.h"
#import "AFNetworking.h"


@interface AddViewController : UITableViewController<UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextViewDelegate, UITextFieldDelegate,NSXMLParserDelegate>{
    NSXMLParser * _rssParser;
    QItem * _currentItem;
    NSMutableArray * _bashItems;
    NSString* _currentProperty;
    NSMutableString * _currentValue;
    int i,k;
    NSMutableArray *imagePath;
}
@property (strong, nonatomic) IBOutlet UIButton *btnAdd;
@property (strong, nonatomic) CitiesViewController *cityViewController;
- (IBAction)btnAddClick:(id)sender;

@property (strong, nonatomic) IBOutlet UITextView *tvFlat;
@property (strong, nonatomic) IBOutlet UITextView *tvPrice;
@property (strong, nonatomic) IBOutlet UITextField *tfPhone;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tap;
@property (strong, nonatomic) IBOutlet UITextField *tfPrice;
@property (strong, nonatomic) NSString *cityName;
@property (strong, nonatomic) NSString *districtName;
@property (strong, nonatomic) NSString *rooms;
@property int cValue;
@property NSIndexPath *roomsIndex;
- (IBAction)takePicture:(id)sender;

@end
