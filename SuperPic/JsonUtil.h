//
//  JsonUtil.h
//  Fox
//
//  Created by Francisco Nunez on 05-05-14.
//  Copyright (c) 2014 Accedo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Response;

@interface JsonUtil : NSObject

+(NSString *)stringFromKey:(NSString *)key inDictionary:(NSDictionary *)dict;
+(NSString *)emailFromKey:(NSString *)key inDictionary:(NSDictionary *)dict;
+(NSInteger)numberFromKey:(NSString *)key inDictionary:(NSDictionary *)dict;
+(BOOL)booleanFromKey:(NSString *)key inDictionary:(NSDictionary *)dict;
+(NSURL *)urlFromKey:(NSString *)key inDictionary:(NSDictionary *)dict;
+(NSDictionary *)dictionaryFromKey:(NSString *)key inDictionary:(NSDictionary *)dict;
+(NSArray *)arrayFromKey:(NSString *)key inDictionary:(NSDictionary *)dict;
+(NSDictionary *)dictionaryFromResponse:(id)response;
+(NSArray *)arrayFromResponse:(id)response;
+(Response *)requestResponseFromResponse:(id)response;
+(NSDictionary *)removeNullNodes:(NSDictionary *)dict;

@end
