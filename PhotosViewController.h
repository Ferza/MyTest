//
//  PhotosViewController.h
//  Flats
//
//  Created by iPlusDev3 on 26.10.14.
//  Copyright (c) 2014 iPlusDev. All rights reserved.
//
#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

#import <UIKit/UIKit.h>

@interface PhotosViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *myImage;
@property (weak, nonatomic) UIImage *image;
@property (strong, nonatomic) IBOutlet UIButton *btnNext;
- (IBAction)btnNextClick:(id)sender;
@property (weak, nonatomic) UIImage *selfImage;
@property (strong, nonatomic) NSMutableArray *myImages;
@property NSArray *imgPath;
@property int tag;
@property int photoCount;
@property int photoID;
@end
