//
//  SPSQLiteManager.h
//  SuperPic
//
//  Created by Syed Hyder Zubair on 01/05/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPSQLiteManager : NSObject {
    NSString *imageName, *imageURL, *userName;
    NSInteger status, rowId;
    
}

- (id)init;
- (void)addImageInfoRecord;
- (BOOL)findImage:(NSString *)imgName;

@property (nonatomic, readonly) NSInteger rowId;

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *imageCode;

@property (nonatomic) NSInteger status;




@end
