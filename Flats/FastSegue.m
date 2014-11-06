//
//  FastSegue.m
//  Flats
//
//  Created by iPlusDev3 on 28.10.14.
//  Copyright (c) 2014 iPlusDev. All rights reserved.
//

#import "FastSegue.h"

@implementation FastSegue
- (void) perform {
    [[[self sourceViewController] navigationController] pushViewController:[self destinationViewController] animated:NO];
}
@end
