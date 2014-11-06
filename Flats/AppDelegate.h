//
//  AppDelegate.h
//  Flats
//
//  Created by iPlusDev3 on 05.10.14.
//  Copyright (c) 2014 iPlusDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "QItem.h"
#import "KeychainWrapper.h"
#import "NSString+APGenerate.h"
#import "NSString+APMD5.h"
#import "AFNetworking/AFNetworking.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,UITabBarDelegate, NSXMLParserDelegate>{
    
    NSXMLParser * _rssParser;
    QItem* _currentItem;
    NSMutableArray* _bashItems;
    NSString* _currentProperty;
    NSMutableString* _currentValue;
    int i;
}

@property (strong, nonatomic) UIWindow *window;


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong,nonatomic)NSString *uuid;
@property UIImage *image ;
@property NSString *days;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(long)getLastID:(NSString*)entityName;

@end
