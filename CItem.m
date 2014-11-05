//
//  CItem.m
//  Flats
//
//  Created by iPlusDev3 on 15.10.14.
//  Copyright (c) 2014 iPlusDev. All rights reserved.
//

#import "CItem.h"

@implementation CItem
@synthesize city_id;
@synthesize city_name;
@synthesize district_name;
@synthesize id_city;
@synthesize district_id;
@synthesize status;

-(void) setValue:(NSString*)value forProperty:(NSString*)property
{
    if ([property isEqualToString:@"city_id"]) {
       city_id=value;
    }
    if ([property isEqualToString:@"city_name"]) {
        city_name=value;
    }
    if ([property isEqualToString:@"district_name"]) {
        district_name=value;
    }
    if ([property isEqualToString:@"id_city"]) {
        id_city=value;
    }
    if ([property isEqualToString:@"district_id"]) {
        district_id=value;
    }
    if ([property isEqualToString:@"status"]) {
        status=value;
    }
   
}

@end
