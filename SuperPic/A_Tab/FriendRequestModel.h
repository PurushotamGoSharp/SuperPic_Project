//
//  FriendRequestModel.h
//  SuperPic
//
//  Created by Vmoksha on 04/05/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendRequestModel : NSObject

@property(nonatomic,strong)NSString *code;
@property(nonatomic,strong)NSString *profileName;
@property(nonatomic,strong)NSString *email;
@property(nonatomic, readwrite)NSInteger  point;
@end
