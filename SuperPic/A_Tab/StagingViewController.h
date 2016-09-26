//
//  StagingViewController.h
//  SuperPic
//
//  Created by Varghese Simon on 4/15/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface StagingViewController : BaseViewController

//@property (weak, nonatomic) IBOutlet UIButton *friendRemoveBtn;
@property (nonatomic, strong) NSMutableArray *stagingGalleryImgsArr;



- (IBAction)shareAndUploadImages:(id)sender;
- (IBAction)selectHomeFriends:(id)sender;

@end
