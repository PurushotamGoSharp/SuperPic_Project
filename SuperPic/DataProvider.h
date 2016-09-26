//
//  DataProvider.h
//  SuperPic
//
//  Created by Syed Hyder Zubair on 28/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HTTPCODE) {
    HTTPCODE_OK = 200,
    HTTPCODE_ERROR_NOT_FOUND = 404,
    HTTPCODE_ERROR_SERVER = 500,
    HTTPCODE_ERROR_CONNECTION = 0
};

@interface DataProvider : NSObject

-(void)getJsonContentWithUrl:(NSString *)urlString completion:(void(^)(BOOL success, id responseJsonObject, id responseObject, NSError *error))block;
-(void)getEntriesForUrl:(NSString *)urlString completion:(void(^)(BOOL success, NSArray* entries, NSError *error))block;

-(void)postJsonContentWithUrl:(NSString *)urlString parameters:(id)parameters completion:(void(^)(BOOL success, id responseJsonObject, id responseObject, NSError *error))block;

-(void)postImageURLAndJsonContentWithURL:(NSString *)imagePathURL bossURL:(NSString *)urlString parameters:(id)parameters completion:(void(^)(BOOL success, id responseJsonObject, id responseObject, NSError *error))block;

-(void)cancelOperations;

@end
