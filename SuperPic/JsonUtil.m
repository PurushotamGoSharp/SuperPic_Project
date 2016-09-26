//
//  JsonUtil.m
//  Fox
//
//  Created by Francisco Nunez on 05-05-14.
//  Copyright (c) 2014 Accedo. All rights reserved.
//

#import "JsonUtil.h"

#import "Response.h"
#import "Utility.h"

@implementation JsonUtil



+(NSString *)stringFromKey:(NSString *)key inDictionary:(NSDictionary *)dict {
    if (!dict[key]){
        return @"";
    }
    if (dict[key] == [NSNull null]){
        return @"";
    }
    if ([dict[key] isKindOfClass:[NSString class]] || [dict[key] isKindOfClass:[NSNumber class]]){
        return [NSString stringWithFormat:@"%@", dict[key] ];
    }
    return @"";
}

+(NSString *)emailFromKey:(NSString *)key inDictionary:(NSDictionary *)dict {
    if (!dict[key] || (dict[key] == [NSNull null])){
        return nil;
    }
    NSString *email = [NSString stringWithFormat:@"%@", dict[key]];
    if ([Utility validateEmail:email]){
        return email;
    }
    return nil;
}



+(NSInteger)numberFromKey:(NSString *)key inDictionary:(NSDictionary *)dict {
    if (!dict[key] || (dict[key] == [NSNull null])){
        return 0;
    }
    return [dict[ key ] integerValue];
}

+(BOOL)booleanFromKey:(NSString *)key inDictionary:(NSDictionary *)dict {
    if (!dict[key] || (dict[key] == [NSNull null])){
        return NO;
    }
    return [dict[ key] boolValue];
}


+(NSURL *)urlFromKey:(NSString *)key inDictionary:(NSDictionary *)dict {
    if (!dict[key] || (dict[key] == [NSNull null])){
        return nil;
    }
    NSString *urlString = [JsonUtil stringFromKey:key inDictionary:dict];
    if (!urlString || [urlString length] == 0){
        return nil;
    }
    return [NSURL URLWithString:urlString];
}

+(NSDictionary *)dictionaryFromKey:(NSString *)key inDictionary:(NSDictionary *)dict {
    if (dict[key] && [dict[ key ] isKindOfClass:[NSDictionary class]]){
        NSDictionary *dictionary = dict[ key ];
        if (dictionary && [[dictionary allKeys] count] > 0){
            return dictionary;
        }
    }
    return nil;
}

+(NSArray *)arrayFromKey:(NSString *)key inDictionary:(NSDictionary *)dict {
    if (dict[key] && [dict[ key ] isKindOfClass:[NSArray class]]){
        return dict[ key ];
    }
    return nil;
}

+(NSDictionary *)dictionaryFromResponse:(id)response {
    if ([response isKindOfClass:[NSDictionary class]]){
        NSDictionary *dictionary = (NSDictionary *)response;
        if (dictionary && [[dictionary allKeys] count] > 0){
            return dictionary;
        }
    }
    return nil;
}

+(NSArray *)arrayFromResponse:(id)response {
    if ([response isKindOfClass:[NSArray class]]){
        return (NSArray *)response;
    }
    return nil;
}

+(Response *)requestResponseFromResponse:(id)response {
    NSDictionary *dict = [JsonUtil dictionaryFromResponse:response];
    Response *request = nil;
    if (dict){
        request = [[Response alloc] initWithDictionary:dict];
    }
    return request;
}

+(NSDictionary *)removeNullNodes:(NSDictionary *)dict {
    if (!dict) return nil;
    
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [tempDict enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        if (object == [NSNull null] || !object){
            [tempDict removeObjectForKey:key];
        }
    }];
    return tempDict;
}

@end
