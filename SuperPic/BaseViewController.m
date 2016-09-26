//
//  BaseViewController.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 14/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "ForgotPasswordViewController.h"
#import "SPFirstViewController.h"
#import "ShareViewController.h"
#import "TermsAndConditionsViewController.h"
#import "AppDelegate.h"
#import "Constant.h"
#import "HomeViewController.h"
#import "AddContactsViewController.h"


//t--#import "UAirship.h"
//t--#import "UAConfig.h"
//t--#import "UAPush.h"

@interface BaseViewController ()<UIActionSheetDelegate,UIAlertViewDelegate>

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customizeBaseSubViewControllers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.7
}

- (void)customizeBaseSubViewControllers {
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"SignedIn"]) {
        //    [self.navigationController.navigationBar setTintColor:[UIColor clearColor]];
        //    [[UINavigationBar appearance] setBarTintColor:[UIColor clearColor]];
    UIViewController *tempVC = self.navigationController.topViewController;

    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"NavBar"] resizableImageWithCapInsets:(UIEdgeInsetsMake(0, 0, 40, 115))] forBarMetrics:UIBarMetricsDefault];

//    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:.13 green:.31 blue:.46 alpha:1]];

    UIButton *logOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logOutBtn setBackgroundColor:[UIColor clearColor]];
    [logOutBtn addTarget:self action:@selector(logOut) forControlEvents:UIControlEventTouchUpInside];
    logOutBtn.frame = CGRectMake(0, 0, 100, 30);
    UIBarButtonItem *logOut = [[UIBarButtonItem alloc] initWithCustomView:logOutBtn] ;
    self.navigationItem.rightBarButtonItem = logOut;

    if ([tempVC isKindOfClass:[SPFirstViewController class]] | [tempVC isKindOfClass:[SignUpViewController class]] | [tempVC isKindOfClass:[SignInViewController class]] | [tempVC isKindOfClass:[ForgotPasswordViewController class]] | [tempVC isKindOfClass:[TermsAndConditionsViewController class]])
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = YES;
    }

    
    UIViewController *vc = [[self.navigationController viewControllers] firstObject];
    
    
    if(![vc isEqual: self.navigationController.topViewController])
    {
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *backBtnImage = [UIImage imageNamed:@"BackButtonWhite750x1334"];
        if ([vc isKindOfClass:[SPFirstViewController class]] | [vc isKindOfClass:[SignUpViewController class]] | [vc isKindOfClass:[SignInViewController class]] | [vc isKindOfClass:[ForgotPasswordViewController class]] | [vc isKindOfClass:[TermsAndConditionsViewController class]] | [vc isKindOfClass:[ShareViewController class]] | [vc isKindOfClass:[AddContactsViewController class]])
        {
            backBtnImage = [UIImage imageNamed:@"BackButton"];
            
        }
        
    
        [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(goback) forControlEvents:UIControlEventTouchUpInside];
        backBtn.frame = CGRectMake(0, 0, 30, 30);
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn] ;
        self.navigationItem.leftBarButtonItem = backButton;

        
    }
    

    
    //Created object of tab bar item
    UITabBarItem *tabBarItem1 = [self.tabBarController.tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [self.tabBarController.tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [self.tabBarController.tabBar.items objectAtIndex:2];
    
    
    // Assign tab bar item with titles
    [tabBarItem1 setTitle:@""];
    [tabBarItem2 setTitle:@""];
    [tabBarItem3 setTitle:@""];
    
    
    
    tabBarItem1.image = [[UIImage imageNamed:@"tabhome"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem1.selectedImage = [[UIImage imageNamed:@"tabhome_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem2.image = [[UIImage imageNamed:@"tabcamera"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem2.selectedImage = [[UIImage imageNamed:@"tabcamera_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //
    tabBarItem3.image = [[UIImage imageNamed:@"tabgallery"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem3.selectedImage = [[UIImage imageNamed:@"tabgallery_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem1.imageInsets = UIEdgeInsetsMake(8, 0, -6, 0);
    tabBarItem2.imageInsets = UIEdgeInsetsMake(8, 0, -6, 0);
    tabBarItem3.imageInsets = UIEdgeInsetsMake(8, 0, -6, 0);
    
    
   // tabBarItem3.badgeValue = @"0";
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:1.0f];
    // removed warning by changing the key from UITextAttributeFont to  NSFontAttributeName
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:70.0/255 green:117.0/255 blue:131.0/255 alpha:1],NSForegroundColorAttributeName, font, NSFontAttributeName, nil]
                                             forState:UIControlStateSelected];
    
    //Set custom font and color  for all tab bar item text at unselected state
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : font,NSForegroundColorAttributeName : [UIColor colorWithRed:166.0/255 green:166.0/255 blue:166.0/255 alpha:1 ]
                                                        
                                                        } forState:UIControlStateNormal];
}

- (void)goback
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)logOut

{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Logout", nil];
    [actionSheet showInView:self.view];

    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        UIAlertView *logOutAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        
        [logOutAlert show];

    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SIGNED_UP_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PROFILE_NAME_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:CURRENT_USER_PASSWORD_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [appDel.selectedFriendsArrList removeAllObjects];
        [appDel.recentlyCuaghtImagesArr removeAllObjects];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:CURRENT_USER_CODE];

        
        [appDel showLoganScreen];
        
        
    }

}


- (void)backToHome {
    self.tabBarController.tabBar.hidden = NO;
    
    if (self.tabBarController.selectedIndex == 0) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    if (self.tabBarController.selectedIndex == 1) {
        UIViewController * target = [[self.tabBarController viewControllers] objectAtIndex:1];
        
        [target.navigationController popToRootViewControllerAnimated: NO];
        [self.tabBarController setSelectedIndex:0];
    }
}

- (void)toast:(NSString *)message {
    int duration = 3; // duration in seconds
    
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

@end
