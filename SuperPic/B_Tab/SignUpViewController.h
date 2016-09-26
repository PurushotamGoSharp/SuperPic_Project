//
//  SignUpViewController.h
//  SuperPic
//
//  Created by Syed Hyder Zubair on 14/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import "SuperPicAsset.h"

@interface SignUpViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *userNamerTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *signUpBtn;

@property (strong, nonatomic) SuperPicAsset *assetRegisterSuccess;

- (IBAction)signUpUserAction:(id)sender;

//@property (nonatomic, strong) SuperPicSignUpAsset *asset;


@end
