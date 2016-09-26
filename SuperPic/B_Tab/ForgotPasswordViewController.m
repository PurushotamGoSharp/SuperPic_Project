//
//  ForgotPasswordViewController.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 14/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "ForgotPasswordViewController.h"

#import "DataProvider.h"
#import "Constant.h"

#import "SignInViewController.h"
#import "AppDelegate.h"

#import "SuperPicAsset.h"

#import "MBProgressHUD.h"

@interface ForgotPasswordViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewOutlet;

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *paddingForemail = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    self.emailFTF.leftView = paddingForemail;
    self.emailFTF.leftViewMode = UITextFieldViewModeAlways;
    

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

- (void)dismissKeyboard {
    [self.emailFTF resignFirstResponder];
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

#pragma mark - Actions

- (IBAction)forgotPasswordAction:(id)sender {
    if ([self.emailFTF.text length] == 0) {
        [self toast:@"Please! Enter mail Id"];
        return;
    }
    
    NSString *parameters = [NSString stringWithFormat:@"{\"request\":{\"email\":\"%@\"}}", self.emailFTF.text];
    __typeof(self) __weak weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    DataProvider *dP = [DataProvider new];
    [dP postJsonContentWithUrl:FORGET_PASSWORD_URL parameters:parameters completion:^(BOOL success, id responseJsonObject, id responseObject, NSError *error) {
        if (success) {
            NSDictionary *dataDictionary = (NSDictionary *)responseJsonObject;
            SuperPicAsset *asset = [[SuperPicAsset alloc] initWithForgotPasswordDictionary:dataDictionary];
            if (asset.isSuccess) {
                [weakSelf notifyUserPassword:asset];
                AppDelegate *appDelegateTemp = [[UIApplication sharedApplication] delegate];

                [appDelegateTemp showSignInScreen];
            }
            else {
                [weakSelf toast:@"Invalid email. Please try again"];
            }
        }
        else {
            [weakSelf toast:responseJsonObject];
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    }];
}

- (void)notifyUserPassword:(SuperPicAsset *)asset {
    [self toast:asset.responseMessage];
}

@end
