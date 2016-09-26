//
//  CameraPickedImageViewController.h
//  SuperPic
//
//  Created by Syed Hyder Zubair on 15/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "MDRadialProgressLabel.h"

@interface CameraPickedImageViewController : BaseViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (IBAction)takeToBackHome:(id)sender;
- (IBAction)showImagePickerForCamera:(id)sender;


@property (strong, atomic) ALAssetsLibrary* library;
@property (assign, nonatomic) BOOL commingFromHome;
@property (assign, nonatomic) BOOL photoorvideo;
@property (nonatomic,retain) MDRadialProgressView * radialView;
@property (nonatomic,retain) NSTimer* timerRecord;
@property (nonatomic, assign) int duration;
@end
