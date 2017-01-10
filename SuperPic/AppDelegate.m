//
//  AppDelegate.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 14/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

/// Comment for urban sdk //t--

#import "AppDelegate.h"

#import "Constant.h"
#import "TabBarDelegate.h"

#import "ParseHandler.h"
#import "MBProgressHUD.h"
#import "DataProvider.h"
#import <OneSignal/OneSignal.h>

#define BASEPUSHURL @"https://onesignal.com/api/v1/notifications"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    TabBarDelegate *tabDelegate;
    UITabBarController* rootTabBarController;
    BOOL bLoadUnread;
}
@synthesize selectedFriendsArrList, selectedFriendsIndexArrList, recentlyCuaghtImagesArr;
@synthesize caughtImagesCount;


-(void)setFrienssListsArrGloble:(NSMutableArray *)frienssListsArrGloble
{
    _frienssListsArrGloble = frienssListsArrGloble;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    
//    self.oneSignal = [[OneSignal alloc] initWithLaunchOptions:launchOptions
//                                                        appId:@"78b48c09-e5d8-4a2f-95b7-27093c194e35"
//                                           handleNotification:nil];
    
    [OneSignal initWithLaunchOptions:launchOptions appId:@"5eb5a37e-b458-11e3-ac11-000c2940e62c"];
    [ParseHandler sharedInstance];
    [self customizeSetUp];

    ////////Parse notification code block
    {
        
        
        if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
        {
            // iOS 8 Notifications
            [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];

            [application registerForRemoteNotifications];
        }
        else
        {
            // iOS < 8 Notifications
            [application registerForRemoteNotificationTypes:
             (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
        }
    }
    //////////parse notification code block

    ////////// restore receive notification
    NSDictionary* remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];

    if (remoteNotif)
        [self handleRemoteNotifications:remoteNotif];

    ///////////
    bLoadUnread = false;
    [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(rootTimer:) userInfo:nil repeats:YES];
    
    self.mixpanel = [Mixpanel sharedInstanceWithToken:@"9d70884ab80b1dc8eaea2714a045b2ab" launchOptions:launchOptions];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:PROFILE_NAME_KEY] != nil)
        [self.mixpanel track:@"Launch" properties:@{  @"username" : [[NSUserDefaults standardUserDefaults] objectForKey:PROFILE_NAME_KEY]}];
    
    ///////////
    return YES;
}

