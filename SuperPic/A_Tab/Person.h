//
//  Person.h
//  JPlus
//
//  Created by Varghese Simon on 4/3/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Person : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *homeEmail;
@property (nonatomic, strong) NSString *workEmail;
@property (nonatomic, assign) NSInteger uniqueID;
@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic,strong)    NSMutableArray *arrOfPhoneNumbers;



@end
