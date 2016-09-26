//
//  GalleryCell.h
//  SuperPic
//
//  Created by Syed Hyder Zubair on 23/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "BaseCollectionViewCell.h"
#import "GallerysModel.h"
@protocol GalleryCellDelegate <NSObject>

-(void)galleryImageButtonPressed:(id)cell;

@end

@interface GalleryCell : BaseCollectionViewCell

- (void)configureCell:(GallerysModel *)model;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIImageView *videoImageView;
@property (nonatomic, weak) IBOutlet UIImageView *selecteImgView;

@property (nonatomic, weak) IBOutlet UIButton *galleryViewBtn;

@property (nonatomic,weak) id <GalleryCellDelegate> delegate;

- (IBAction)showGalleryImageAction:(id)sender;

@end
