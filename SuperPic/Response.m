//
//  RequestResponse.m
//  Fox
//
//  Created by Francisco Nunez on 09-06-14.
//  Copyright (c) 2014 Accedo. All rights reserved.
//

#import "Response.h"

#import "JsonUtil.h"

@implementation Response

-(instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _code =  [JsonUtil numberFromKey:@"http_code" inDictionary:dict];
        _message = [JsonUtil stringFromKey:@"message" inDictionary:dict];
    }
    return self;
}

@end
