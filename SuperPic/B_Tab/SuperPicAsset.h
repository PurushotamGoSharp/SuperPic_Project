//
//  SuperPicSignUpAsset.h
//  SuperPic
//
//  Created by Syed Hyder Zubair on 29/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SuperPicAsset : NSObject

@property (assign, nonatomic) BOOL successFromCloud;

@property (nonatomic, strong) NSString *responseMessage;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSString *userCode;
@property (nonatomic, strong) NSString *emailId;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *userProfileName;

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, assign) NSInteger successCode;
//@property (nonatomic, strong) NSDictionary *user;
-(instancetype)initWithDictionary:(NSDictionary*)dict;


@property (nonatomic, assign) BOOL isUserExisted, isUserExistedResponse;
-(instancetype)initWithCheckDuplicateDictionary:(NSDictionary*)dict;

@property (nonatomic, assign) BOOL isSuccess, userStatus;
-(instancetype)initWithSignedInDictionary:(NSDictionary*)dict;

-(instancetype)initWithForgotPasswordDictionary:(NSDictionary*)dict;

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *fileCode;
@property (nonatomic, strong) NSString *serverFileURL;
@property (nonatomic, assign) NSInteger imageId;
//@property (nonatomic, assign) BOOL imageStatus;

-(instancetype)initWithFileUploadDictionary:(NSDictionary*)dict;

@property (nonatomic, strong) NSMutableArray *friendList;
//@property(nonatomic, strong)NSString *toUserCode;
-(instancetype)initWithFriendsList:(NSDictionary *)dict;


@property (nonatomic, strong) NSMutableArray *allUsers;
-(instancetype)initWithAllUsers:(NSDictionary *)dict;


@property (nonatomic, strong) NSMutableArray *allFriendRequests;
-(instancetype)initWithAllFriendsRequests:(NSDictionary *)dict;

@property (nonatomic, assign) BOOL isConform, isIgnore, isRequestSucess;
-(instancetype)initWithAcceptFriendRequest:(NSDictionary *)dict;
-(instancetype)initWithIgnoreFriendRequest:(NSDictionary *)dict;
-(instancetype)initWithMakeAFriendsRequest:(NSDictionary *)dict;




@end
