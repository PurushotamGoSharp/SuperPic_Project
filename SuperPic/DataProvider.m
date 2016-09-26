//
//  DataProvider.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 28/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "DataProvider.h"

#import "Constant.h"

#import "AFHTTPSessionManager.h"

#import "JSONResponseSerializerWithData.h"

#import "AFHTTPRequestOperationManager.h"

@interface DataProvider()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation DataProvider

BOOL const success = YES;
BOOL const noSuccess = NO;

-(void)getJsonContentWithUrl:(NSString *)urlString completion:(void(^)(BOOL success, id responseJsonObject, id responseObject, NSError *error))block {
    NSString *URLString = [NSString stringWithFormat:@"%@%@", BASE_URL, urlString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [self requestSerializer];
    AFHTTPRequestOperation *requestOperation = [manager GET:URLString
                                          parameters:nil
                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                 
                                                 NSData *responseData = [operation responseData];
                                                 NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
                                                 block(success, json, responseObject, nil);
                                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 block(noSuccess, [operation responseString], nil, error);
                                             }];
    [requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        double percentDone = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        NSLog(@"progress updated(percentDone) : %f", percentDone);
    }];
    [requestOperation start];
}
/*
 * MultipartFormData
 */


-(void)postImageURLAndJsonContentWithURL:(NSString *)imagePathURL bossURL:(NSString *)urlString parameters:(id)parameters completion:(void(^)(BOOL success, id responseJsonObject, id responseObject, NSError *error))block {
    NSString *URLString = [NSString stringWithFormat:@"%@%@", BASE_URL, urlString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [self requestSerializer];
    AFHTTPRequestOperation *requestOperation = [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSError *error;
        NSURL *tempFilePathURL = [[NSURL alloc] initFileURLWithPath:imagePathURL];
        BOOL success = [formData appendPartWithFileURL:tempFilePathURL name:@"files" error:&error];
        if (!success) {
            NSLog(@"appendPartWithFileURL error: %@", error);
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *responseData = [operation responseData];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        block(success, json, responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        block(noSuccess, [operation responseString], nil, error);
    }];
    [requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        double percentDone = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        NSLog(@"progress updated(percentDone) : %f", percentDone);
    }];
    [requestOperation start];
}

-(void)getEntriesForUrl:(NSString *)urlString completion:(void(^)(BOOL success, NSArray* entries, NSError *error))block {
    [self getJsonContentWithUrl:urlString completion:^(BOOL success, id responseJsonObject, id responseObject, NSError *error) {
        NSMutableArray *items = [NSMutableArray array];
        if (success) {
            NSDictionary *json = (NSDictionary *)responseObject;
            NSArray *entries = json[ @"Users" ];
            for (NSDictionary *dict in entries) {
                NSLog(@"Entries : %@", dict);
                block(YES, items, nil);
            }
        } else {
            block(NO, nil, error);
        }
    }];
}

-(void)postJsonContentWithUrl:(NSString *)urlString parameters:(id)parameters completion:(void(^)(BOOL success, id responseJsonObject, id responseObject, NSError *error))block {
    
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@", BASE_URL, urlString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer = [self requestSerializer];
    AFJSONRequestSerializer *tempRequestSerializer = [AFJSONRequestSerializer serializer];
    if ([FILE_UPLOAD_URL isEqualToString:urlString]) {
//        URLString = [NSString stringWithFormat:@"http://sharepic.azurewebsites.net/%@", urlString];
    }
    else {
        
        [tempRequestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    [tempRequestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = tempRequestSerializer;
    
    NSLog(@"URl = %@ \n parameters = %@", URLString,parameters);
    NSDictionary *parameterDict;
    if (![parameters isKindOfClass:[NSDictionary class]])
    {
         parameterDict = [NSJSONSerialization JSONObjectWithData:[parameters dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
    }
    
    
    AFHTTPRequestOperation *operation = [manager POST:URLString
                                           parameters:parameterDict
                                              success:^(AFHTTPRequestOperation *operation, id responseObject){
                                                  
                                                  NSData *responseData = [operation responseData];
                                                  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
                                                  NSLog(@"json data %@",json);
                                                  block(success, json, responseObject, nil);
                                                  
                                              }
                                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                  block(noSuccess, [operation responseString], nil, error);
                                                  NSLog(@"ERROR %@",[operation responseString]);
                                                  NSLog(@"Error %@", error.description);
                                              }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        double percentDone = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        NSLog(@"progress updated(percentDone) : %f", percentDone);
    }];
    [operation start];
}

- (AFJSONRequestSerializer *)requestSerializer {
    AFJSONRequestSerializer *tempRequestSerializer = [AFJSONRequestSerializer serializer];
    
    [tempRequestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [tempRequestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    return tempRequestSerializer;
}

#pragma mark - Session Manager

-(AFHTTPSessionManager *)getSessionManager {
    if (!self.sessionManager){
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.HTTPAdditionalHeaders = nil;
        NSURL *url = [NSURL URLWithString:BASE_URL];
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:sessionConfiguration];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    manager.requestSerializer = requestSerializer;
    
    self.sessionManager.securityPolicy.allowInvalidCertificates = YES;
    self.sessionManager.responseSerializer = [JSONResponseSerializerWithData serializer];
    return self.sessionManager;
}

#pragma mark - Cancel operations

-(void)cancelOperations {
    if (self.sessionManager){
        for (NSURLSessionDataTask *task in [self.sessionManager tasks]) {
            [task cancel];
        }
    }
}

@end
