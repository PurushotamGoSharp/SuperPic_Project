//
//  BaseViewController.h
//  SuperPic
//
//  Created by Syed Hyder Zubair on 14/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController<UIActionSheetDelegate,UIAlertViewDelegate>
//- (UIView *)customSelectedBackgroundView:(CGRect)rect;

//-(UIColor*) inverseColor:(UIColor *)oldColor;

- (void)goback;
- (void)backToHome;
- (void)toast:(NSString *)message;
//-(BOOL) NSStringIsValidEmail:(NSString *)checkString;
//- (BOOL) validateEmail:(NSString*) emailAddress

@end
