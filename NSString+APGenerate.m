//
//  NSString+Generate.m
//  appPromotion
//
//  Created by Ruslan Rezin on 13.12.13.
//  Copyright (c) 2013 Michael Krutoyarskiy. All rights reserved.
//

#import "NSString+APGenerate.h"

@implementation NSString (APGenerate)

+ (NSString*)generatedString{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    
    NSString *returnString = (__bridge_transfer NSString *)string;
    
    return returnString;
}

@end
