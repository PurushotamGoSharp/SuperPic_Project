//
//  Person.m
//  JPlus
//
//  Created by Varghese Simon on 4/3/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "Person.h"

@implementation Person

-(id)init {
    self = [super init];
    if (self)
    {
        self.arrOfPhoneNumbers = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end
