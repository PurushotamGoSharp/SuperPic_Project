//
//  AppDelegate.h
//  SuperPic
//
//  Created by Syed Hyder Zubair on 14/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) Mixpanel *mixpanel;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSMutableArray *selectedFriendsArrList, *selectedFriendsIndexArrList, *recentlyCuaghtImagesArr;

@property (nonatomic,strong)NSMutableArray *frienssListsArrGloble;
@property (nonatomic) int caughtImagesCount;
@property (strong, nonatomic) OneSignal *oneSignal;
@property (nonatomic, readwrite) NSInteger currentIndex;
- (void)customizeSetUp;
- (void)showHomeScreen;
- (void)showLoganScreen;
- (void)showSignInScreen;

- (void)showHomeScreen1;
- (void)showGalleryScreen;

- (void)authenticateUser:(NSString *)userName savePassword:(NSString *)password;

#pragma mark - SuperPic DB

-(void) checkAndCreateDatabase;
-(NSString *)databaseName;
-(NSString *)databasePath;

-(NSString *)documentsDirectory;
-(void) sendPushToUsersbyTags:(NSMutableArray*) tags message:(NSString*)message;
@end

