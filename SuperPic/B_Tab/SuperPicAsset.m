//
//  SuperPicSignUpAsset.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 29/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "SuperPicAsset.h"
#import "JsonUtil.h"

@implementation SuperPicAsset

-(instancetype)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        
        NSDictionary *aaDataDict =      [JsonUtil dictionaryFromKey:@"aaData" inDictionary:dict];
        self.responseMessage =          [JsonUtil stringFromKey:@"Message" inDictionary:aaDataDict];
        self.successCode =              [JsonUtil numberFromKey:@"Success" inDictionary:aaDataDict];
        
        
        NSDictionary *tempUserDict =    [JsonUtil dictionaryFromKey:@"User" inDictionary:aaDataDict];
        self.userCode =                 [JsonUtil stringFromKey:@"Code" inDictionary:tempUserDict];
        self.deviceToken =              [JsonUtil stringFromKey:@"DeviceToken" inDictionary:tempUserDict];
        self.userId =                   [JsonUtil numberFromKey:@"ID" inDictionary:dict];
        self.emailId =                  [JsonUtil stringFromKey:@"Email" inDictionary:tempUserDict];
        self.password =                 [JsonUtil stringFromKey:@"Password" inDictionary:tempUserDict];
        self.userProfileName =          [JsonUtil stringFromKey:@"ProfileName" inDictionary:tempUserDict];
    }
    return self;
}

-(instancetype)initWithCheckDuplicateDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        NSDictionary *aaDataDict =      [JsonUtil dictionaryFromKey:@"aaData" inDictionary:dict];
        self.isUserExisted  =            [JsonUtil booleanFromKey:@"IsExisted" inDictionary:aaDataDict];
        self.isUserExistedResponse =    [JsonUtil booleanFromKey:@"Success" inDictionary:aaDataDict];
    }
    return self;
}

-(instancetype)initWithSignedInDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        NSDictionary *aaDataDict =      [JsonUtil dictionaryFromKey:@"aaData" inDictionary:dict];
        self.responseMessage =          [JsonUtil stringFromKey:@"Message" inDictionary:aaDataDict];
        self.isSuccess =                [JsonUtil booleanFromKey:@"Success" inDictionary:aaDataDict];
        
        NSDictionary *tempUserDict =    [JsonUtil dictionaryFromKey:@"User" inDictionary:aaDataDict];
        self.userCode =                 [JsonUtil stringFromKey:@"Code" inDictionary:tempUserDict];
        self.deviceToken =              [JsonUtil stringFromKey:@"DeviceToken" inDictionary:tempUserDict];
        self.emailId =                  [JsonUtil stringFromKey:@"Email" inDictionary:tempUserDict];
        self.userId =                   [JsonUtil numberFromKey:@"ID" inDictionary:dict];
        self.userProfileName =          [JsonUtil stringFromKey:@"ProfileName" inDictionary:tempUserDict];
        self.userStatus  =              [JsonUtil booleanFromKey:@"Status" inDictionary:tempUserDict];
    }
    return self;
}

-(instancetype)initWithForgotPasswordDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        NSDictionary *aaDataDict =      [JsonUtil dictionaryFromKey:@"aaData" inDictionary:dict];
        self.responseMessage =          [JsonUtil stringFromKey:@"Message" inDictionary:aaDataDict];
        self.isSuccess =                [JsonUtil booleanFromKey:@"Success" inDictionary:aaDataDict];
        
        NSArray *userDetailsArr = [JsonUtil arrayFromKey:@"userDetails" inDictionary:aaDataDict];
        if (userDetailsArr.count > 0) {
            for (id obj in userDetailsArr) {
                self.emailId =                  [JsonUtil stringFromKey:@"email" inDictionary:obj];
                self.password =                 [JsonUtil stringFromKey:@"password" inDictionary:obj];
                self.userProfileName =          [JsonUtil stringFromKey:@"profilename" inDictionary:obj];
            }
        }
    }
    return self;
}

-(instancetype)initWithFileUploadDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        NSDictionary *aaDataDict =      [JsonUtil dictionaryFromKey:@"aaData" inDictionary:dict];
        self.isSuccess =                [JsonUtil booleanFromKey:@"Success" inDictionary:aaDataDict];
        if (self.isSuccess) {
            NSDictionary *imageListDict = (NSDictionary *)[aaDataDict[@"imageList"] firstObject];
            self.successFromCloud = [imageListDict[@"Success"] boolValue];
            if (self.successFromCloud) {
                
                NSDictionary *tempImageData =   [JsonUtil dictionaryFromKey:@"imageData" inDictionary:imageListDict];
                self.fileName =            [JsonUtil stringFromKey:@"FileName" inDictionary:tempImageData];
                self.fileCode =            [JsonUtil stringFromKey:@"Code" inDictionary:tempImageData];
                self.serverFileURL =       [JsonUtil stringFromKey:@"Url" inDictionary:tempImageData];
                self.userCode =                 [JsonUtil stringFromKey:@"UserCode" inDictionary:tempImageData];
                self.imageId =             [JsonUtil numberFromKey:@"ID" inDictionary:tempImageData];

            }
        }
    }
    return self;
}

-(instancetype)initWithFriendsList:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        NSDictionary *aaDataDict =      [JsonUtil dictionaryFromKey:@"aaData" inDictionary:dict];
        self.isSuccess =                [JsonUtil booleanFromKey:@"Success" inDictionary:aaDataDict];
        if (self.isSuccess)
        {
            self.friendList = [[JsonUtil arrayFromKey:@"friends" inDictionary:aaDataDict] mutableCopy];
            
//
        }
    }
    return self;
}

-(instancetype)initWithAllUsers:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        NSDictionary *aaDataDict =      [JsonUtil dictionaryFromKey:@"aaData" inDictionary:dict];
        self.isSuccess =                [JsonUtil booleanFromKey:@"Success" inDictionary:aaDataDict];
        if (self.isSuccess)
        {
            self.allUsers = [[JsonUtil arrayFromKey:@"Users" inDictionary:aaDataDict] mutableCopy];

        }
    }
    return self;
}

-(instancetype)initWithAllFriendsRequests:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        NSDictionary *aaDataDict =      [JsonUtil dictionaryFromKey:@"aaData" inDictionary:dict];
        self.isSuccess =                [JsonUtil booleanFromKey:@"Success" inDictionary:aaDataDict];
        if (self.isSuccess)
        {
            self.allFriendRequests = [[JsonUtil arrayFromKey:@"MyRequests" inDictionary:aaDataDict] mutableCopy];
        }
    }
    return self;
}

-(instancetype)initWithAcceptFriendRequest:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        NSDictionary *aaDataDict =      [JsonUtil dictionaryFromKey:@"aaData" inDictionary:dict];
        self.isConform =                [JsonUtil booleanFromKey:@"Success" inDictionary:aaDataDict];
        
    }
    return self;
}

-(instancetype)initWithIgnoreFriendRequest:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        NSDictionary *aaDataDict =      [JsonUtil dictionaryFromKey:@"aaData" inDictionary:dict];
        self.isIgnore =                [JsonUtil booleanFromKey:@"Success" inDictionary:aaDataDict];
    }
    return self;
}


-(instancetype)initWithMakeAFriendsRequest:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        NSDictionary *aaDataDict =      [JsonUtil dictionaryFromKey:@"aaData" inDictionary:dict];
        self.isRequestSucess =                [JsonUtil booleanFromKey:@"Success" inDictionary:aaDataDict];
    }
    return self;
}


@end
