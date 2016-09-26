//  ParseHandler.m
//  SuperPic
//
//  Created by iT on 5/26/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.

#import "ParseHandler.h"
#import "FriendListsModel.h"

static ParseHandler *parseHandler = nil;

@implementation ParseHandler
@synthesize delegate;
@synthesize parseResponsecode;
@synthesize parseRequest;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (ParseHandler*)sharedInstance {
    
    if (parseHandler == nil) {
        parseHandler = [[super allocWithZone:NULL] init];
        [parseHandler initialize];
    }
    
    return parseHandler;
}

- (void) initialize
{

    
}



- (void) shareNotification:(NSMutableArray *)shareUsers count:(int)count
{
    

    
}





- (BOOL) isNumbericalText:( NSString*)text //double &value
{
    BOOL result = false;
    NSCharacterSet* alphaNumberSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet* stringSet      = [NSCharacterSet characterSetWithCharactersInString:text];
    result = [alphaNumberSet isSupersetOfSet:stringSet];
    return result;
}


@end