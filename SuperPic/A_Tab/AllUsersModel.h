//
//  AllUsersModel.h
//  SuperPic
//
//  Created by Vmoksha on 01/05/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AllUsersModel : NSObject

@property(nonatomic,assign)NSInteger ID;
@property(nonatomic,strong)NSString *code;
@property(nonatomic,strong)NSString *profileName;
@property(nonatomic,strong)NSString *email;
@property(nonatomic, readwrite)NSInteger  point;

@end