- (void) rootTimer:(NSTimer*)timer
{
    if (bLoadUnread)
        return;

    bLoadUnread = true;
    DataProvider *tempDataProvider = [DataProvider new];
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *curentUserCode =  [[NSUserDefaults standardUserDefaults] valueForKey:CURRENT_USER_CODE];
 
    
    [tempDataProvider getJsonContentWithUrl:[NSString stringWithFormat:@"%@%@",GET_UNREAD_URL,curentUserCode] completion:^(BOOL success, id responseJsonObject, id responseObject, NSError *error) {
        bLoadUnread = false;
        if (success) {
            NSDictionary *dataDictionary = (NSDictionary *)responseJsonObject;
            NSDictionary* aaData = [dataDictionary objectForKey:@"aaData"];
            int unreadImageCount = [[aaData objectForKey:@"UnreadImageCount"] intValue];
            int unreadRequestCount = [[aaData objectForKey:@"UnreadRequestCount"] intValue];

            if (unreadImageCount > 0) {
                [[NSUserDefaults standardUserDefaults]setInteger:unreadImageCount forKey:@"GalleryBadgeCount"];
                [[NSUserDefaults standardUserDefaults] synchronize];

                UITabBarItem* tabbarItem = rootTabBarController.tabBar.items[2];
                NSInteger gallerycount = [[NSUserDefaults standardUserDefaults]integerForKey:@"GalleryBadgeCount"];
                tabbarItem.badgeValue = [NSString stringWithFormat:@"%d", (int)gallerycount];

                [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationRespondToShareImage" object:nil];
            }

            if (unreadRequestCount > 0) {
                [[NSUserDefaults standardUserDefaults]setInteger:unreadRequestCount forKey:BADGE_COUNT];
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:REQUEST_BOOL_KEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationRespondToShareImage" object:nil];
            }
            
        }
        else {

        }
    }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
    [d setObject:deviceToken forKey:@"token"];
    [d synchronize];
    
    
    
}

-(void)MessageBox:(NSString *)title message:(NSString *)messageText
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:messageText delegate:self
                                          cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"Application did register with user notification types %ld", (unsigned long)notificationSettings.types);
//t--    [[UAirship push] appRegisteredUserNotificationSettings];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
//t--    NSLog(@"Application failed to register for remote notifications with error: %@", error);
}
- (void) handleRemoteNotifications:(NSDictionary*)userInfo{
    NSLog(@"Application received remote notification: %@", userInfo);
   
    
    
    NSLog(@"userinfo = %@", userInfo);
    NSLog(@"category = %@", userInfo[@"ShareImage"]);
    //if ([userInfo[@"category"]isEqualToString:@"FriendRequest"])
    if ([userInfo[@"category"]isEqualToString:@"FriendRequest"])
    {
        NSLog(@"notification From gallary ");
        NSInteger count = [[NSUserDefaults standardUserDefaults]integerForKey:BADGE_COUNT];
        [[NSUserDefaults standardUserDefaults]setInteger:count+1 forKey:BADGE_COUNT];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:REQUEST_BOOL_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //
        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"RequestNotification" object:nil];
        
        //        NSInteger count = [[NSUserDefaults standardUserDefaults]integerForKey:@"GalleryBadgeCount"];
        //        [[NSUserDefaults standardUserDefaults]setInteger:count+1 forKey:@"GalleryBadgeCount"];
        //        [[NSUserDefaults standardUserDefaults] synchronize];
        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"GalleryNotification" object:nil];
    }
    //else if ([userInfo[@"category"]isEqualToString:@"ShareImage"])
    else if ([userInfo[@"category"]isEqualToString:@"ShareImage"])
    {
        NSLog(@"notification From request ");
        
        
        
        NSInteger count = [[NSUserDefaults standardUserDefaults]integerForKey:@"GalleryBadgeCount"];
        
        NSString* photo_c = userInfo[@"photocount"];
        [[NSUserDefaults standardUserDefaults]setInteger:count+[photo_c intValue] forKey:@"GalleryBadgeCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UITabBarItem* tabbarItem = rootTabBarController.tabBar.items[2];
        NSInteger gallerycount = [[NSUserDefaults standardUserDefaults]integerForKey:@"GalleryBadgeCount"];
        tabbarItem.badgeValue = [NSString stringWithFormat:@"%d", (int)gallerycount];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationRespondToShareImage" object:nil];
        
    }else {
        
        
    }
    
    
    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self MessageBox:@"Notification" message:[[userInfo objectForKey:@"aps"] valueForKey:@"alert"]];
    /////////// Adjust application badgecount
    NSLog(@"userinfo = %@", userInfo);
    NSLog(@"category = %@", userInfo[@"ShareImage"]);
    //if ([userInfo[@"category"]isEqualToString:@"FriendRequest"])
    if ([userInfo[@"category"]isEqualToString:@"FriendRequest"])
    {
        NSLog(@"notification From gallary ");
                NSInteger count = [[NSUserDefaults standardUserDefaults]integerForKey:BADGE_COUNT];
                [[NSUserDefaults standardUserDefaults]setInteger:count+1 forKey:BADGE_COUNT];
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:REQUEST_BOOL_KEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
       
        
    }else if ([userInfo[@"category"]isEqualToString:@"ShareImage"])
    {
        NSLog(@"notification From request ");
        

        
        NSInteger count = [[NSUserDefaults standardUserDefaults]integerForKey:@"GalleryBadgeCount"];
        
        NSString* photo_c = userInfo[@"photocount"];
        [[NSUserDefaults standardUserDefaults]setInteger:count+[photo_c intValue] forKey:@"GalleryBadgeCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UITabBarItem* tabbarItem = rootTabBarController.tabBar.items[2];
        NSInteger gallerycount = [[NSUserDefaults standardUserDefaults]integerForKey:@"GalleryBadgeCount"];
        tabbarItem.badgeValue = [NSString stringWithFormat:@"%d", (int)gallerycount];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationRespondToShareImage" object:nil];

        
    }else {
        
        
    }
    
    
}


- (void)getNotification:(NSDictionary *)appInfo
{
    NSString *alert = appInfo[@"alert"];
    
    UIAlertView *alertForNotification =  [[UIAlertView alloc] initWithTitle:@"Notification" message:alert delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertForNotification show];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - pre data allocation

- (void)customizeSetUp
{
    self.selectedFriendsArrList         = [[NSMutableArray alloc] init];
    self.selectedFriendsIndexArrList    = [[NSMutableArray alloc] init];
    self.recentlyCuaghtImagesArr        = [[NSMutableArray alloc] init];
    
    self.caughtImagesCount = 0;
    
    
    
    BOOL authenticatedUser = [[NSUserDefaults standardUserDefaults] boolForKey:SIGNED_UP_KEY];
    if (authenticatedUser)
    {
        NSString* username = [[NSUserDefaults standardUserDefaults] objectForKey:PROFILE_NAME_KEY];
        NSString* password = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_USER_PASSWORD_KEY];

        [self showHomeScreen];
    }
    else
    {
        [self showLoganScreen];
    }
}

