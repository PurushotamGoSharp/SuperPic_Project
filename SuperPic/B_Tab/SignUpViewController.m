//
//  SignUpViewController.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 14/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "SignUpViewController.h"

#import "AppDelegate.h"
#import "Constant.h"
#import "DataProvider.h"

#import "Utility.h"

#import "MBProgressHUD.h"

#import "ParseHandler.h"

@interface SignUpViewController ()<ParseHandlerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewOutlet;

- (void)newUserRegistration;
- (void)notifyUser:(SuperPicAsset *)signUpAsset;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    self.hidesBottomBarWhenPushed = YES;
    
    UIView *paddingForUserName = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    self.userNamerTF.leftView = paddingForUserName;
    self.userNamerTF.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingForEmail = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    self.emailTF.leftView = paddingForEmail;
    self.emailTF.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingForPassword = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    self.passwordTF.leftView = paddingForPassword;
    self.passwordTF.leftViewMode = UITextFieldViewModeAlways;

    [self setUpCntlr];
}

- (void)setUpCntlr {
    // Do any additional setup after loading the view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
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
    

    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height+40, 0.0);
    self.scrollViewOutlet.contentInset = contentInsets;
    self.scrollViewOutlet.scrollIndicatorInsets = contentInsets;
    
    
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

-(void)dismissKeyboard
{
    //Hiding Keypad
    [self.userNamerTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self.emailTF resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)signUpUserAction:(id)sender {
    NSString *uNStr =   self.userNamerTF.text;
    NSString *pStr =    self.passwordTF.text;
    NSString *emailStr =    self.emailTF.text;
    
    if ([uNStr length] == 0 || [pStr length] == 0 || [emailStr length] == 0) {
        [self toast:@"Please, Enter User name/Email ID/Password."];
        return;
    }
    
    if (![Utility validateEmail:emailStr]) {
        [self toast:@"Please! Enter valid mail Id."];
        return;
    }
//    [self.signUpBtn setEnabled:NO];
    __typeof(self) __weak weakSelf = self;
    DataProvider *tempDataProvider = [DataProvider new];
    NSString *urlString = [NSString stringWithFormat:PROFILE_NAME_DUPLICATE_CHECH_URL, self.userNamerTF.text];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [tempDataProvider getJsonContentWithUrl:urlString completion:^(BOOL success, id responseJsonObject, id responseObject, NSError *error) {
        if (success) {
            NSDictionary *dataDictionary = (NSDictionary *)responseJsonObject;
            NSLog(@"responsejsonobject = %@", responseJsonObject);
            SuperPicAsset *asset = [[SuperPicAsset alloc] initWithCheckDuplicateDictionary:dataDictionary];
            NSLog(@"asset = %@", [asset description]);
            if (!asset.isUserExisted) {
                [weakSelf newUserRegistration];
            }
            else {
                [weakSelf toast:@"Duplicate User! please sign In with different profile name"];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
        }
        else {
            [weakSelf toast:responseJsonObject];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            [weakSelf toast:[NSString stringWithFormat:@"%@", error.description]];
//            NSLog(@"Err: %@", error.description);
        }
    }];
}

- (void)newUserRegistration {
    __typeof(self) __weak weakSelf = self;
    DataProvider *dP = [DataProvider new];

    NSString *deviceToken = [[NSUserDefaults standardUserDefaults]objectForKey:Device_Token_CURRENT];

    NSString *parameters = [NSString stringWithFormat:@"{\"request\":{\"email\":\"%@\",\"profileName\":\"%@\",\"password\":\"%@\",\"deviceToken\":\"%@\"}}", self.emailTF.text, self.userNamerTF.text, self.passwordTF.text,deviceToken];
    

    [dP postJsonContentWithUrl:USER_REGISTER_URL parameters:parameters completion:^(BOOL success, id responseJsonObject, id responseObject, NSError *error) {
        if (success) {
            NSDictionary *dataDictionary = (NSDictionary *)responseJsonObject;
            self.assetRegisterSuccess = [[SuperPicAsset alloc] initWithDictionary:dataDictionary];
            [weakSelf.signUpBtn setEnabled:YES];

            [[NSUserDefaults standardUserDefaults] setObject:self.assetRegisterSuccess.userCode forKey:CURRENT_USER_CODE];
            
            AppDelegate *appDelegateTemp = [[UIApplication sharedApplication] delegate];
            [appDelegateTemp authenticateUser:self.userNamerTF.text savePassword:self.passwordTF.text];
            
            [OneSignal sendTag:@"usercode" value:self.assetRegisterSuccess.userCode];

           // [appDelegateTemp.oneSignal sendTag:@"usercode" value:self.assetRegisterSuccess.userCode];
            
            [appDelegateTemp showHomeScreen];
            
        }
        else
        {
            [weakSelf toast:responseJsonObject];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
    }];
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

#pragma mark - parse Handler Delegate
#pragma mark - ParseHandlerDelegate
- (void)completedParseReuest:(ParseResponseCode)response error:(NSString*)error
{
    __typeof(self) __weak weakSelf = self;
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    switch (response) {
        case ParseResponseSuccess:
            //
        {
            if ([ParseHandler sharedInstance].parseRequest == ParseRequestSignUp) {
                
                [weakSelf notifyUser:self.assetRegisterSuccess];
            }
            else if ( [ParseHandler sharedInstance].parseRequest == ParseRequestSignUpCheck )
            {
                
            }
//            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//            currentInstallation[@"user"] = [PFUser currentUser];
//            [currentInstallation addUniqueObject:@"update" forKey:@"channels"];
//            [currentInstallation saveInBackground];
        }
            break;
        case ParseResponseSignUpError:
            break;
        case ParseResponseUserAlreadyLoggedIn:
        default:
            break;
    }
}

- (void)analyzeResult
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
@end
