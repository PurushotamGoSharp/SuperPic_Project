//
//  GallerysModel.h
//  SuperPic
//
//  Created by Vmoksha on 07/05/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Daikiri.h"


@interface GallerysModel : Daikiri
//@property (nonatomic,strong)NSString *url;
//@property (nonatomic,strong)NSString *thumbnailURL;
//@property (nonatomic,strong)NSString *name;
//@property (nonatomic,strong)NSDate *dateCreated;
//@property (nonatomic,strong)NSString *dateCreatedString;
//@property (nonatomic,strong)NSString *code;
//@property (nonatomic,strong)NSString *filetype;
//@property (nonatomic,strong)NSString *ownername;
//@property (nonatomic,strong)NSString *ownercode;
//
//@property (nonatomic,readwrite)BOOL read;
//@property (nonatomic,assign)BOOL deleted;
//

@property (nonatomic,strong)NSString *url;
@property (nonatomic,strong)NSString *code;
@property (nonatomic,strong)NSString *sharedcode;
@property (nonatomic,strong)NSString *datecreated;
@property (nonatomic,strong)NSString *filename;
@property (nonatomic,strong)NSString *filetype;
@property (nonatomic,strong)NSString *ownercode;
@property (nonatomic,strong)NSString *ownername;
@property (nonatomic,strong)NSNumber *read;
@property (nonatomic,strong)NSString *thumbnailurl;




@end
