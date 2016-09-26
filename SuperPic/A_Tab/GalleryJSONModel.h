//
//  GalleryJSONModel.h
//  SuperPic
//
//  Created by Prince on 9/6/16.
//  Copyright © 2016 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Daikiri.h"

@interface GalleryJSONModel : Daikiri

@property(strong,nonatomic) NSNumber* Success;
@property(strong,nonatomic) NSArray*  ImageData;


@end