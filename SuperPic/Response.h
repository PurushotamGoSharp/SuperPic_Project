//
//  RequestResponse.h
//  Fox
//
//  Created by Francisco Nunez on 09-06-14.
//  Copyright (c) 2014 Accedo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Response : NSObject

@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) NSInteger code;

-(instancetype)initWithDictionary:(NSDictionary *)dict;

@end
