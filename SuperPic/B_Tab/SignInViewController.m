//
//  SignInViewController.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 14/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "SignInViewController.h"

#import "AppDelegate.h"
#import "Constant.h"
#import "DataProvider.h"

#import "MBProgressHUD.h"
#import <CoreData/CoreData.h>
#import "ParseHandler.h"

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameSITF;
@property (weak, nonatomic) IBOutlet UITextField *passwordSITF;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewOutlet;

- (void)notifySignedInUser:(SuperPicAsset *)signUpAsset;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *paddingForUserName = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    self.userNameSITF.leftView = paddingForUserName;
    self.userNameSITF.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingForPassword = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    self.passwordSITF.leftView = paddingForPassword;
    self.passwordSITF.leftViewMode = UITextFieldViewModeAlways;


    
//    myTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);

//    self.userNameSITF.layer.sublayerTransform = CATransform3DMakeTranslation(100, 0, 0);
    
    [self setUpCntlr];
    self.navigationController.navigationBarHidden = YES;
    self.hidesBottomBarWhenPushed = YES;

}

- (void)setUpCntlr {
    // Do any additional setup after loading the view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    
    
    [self.view addGestureRecognizer:tap];
    
    NSString *tempUserName = [[NSUserDefaults standardUserDefaults] objectForKey:PROFILE_NAME_KEY];
    NSString *tempCurrentUserPassword = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_USER_PASSWORD_KEY];
    
    if ([tempUserName length] > 0) {
        if ([tempCurrentUserPassword length] > 0)
        {
            [self.userNameSITF setText:tempUserName];
            [self.passwordSITF setText:tempCurrentUserPassword];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self registerForKeyboardNotifications];

}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //    if ([activeField isEqual:enterUserNameTextField])
    //    {
    //        kbSize.height = self.tableView.frame.size.height - 80;
    //    }
    //
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height+40, 0.0);
    self.scrollViewOutlet.contentInset = contentInsets;
    self.scrollViewOutlet.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
//    CGRect aRect = self.view.frame;
//    [self.scrollViewOutlet scrollRectToVisible:aRect animated:YES];
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollViewOutlet.contentInset = contentInsets;
    self.scrollViewOutlet.scrollIndicatorInsets = contentInsets;
}

- (IBAction)backBtnAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];

}



-(void)dismissKeyboard {
    
    //Hiding Keypad
    [self.userNameSITF resignFirstResponder];
    [self.passwordSITF resignFirstResponder];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 #pragma mark - Navigation
 //[[NSUserDefaults standardUserDefaults] set
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 //
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
//     if ([[segue identifier] isEqualToString:@"SignedInIdentifier"]) {
//         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SignedIn"];
//     }
 }
- (void)toast:(NSString *)message {
    int duration = 2; // duration in seconds
    
    if ([UIAlertController class])
    {
        
        UIAlertController *toast = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:toast animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [toast dismissViewControllerAnimated:YES completion:^{
                NSLog(@"toast dismissed");
            }];
        });
    }
    else {
        UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil, nil];
        [toast show];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [toast dismissWithClickedButtonIndex:0 animated:YES];
        });
        
    }
}

- (IBAction)signInuserAction:(id)sender {
    
    NSString *uNStr =   self.userNameSITF.text;
    NSString *pStr =    self.passwordSITF.text;
    
    if ([uNStr length] == 0 || [pStr length] == 0) {
        [self toast:@"Please enter user name/password"];
        return;
    }
    // {"request":{"profileName":"prasad","password":"prasad"}}
    
    NSString *parameters = [NSString stringWithFormat:@"{\"request\":{\"profileName\":\"%@\",\"password\":\"%@\"}}", self.userNameSITF.text, self.passwordSITF.text];
    
    __typeof(self) __weak weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    DataProvider *dP = [DataProvider new];
    [dP postJsonContentWithUrl:USER_AUTHENTICATION_URL parameters:parameters completion:^(BOOL success, id responseJsonObject, id responseObject, NSError *error) {
        if (success)
        {
            NSDictionary *dataDictionary = (NSDictionary *)responseJsonObject;
            SuperPicAsset *asset = [[SuperPicAsset alloc] initWithSignedInDictionary:dataDictionary];
            if (asset.isSuccess)
            {

                
                
                [weakSelf notifySignedInUser:asset];

                
                if ([[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_USER_CODE]) {
                    
                    
                    
                }
                [[NSUserDefaults standardUserDefaults] setObject:asset.userCode forKey:CURRENT_USER_CODE];
                
                
            }
            else
            {

                [weakSelf toast:asset.responseMessage];

            }
        }
        else {
            [weakSelf toast:@"Check Internet connection"];
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    }];
}

- (void)notifySignedInUser:(SuperPicAsset *)asset {
//    [self toast:@"Signed In - Successfully"];
    AppDelegate *appDelegateTemp = [[UIApplication sharedApplication] delegate];
    [appDelegateTemp authenticateUser:self.userNameSITF.text savePassword:self.passwordSITF.text];
    if (asset.userCode.length > 0)
    {
        //t--[UAirship push].tags = @[asset.userCode];
        //t--[[UAirship push] updateRegistration];

        NSSet* tags = [[NSSet alloc] initWithObjects:asset.userCode, nil];
        
     
    
        NSData* deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
        
        
        [[NSUserDefaults standardUserDefaults] setObject:asset.userCode forKey:CURRENT_USER_CODE];
        [[NSUserDefaults standardUserDefaults] setObject:asset.emailId forKey:CURRENT_USER_MAIL_ID];

        
        
        [OneSignal sendTag:@"usercode" value:asset.userCode];
 
       // [appDelegateTemp.oneSignal sendTag:@"usercode" value:asset.userCode];
        
        
        
        
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [appDelegateTemp showHomeScreen];
    
}

@end
