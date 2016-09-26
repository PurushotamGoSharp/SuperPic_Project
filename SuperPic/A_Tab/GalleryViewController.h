//
//  GalleryViewController.h
//  SuperPic
//
//  Created by Syed Hyder Zubair on 14/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import "MUKMediaThumbnailsViewController.h"
@interface GalleryViewController : MUKMediaThumbnailsViewController<UIActionSheetDelegate,UIAlertViewDelegate>
{
    BOOL bEnd;
}
@property (nonatomic, strong) NSMutableArray *mediaAssets;


@end
