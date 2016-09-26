//
//  Constant.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 28/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "Constant.h"

// http://superpic.azurewebsites.net/user/authenticate

@implementation Constant



//NSString *BASE_URL =                            @"http://tst-superpic.azurewebsites.net/";
NSString *BASE_URL =                            @"http://superpic.azurewebsites.net/";

#pragma mark - SP - POST Methods

NSString *USER_REGISTER_URL =                   @"user/register";
NSString *USER_AUTHENTICATION_URL =             @"user/authenticate";
NSString *FORGET_PASSWORD_URL =                 @"user/ForgotPassword";


NSString *ACCEPT_FRIEND_REQUEST_URL =           @"request/accept/";
NSString *FRIEND_REQUESTS_URL =                 @"request/friend";

NSString *IMAGE_SHARE_URL =                     @"picture/share";
NSString *FILE_UPLOAD_URL =                     @"picture/upload";
NSString *REJECT_FRIEND_REQUEST_URL =           @"request/reject/";

#pragma mark - Video share
NSString *VIDEO_SHARE_URL =                     @"sharevideo";
NSString *VIDEO_UPLOAD_URL =                     @"video/upload";


#pragma mark - SP - GET Methods

NSString *GET_UNREAD_URL            =           @"UnReadCount/";//0NQHMVJH6ZEP
NSString *USER_CODE_FRIEND_LIST_URL =           @"friends/%@";
NSString *USER_CODE_FRIEND_REQUEST_URL =        @"requests/%@";
NSString *GET_ALL_USERS_URL =                   @"Search";
NSString *CODE_GET_USER_URL =                   @"user/%@";
NSString *PROFILE_NAME_DUPLICATE_CHECH_URL =    @"user/profilename/%@";



#pragma mark - User default keys
NSString *SIGNED_UP_KEY =                       @"userSignedIn";
NSString *PROFILE_NAME_KEY =                    @"profileName";
NSString *CURRENT_USER_PASSWORD_KEY =           @"currentUserPassword";

// re-define

NSString *GET_ALL_FRIENDS_REQUEST_URL = @"requests/";


NSString *CURRENT_USER_CODE = @"CurrentUserCode";
NSString *CURRENT_USER_MAIL_ID = @"CurrentUserMailID";

NSString *FRIEND_LIST_URL = @"friends/";

NSString *FRIEND_REQUESTS_LISTS =@"requests/";

NSString *REQUEST_BOOL_KEY = @"request";

NSString *BADGE_COUNT = @"badgeCount";

NSString *Device_Token_CURRENT = @"DeviceToken";




//NSString *SEARCH_CELL =             @"SearchCell";

@end
