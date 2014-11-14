//
//  QItem.h
//  Flats
//
//  Created by iPlusDev3 on 07.10.14.
//  Copyright (c) 2014 iPlusDev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QItem : NSObject{
    NSDate *_pubDate;
    NSString *_publication;
}
//прописать все нужные поля
@property (nonatomic, retain) NSString *id_rec;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *place;
@property (nonatomic, retain) NSString *rooms;
@property (nonatomic, retain) NSString *price;
@property (nonatomic, retain) NSString *descript;
@property (nonatomic, retain) NSString *photo;
@property (nonatomic, retain) NSDate *pub_date;
@property (nonatomic, retain)  NSString *name;
@property (nonatomic, retain)  NSString *phone;
@property  (nonatomic, retain) NSString *photo_count;
@property  (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *days;
@property (nonatomic, retain) NSString *subway;

-(void) setValue:(NSString*)value forProperty:(NSString*)property;



@end
