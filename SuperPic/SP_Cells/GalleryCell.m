//
//  GalleryCell.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 23/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "GalleryCell.h"
#import "UIImageView+AFNetworking.h"
#import "SDImageCache.h"
@implementation GalleryCell

-(void)awakeFromNib {
    self.imageView.clipsToBounds        = YES;
    self.selecteImgView.clipsToBounds   = YES;
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.selecteImgView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)configureCell:(GallerysModel *)model {

    if ([model.filetype isEqualToString:@"video"]) {
        self.videoImageView.hidden = false;
        
        
        UIImage* image =  [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.code];
        if (image) {
            [self.imageView setImage:image];
        }else
        {
            [self.imageView setImage:[UIImage imageNamed:@"default-placeholder_video"]];
            [self.imageView setContentMode:UIViewContentModeScaleToFill];
            
            //                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:imageView , @"imageView", messageString, @"itemurl", nil];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                
                NSURL *url = [NSURL URLWithString:model.thumbnailurl];
                
                AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:url options:nil];
                AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                imageGenerator.maximumSize = CGSizeMake(100, 100);
                Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
                CMTime midpoint = CMTimeMakeWithSeconds(0, 600);
                NSError* error = nil;
                CMTime actualTime;
                
                CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
                
                UIImage* resultUIImage = nil;
                if (halfWayImage != NULL) {
                    resultUIImage = [UIImage imageWithCGImage:halfWayImage];
                    
                    CGImageRelease(halfWayImage);
                    
                    UIImage* resizedImage = resultUIImage;
                    
                    if (self.imageView != nil) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.imageView setImage:resizedImage];
                            [[SDImageCache sharedImageCache] storeImage:resizedImage forKey:model.code];
                        });
                    }
                    
                    
                }
                else
                {
                    
                    
                }
            });
            
            //                [self performSelectorInBackground:@selector(generateThumbImage:) withObject:dict];
        }
        
        
    }else{
        self.videoImageView.hidden = true;
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:model.thumbnailurl]
                                                      cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                  timeoutInterval:60];
        [self.imageView setImageWithURLRequest:imageRequest
                              placeholderImage:[UIImage imageNamed:@"default-placeholder"]
                                       success:nil
                                       failure:nil];
    }
    
//    [self.imageView setImage:[UIImage imageWithContentsOfFile:sPLocalGalleryImgPath]];
    if (model.read == 0)
        [self.selecteImgView setHidden:false];
    else
        [self.selecteImgView setHidden:true];
}

// -(void)configureCell:(SupperPicAsset *)asset

#pragma mark -  Action

- (IBAction)showGalleryImageAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(galleryImageButtonPressed:)]) {
        [self.delegate galleryImageButtonPressed:self];
    }
}

@end
