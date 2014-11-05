//
//  CItem.h
//  Flats
//
//  Created by iPlusDev3 on 15.10.14.
//  Copyright (c) 2014 iPlusDev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CItem : NSObject
@property (nonatomic, retain) NSString *city_id;
@property (nonatomic, retain) NSString *district_id;
@property (nonatomic, retain) NSString *id_city;
@property (nonatomic, retain) NSString *city_name;
@property (nonatomic, retain) NSString *district_name;
@property (nonatomic,retain)NSString *status;

-(void) setValue:(NSString*)value forProperty:(NSString*)property;
@end
