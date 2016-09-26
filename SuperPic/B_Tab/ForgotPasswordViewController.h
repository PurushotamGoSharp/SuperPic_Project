//
//  ForgotPasswordViewController.h
//  SuperPic
//
//  Created by Syed Hyder Zubair on 14/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "BaseViewController.h"

@interface ForgotPasswordViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITextField *emailFTF;

- (IBAction)forgotPasswordAction:(id)sender;

@end
