//
//  JSONResponseSerializerWithData.m
//  Fox
//
//  Created by Francisco Nunez on 05-11-14.
//  Copyright (c) 2014 Accedo. All rights reserved.
//

#import "JSONResponseSerializerWithData.h"

@implementation JSONResponseSerializerWithData

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (*error != nil) {
            NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
            NSError *jsonError;
            // parse to json
            id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            // store the value in userInfo if JSON has no error
            if (jsonError == nil) userInfo[JSONResponseSerializerWithDataKey] = json;
            NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
            (*error) = newError;
        }
        return (nil);
    }
    return ([super responseObjectForResponse:response data:data error:error]);
}

@end
