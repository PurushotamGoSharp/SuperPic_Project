//
//  Utility.h
//  Fox
//
//  Created by Francisco Nunez on 21-04-14.
//  Copyright (c) 2014 Accedo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+(NSString *)nameApp;
//+(NSString *)deviceDensity;

//+(BOOL)hasFourInchDisplay;
+(BOOL)validateEmail:(NSString *)email;

//+(BOOL) isIpad;

+(NSString *)stringFrom:(NSString *)text;

+(NSString *)stringFromDictionary:(NSDictionary *)dictionary;
//+(NSError *)customErrorWithError:(NSError *)error statusCode:(NSInteger)statusCode ;

//+(NSString*) getDeviceId;
//+(NSString*) getDeviceName;

@end
