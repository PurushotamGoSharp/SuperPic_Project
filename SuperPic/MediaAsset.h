//
//  MediaAsset.h
//  MUKMediaGallery Example
//
//  Created by Marco on 26/06/13.
//  Copyright (c) 2013 MeLive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaAsset : NSObject
@property (nonatomic) MUKMediaKind kind;
@property (nonatomic) NSURL *thumbnailURL, *URL;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSString *caption;
@property (nonatomic) NSString *code;
@property (nonatomic) NSString *ownercode;
@property (nonatomic) NSString *date;
- (instancetype)initWithKind:(MUKMediaKind)kind;

@end
