//
//  StagingCollectionViewCell.h
//  SuperPic
//
//  Created by Syed Hyder Zubair on 27/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "BaseCollectionViewCell.h"

@interface StagingCollectionViewCell : BaseCollectionViewCell

-(void)configureCell:(NSString *)sPStagingCaughtImgPath;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIImageView *selecteImgView;


@end