- (void)showLoganScreen {
    UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SPFirstVC_StoryBoard_ID"];
    UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
    
    self.window.rootViewController = navigation;
}

- (void)showSignInScreen {
    UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SPSignInSBIde"];
    UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
    
    self.window.rootViewController = navigation;
}

- (void)authenticateUser:(NSString *)userName savePassword:(NSString *)password {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SIGNED_UP_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:PROFILE_NAME_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:CURRENT_USER_PASSWORD_KEY];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showHomeScreen
{
    
    NSString *curentUserCode =  [[NSUserDefaults standardUserDefaults] valueForKey:CURRENT_USER_CODE];
    
    if (curentUserCode != nil) {
        
        [OneSignal sendTag:@"usercode" value:curentUserCode];
       // [self.oneSignal sendTag:@"usercode" value:curentUserCode];
    }
    NSSet* tags = [[NSSet alloc] initWithObjects:curentUserCode, nil];
    
    
    NSData* deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    
    
    if (tabDelegate == nil)
    {
        tabDelegate = [[TabBarDelegate alloc] init];
    }
    
    
    rootTabBarController =  [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SPTabBarcontrollerSBIde"]; // UITabBarController* rootController =
    rootTabBarController.delegate = tabDelegate;

    
    [rootTabBarController setSelectedIndex:1];
    self.window.rootViewController = rootTabBarController;
}

- (void)showGalleryScreen
{
    if (tabDelegate == nil)
    {
        tabDelegate = [[TabBarDelegate alloc] init];
    }


    rootTabBarController =  [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SPTabBarcontrollerSBIde"]; // UITabBarController* rootController =
    rootTabBarController.delegate = tabDelegate;
    

    
    [rootTabBarController setSelectedIndex:2];
    self.window.rootViewController = rootTabBarController;
}


- (void)showHomeScreen1
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:PROFILE_NAME_KEY] length])
    {
        if (tabDelegate == nil)
            tabDelegate = [[TabBarDelegate alloc] init];

        
       
        rootTabBarController =  [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SPTabBarcontrollerSBIde"]; // UITabBarController* rootController =
        rootTabBarController.delegate = tabDelegate;
        
        
        
        [rootTabBarController setSelectedIndex:0];
        self.window.rootViewController = rootTabBarController;
    }
}


- (NSString *)documentsDirectory {
    // Get the path to the documents directory and append the databaseName
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    
    return documentsDir;
}

-(void) sendPushToUsersbyTags:(NSArray*) tags message:(NSString*)message
{
    if (tags.count == 0 | tags == nil) {
        return;
    }
    NSString *URLString = [NSString stringWithFormat:@"%@", BASEPUSHURL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer = [self requestSerializer];
    AFJSONRequestSerializer *tempRequestSerializer = [AFJSONRequestSerializer serializer];
    
    [tempRequestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSString* authorizationHeaderValue = [NSString stringWithFormat:@"Basic %@", @"NTJiYWNhNmEtNzFhOC00YTYwLWJmOWItODkxMTM5ZGY5MzFi"];
    [tempRequestSerializer setValue:authorizationHeaderValue forHTTPHeaderField:@"Authorization"];
    
    
    manager.requestSerializer = tempRequestSerializer;
    NSString* stringtags;
    
    stringtags = [NSString stringWithFormat:@"{\"key\": \"usercode\", \"relation\": \"=\", \"value\": \"%@\"}", tags[0]];
    
    if (tags.count > 1) {
        for (int i = 1; i < tags.count; i++) {
            stringtags = [NSString stringWithFormat:@"%@,{\"operator\": \"OR\"}, {\"key\": \"usercode\", \"relation\": \"=\", \"value\": \"%@\"}", stringtags, tags[i]];
        }
    }
    
    NSString *parameters = [NSString stringWithFormat:@"{\"ios_badgeType\":\"Increase\",\"ios_badgeCount\": 1, \"app_id\": \"c0b19b38-d027-4cf4-b0f0-1d6e62d17099\",\"tags\": [%@],\"contents\": {\"en\": \"%@\"}}", stringtags, message];
    
    NSDictionary *parameterDict;
   
    parameterDict = [NSJSONSerialization JSONObjectWithData:[parameters dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
    
    AFHTTPRequestOperation *operation = [manager POST:URLString
                                           parameters:parameterDict
                                              success:^(AFHTTPRequestOperation *operation, id responseObject){
                                                  
                                                  NSData *responseData = [operation responseData];
                                                  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
                                                  NSLog(@"json data %@",json);
                                                  
                                                  
                                              }
                                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                  
                                                  NSLog(@"ERROR %@",[operation responseString]);
                                                  NSLog(@"Error %@", error.description);
                                              }];
    
 
    [operation start];
}
@end
