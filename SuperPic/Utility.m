//
//  Utility.m
//  Fox
//
//  Created by Francisco Nunez on 21-04-14.
//  Copyright (c) 2014 Accedo. All rights reserved.
//

#import "Utility.h"

#import "Constant.h"
//#import "GraphicUtil.h"
//#import "Country.h"
//#import "SettingsHelper.h"

@implementation Utility


+(NSString *)nameApp {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}
/*
+(NSString *)deviceDensity {
    return ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad && [UIScreen mainScreen].bounds.size.height == 480.0) ? @"1x" : @"2x";
}

+(BOOL)hasFourInchDisplay {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0);
}
*/
+(BOOL)validateEmail:(NSString *)email {
	if (![email length])
    {
        return NO;
    }
    
    NSRange entireRange = NSMakeRange(0, [email length]);
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                               error:NULL];
    NSArray *matches = [detector matchesInString:email options:0 range:entireRange];
    
    // should only a single match
    if ([matches count]!=1)
    {
        return NO;
    }
    
    NSTextCheckingResult *result = [matches firstObject];
    
    // result should be a link
    if (result.resultType != NSTextCheckingTypeLink)
    {
        return NO;
    }
    
    // result should be a recognized mail address
    if (![result.URL.scheme isEqualToString:@"mailto"])
    {
        return NO;
    }
    
    // match must be entire string
    if (!NSEqualRanges(result.range, entireRange))
    {
        return NO;
    }
    
    // but schould not have the mail URL scheme
    if ([email hasPrefix:@"mailto:"])
    {
        return NO;
    }
    
    // no complaints, string is valid email address
    return YES;
}
/*
+(BOOL) isIpad {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}
*/
+(NSString *)stringFrom:(NSString *)text {
    if (!nil) return @"";
    return text;
}

+(NSString *)stringFromDictionary:(NSDictionary *)dictionary {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    if (!error){
        NSString *json = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return json;
    }
    return nil;
}

+(NSString*) getDeviceId {
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (![defaults objectForKey:@"deviceuniqueid"]) {
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        [defaults setObject:(__bridge_transfer NSString *)uuidStringRef forKey:@"deviceuniqueid"];
        [defaults synchronize];
    }
    return [defaults objectForKey:@"deviceuniqueid"];
}
/*
+(NSString*) getDeviceName {
    return [[UIDevice currentDevice] name];
}
*/
@end
