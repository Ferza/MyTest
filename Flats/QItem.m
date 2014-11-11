//
//  QItem.m
//  Flats
//
//  Created by iPlusDev3 on 07.10.14.
//  Copyright (c) 2014 iPlusDev. All rights reserved.
//

#import "QItem.h"

@implementation QItem
@synthesize id_rec;
@synthesize city;
@synthesize place;
@synthesize rooms;
@synthesize price;
@synthesize descript;
@synthesize photo;
@synthesize name;
@synthesize phone;
@synthesize pub_date;
@synthesize photo_count;
@synthesize status;
@synthesize path;
@synthesize days;


//доделать!!!!!
-(void) setValue:(NSString*)value forProperty:(NSString*)property
{
    if ([property isEqualToString:@"pub_date"]) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EE, d LLLL yyyy HH:mm:ss Z"];
        pub_date = [dateFormat dateFromString:value];
        
        return;
        
    }
    
    if ([property isEqualToString:@"id"]) {
        id_rec=value;
    }
    if ([property isEqualToString:@"city"]) {
        city=value;
    }
    if ([property isEqualToString:@"place"]) {
        place=value;
    }
    if ([property isEqualToString:@"rooms"]) {
        rooms=value;
    }
    if ([property isEqualToString:@"price"]) {
        price=value;
    }
    if ([property isEqualToString:@"descript"]) {
        descript=value;
    }
    if ([property isEqualToString:@"photo"]) {
        photo=value;
    }
    if ([property isEqualToString:@"name"]) {
        name=value;
    }
    if ([property isEqualToString:@"phone"]) {
        phone=value;
    }
 
   if ([property isEqualToString:@"photo_count"]) {
        photo_count=value;
    }
    if ([property isEqualToString:@"status"]) {
        status=value;
    }
    if ([property isEqualToString:@"path"]) {
        path=value;
    }
    if ([property isEqualToString:@"days"]) {
        days=value;
    }

    //  _publication=value;
    
    
}
@end
