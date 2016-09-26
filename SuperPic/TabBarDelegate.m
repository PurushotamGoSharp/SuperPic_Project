//
//  TabBarDelegate.m
//  SuperPic
//
//  Created by Varghese Simon on 5/6/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "TabBarDelegate.h"
#import "A_Tab/HomeViewController.h"
#import "A_Tab/CameraPickedImageViewController.h"
#import "A_Tab/GalleryViewController.h"

@implementation TabBarDelegate
{
    id currentlySelectedVC;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    currentlySelectedVC = tabBarController.selectedViewController;
    
    return YES;
    
    
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    UINavigationController *navCon = (UINavigationController *)viewController;
    id viewC = [navCon.viewControllers firstObject];
    
    if ([viewC isKindOfClass:[CameraPickedImageViewController class]])
    {
        if (! [currentlySelectedVC isKindOfClass:[CameraPickedImageViewController class]])
        {
            CameraPickedImageViewController *cameraVC = (CameraPickedImageViewController *)viewC;
            cameraVC.commingFromHome = NO;
//            [cameraVC showImagePickerForCamera:nil];
        }
        
    }else if ([viewC isKindOfClass:[HomeViewController class]])
    {
        [navCon popToRootViewControllerAnimated:YES];
        HomeViewController *homeVC = (HomeViewController *)viewC;
        homeVC.isCommingFormCamera = NO;
    }else if ([viewC isKindOfClass:[GalleryViewController class]]) {
        [navCon popToRootViewControllerAnimated:YES];
    }
    
    currentlySelectedVC = nil;
}

- (void)dealloc
{
    NSLog(@"TAbDelegate DEALLOCED");
}

@end
