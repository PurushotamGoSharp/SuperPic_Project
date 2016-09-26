//
//  Constant.h
//  SuperPic
//
//  Created by Syed Hyder Zubair on 28/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constant : NSObject

extern NSString *BASE_URL;

extern NSString *USER_REGISTER_URL;
extern NSString *USER_AUTHENTICATION_URL;
extern NSString *FORGET_PASSWORD_URL;

extern NSString *USER_CODE_FRIEND_LIST_URL;
extern NSString *ACCEPT_FRIEND_REQUEST_URL;
extern NSString *FRIEND_REQUESTS_URL;
extern NSString *USER_CODE_FRIEND_REQUEST_URL;
extern NSString *GET_ALL_USERS_URL;
extern NSString *CODE_GET_USER_URL;
extern NSString *IMAGE_SHARE_URL;
extern NSString *FILE_UPLOAD_URL;
extern NSString *PROFILE_NAME_DUPLICATE_CHECH_URL;
extern NSString *REJECT_FRIEND_REQUEST_URL;
extern NSString *GET_UNREAD_URL;
extern NSString *VIDEO_SHARE_URL;
extern NSString *VIDEO_UPLOAD_URL;

#pragma mark - User default keys
extern NSString *SIGNED_UP_KEY;
extern NSString *PROFILE_NAME_KEY;
extern NSString *CURRENT_USER_PASSWORD_KEY;
extern NSString *CURRENT_USER_CODE;
extern NSString *CURRENT_USER_MAIL_ID;
extern NSString *FRIEND_LIST_URL;

extern NSString *FRIEND_REQUESTS_LISTS;

extern NSString *REQUEST_BOOL_KEY;
extern NSString *BADGE_COUNT;

extern NSString *GET_ALL_FRIENDS_REQUEST_URL;
extern NSString *Device_Token_CURRENT;


#pragma mark - Cell Identifiers
//extern NSString *SEARCH_CELL;



@end
