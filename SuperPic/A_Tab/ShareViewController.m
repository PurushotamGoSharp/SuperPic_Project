 //
//  HomeViewController.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 14/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "ShareViewController.h"

#import "CameraPickedImageViewController.h"
#import "StagingViewController.h"
#import "AppDelegate.h"

#import "FriendsTableViewCell.h"
#import "RequestTableViewCell.h"

#import "DataProvider.h"
#import "Constant.h"
#import "JsonUtil.h"
#import "SuperPicAsset.h"
#import "FriendRequestModel.h"
#import "FriendListsModel.h"
#import "SignInViewController.h"

#import "MBProgressHUD.h"
#import "ParseHandler.h"


#import "SPSQLiteManager.h"
#import "FriendListsModel.h"

#import "AFNetworking.h"

#import "TakenImageModel.h"


@interface ShareViewController ()<UITableViewDelegate, FriendsTableViewCellDelegate, RequestTableViewCellDelegate, UITabBarControllerDelegate,UIActionSheetDelegate, ParseHandlerDelegate> {
}


@property (weak, nonatomic) IBOutlet UIView *friendsView;
@property (strong, nonatomic) IBOutlet UITableView *friendsTableView;
@property (weak, nonatomic) IBOutlet UITableView *friendsRequestTableView;
@property (weak, nonatomic) IBOutlet UIView *friendsSelectedBtnVw;
@property (weak, nonatomic) IBOutlet UIView *requestsSelectedBtnVw;
@property (nonatomic, strong) NSMutableArray *friendstableData, *friendsRequestData,*friendsListCode;

@property (weak, nonatomic) IBOutlet UIButton *homeNextBtn;
@property (weak, nonatomic) IBOutlet UIImageView *badgeIcon;

- (void)postFriendRequest:(NSIndexPath *)indexPath;

@end

@implementation ShareViewController
{
    NSInteger requesterBadgeCount;
    AppDelegate *appDel, *appDelegate;
    BOOL selectAllFriends;
    
    NSInteger numberOfImagesLeftToUpload, numberOfURLsLeftToSend;
    
    MBProgressHUD* HUD;
    
     NSDateFormatter *dateFormatter;
    
    NSString *currentUserCode;
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.friendstableData = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upDateBadgeCount) name:@"RequestNotification" object:nil];

    dateFormatter = [[NSDateFormatter alloc]init];
    //    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSSZZZZ";
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    
    currentUserCode = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_USER_CODE];
    
    

    self.tabBarController.tabBar.hidden = YES;
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
//    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//
//    if (appDelegate.frienssListsArrGloble.count == 0)
//    {
//        [self getFriendsListFormAPI];
//    }else
//    {
//        self.friendstableData = [appDelegate.frienssListsArrGloble copy];
//    }

      self.badgeIcon.image = [[UIImage imageNamed:@"badgeIcon"] resizableImageWithCapInsets:(UIEdgeInsetsMake(0, 10, 0, 10))];
    
    [self setupView];
}

-(void)upDateBadgeCount
{
    requesterBadgeCount = [[NSUserDefaults standardUserDefaults]integerForKey:BADGE_COUNT];
    
    NSString *codeStr = [NSString stringWithFormat:@"%li",(long)requesterBadgeCount];
    self.requestNotificationLabel.text = codeStr;
    
    if (requesterBadgeCount>0)
    {
        self.requestNotificationLabel.hidden=NO;
        self.badgeIcon.hidden = NO;
    }else
    {
        self.requestNotificationLabel.hidden=YES;
        self.badgeIcon.hidden = YES;

    }
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
    
//    self.tabBarController.delegate = self;
    [self setupView];
    [self.friendsTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upDateBadgeCount) name:@"RequestNotification" object:nil];

    
#warning Please check this one
    appDel = [[UIApplication sharedApplication] delegate];

    
    [self selectionOfFriendsByUserFrmIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}



- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)setupView {
    
    [self addressBookContactsAction:nil];

    self.homeNextBtn.layer.cornerRadius = 10.0;

    [self upDateBadgeCount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - friend list by user code

- (NSArray *)friendList {
    NSArray *tempFriends = [NSArray array];
    
    return tempFriends;
}

- (FriendListsModel *)friendListFor:(NSString *)code
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code = %@", code];
    NSArray *filteredArray = [appDel.selectedFriendsArrList filteredArrayUsingPredicate:predicate];
    if (filteredArray.count > 0)
    {
        return [filteredArray firstObject];
    }
    return nil;
}

#pragma mark - TableView datasources and delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.friendsRequestTableView) {
        return [_friendsRequestData count];
    }
    NSLog(@"friend all count %lu",(unsigned long)self.friendstableData.count);
    return [self.friendstableData count]+2;
    

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 44;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellidentifier;
    if (tableView == self.friendsRequestTableView)
    {
        cellidentifier = @"reuestTVCIdentifier";
        RequestTableViewCell *cell = (RequestTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
        
        FriendRequestModel *friendsReq = self.friendsRequestData[indexPath.row];
        
        [cell configureCell:friendsReq.profileName];
        [cell setDelegate:self];
        cell.selectionStyle  = UITableViewCellEditingStyleNone;
        return cell;
    }
    if (tableView == self.friendsTableView) {
        cellidentifier = @"friendTableCellIdentifier";
         FriendsTableViewCell *cell = (FriendsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
        
        NSLog(@"count %lu",(unsigned long)self.friendstableData.count);
        NSString *tempCellTitle;

        if (indexPath.row == 0)
        {
            tempCellTitle = @"You";
            [cell setSelected:YES];
        }else if (indexPath.row == 1)
        {
            if (self.friendstableData.count+1 == appDel.selectedFriendsArrList.count && self.friendstableData.count != 0 )
            {
                [self selectionOfFriendsByUserFrmIndexPath:indexPath];
            }
            tempCellTitle = @"Send to All Friends";
        }else
        {
            FriendListsModel *friendList = self.friendstableData[indexPath.row-2];
            tempCellTitle = friendList.profileName;
            
            if ([self friendListFor:friendList.code])
            {
                [self selectionOfFriendsByUserFrmIndexPath:indexPath];
            }
        }
        
//        NSString *tempCellTitle = _friendstableData[indexPath.row];
        [cell configureCell: tempCellTitle];
        [cell setDelegate:self];
        [self changeSelectedBackgroundFriendsTableViewCellViewColor:cell];
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.friendsTableView)
    {
//        FriendListsModel *friendLists =  _friendstableData[indexPath.row-2];
//        NSString *tempCellTitle = friendLists.profileName;
        
        if (indexPath.row == 1)
        {
            if (!selectAllFriends)
            {
                for (int i = 2; i < self.friendstableData.count+2; i++)
                {
                    NSIndexPath *selectToIndex = [NSIndexPath indexPathForRow:i inSection:0];
                    [self selectionOfFriendsByUserFrmIndexPath:selectToIndex];
                }
                selectAllFriends = YES;
            }else
            {
                for (int i = 2; i < self.friendstableData.count+2; i++)
                {
                    NSIndexPath *selectToIndex = [NSIndexPath indexPathForRow:i inSection:0];
                    [self.friendsTableView deselectRowAtIndexPath:selectToIndex animated:YES];
                }
                selectAllFriends = NO;
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.friendsTableView)
    {
        if (indexPath.row == 1)
        {
            for (int i = 2; i < self.friendstableData.count+2; i++)
            {
                NSIndexPath *selectToIndex = [NSIndexPath indexPathForRow:i inSection:0];
                [self.friendsTableView deselectRowAtIndexPath:selectToIndex animated:YES];
            }
            selectAllFriends = NO;
//            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isSendToAllFriends"];
        }
    }
}

#pragma mark - change selected background color cell

- (void)selectionOfFriendsByUserFrmIndexPath:(NSIndexPath *)indexPath {
    [self.friendsTableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
    UITableViewCell *cell = [self.friendsTableView cellForRowAtIndexPath:indexPath];
    [self changeSelectedBackgroundFriendsTableViewCellViewColor:cell];
}

- (void)changeSelectedBackgroundFriendsTableViewCellViewColor:(UITableViewCell *)friendsTableViewCell {
    //    CGRect tempFrame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y + 5, cell.frame.size.width, cell.frame.size.height - 10);
    UIView *myBackView = [[UIView alloc] initWithFrame:friendsTableViewCell.frame];
    myBackView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Selected Contact"]];
    //    myBackView.layer.cornerRadius = 10;
    
    myBackView.layer.borderColor = [UIColor whiteColor].CGColor;
    myBackView.layer.borderWidth = 1.5f;
    
    //    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, 3.0)];
    //    [tempView setBackgroundColor:[UIColor whiteColor]];
    //    [myBackView addSubview:tempView];
    friendsTableViewCell.selectedBackgroundView = myBackView;
    
    //    cell.accessoryView = [[ UIImageView alloc ]
    //                            initWithImage:[UIImage imageNamed:@"Dropmenublue" ]];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
}

- (IBAction)nextToCamOrStagingAction:(id)sender
{
   
    if (self.shareImageArray.count > 0)
    {
        
        if (self.shareImageArray.count == 1) {
            [self imagesToShare:self.shareImageArray];
        }else{
        
            TakenImageModel *takenImg0 =[self.shareImageArray objectAtIndex:0];
            TakenImageModel *takenImg1 =[self.shareImageArray objectAtIndex:1];
            
            NSString *tempImgPath0 = takenImg0.imagePath;
            NSString *tempImgPath1 = takenImg1.imagePath;
            
            if ([tempImgPath0.pathExtension isEqualToString:@"MOV"] || [tempImgPath1.pathExtension isEqualToString:@"MOV"]) {
                [self videoToShare:self.shareImageArray];
            }else
                [self imagesToShare:self.shareImageArray];
        }
        
    }
    
    

    
}

-(void) videoToShareStep2:(NSString *)thumbfileCode
{
    TakenImageModel *takenVideo =[self.shareImageArray objectAtIndex:1];
    
    
    TakenImageModel *takenThumbnail;
    TakenImageModel *takenThumbnail0 =[self.shareImageArray objectAtIndex:0];
    
    TakenImageModel *takenThumbnail1 =[self.shareImageArray objectAtIndex:1];
    
    if ([takenThumbnail0.imagePath.pathExtension isEqualToString:@"MOV"])
    {
        takenVideo = takenThumbnail0;
    }else{
        takenVideo = takenThumbnail1;
    }
        
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
    
    
    NSMutableArray* dateArray = [NSMutableArray new];
    NSMutableArray* pathURLArrays = [NSMutableArray new];
    
    
    NSURL *filePathURL = [NSURL fileURLWithPath:takenVideo.imagePath];
    [pathURLArrays addObject:filePathURL];
    
    NSString *dateString = [dateFormatter stringFromDate:takenVideo.imgTakenDate];
    [dateArray addObject:dateString];
    
    
    NSData *dateJSONData = [NSJSONSerialization dataWithJSONObject:dateArray options:kNilOptions error:nil];
    NSString *dateJSONString = [[NSString alloc] initWithData:dateJSONData encoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = requestSerializer;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"multipart/form-data"];
    
    NSString *userCodeString = [NSString stringWithFormat:@"{\"UserCode\":\"%@\",\"ImagesDateCreated\":%@}", currentUserCode,dateJSONString];
    NSDictionary *parameters = @{@"request": userCodeString};
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@", BASE_URL, VIDEO_UPLOAD_URL];
    AFHTTPRequestOperation *operation = [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                         {
                                             for (NSURL *anURL in pathURLArrays)
                                             {
                                                 
                                                 
                                                 NSData *videoData = [NSData dataWithContentsOfURL:anURL]; // I suppose my
                                                 [formData appendPartWithFileData:videoData name:@"files" fileName:@"filename.mov" mimeType:@"video/quicktime"];
                                                 
                                                 
                                             }
                                             
                                             
                                         }
                                              success:^(AFHTTPRequestOperation *operation, id responseObject)
                                         {
                                             //        numberOfImagesLeftToUpload--;
                                             
                                             NSDictionary *dict = (NSDictionary *)responseObject;
                                             NSDictionary *aaDataDict =      [JsonUtil dictionaryFromKey:@"aaData" inDictionary:dict];
                                             BOOL isSuccess =                [JsonUtil booleanFromKey:@"Success" inDictionary:aaDataDict];
                                             if (isSuccess) {
                                                 [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
                                                 
                                                 NSArray *imageList = aaDataDict[@"imageList"];
                                                 NSMutableArray *tempURLArray = [[NSMutableArray alloc] init];
                                                 for (NSDictionary *imageListDict in imageList)
                                                 {
                                                     SuperPicAsset *asset = [[SuperPicAsset alloc] init];
                                                     asset.successFromCloud = [imageListDict[@"Success"] boolValue];
                                                     if (asset.successFromCloud) {
                                                         
                                                         NSDictionary *tempImageData =   [JsonUtil dictionaryFromKey:@"imageData" inDictionary:imageListDict];
                                                         asset.fileName =            [JsonUtil stringFromKey:@"FileName" inDictionary:tempImageData];
                                                         asset.fileCode =            [JsonUtil stringFromKey:@"Code" inDictionary:tempImageData];
                                                         asset.serverFileURL =       [JsonUtil stringFromKey:@"Url" inDictionary:tempImageData];
                                                         asset.userCode =                 [JsonUtil stringFromKey:@"UserCode" inDictionary:tempImageData];
                                                         asset.imageId =             [JsonUtil numberFromKey:@"ID" inDictionary:tempImageData];
                                                         
                                                         [self storeResponseInTable:asset];
                                                         [tempURLArray addObject:asset.fileCode];
                                                         
                                                     }
                                                     else
                                                     {
                                                         NSLog(@"ERROR IN SERVER SIDE> MOST PROBALY PRIMARY KEY DUPLICATION ERROR");
                                                     }
                                                 }
                                                 [self postUploadedVideo:tempURLArray thumbfileCode:thumbfileCode];
                                                 
                                                 //             NSDictionary *imageListDict = (NSDictionary *)[aaDataDict[@"imageList"] firstObject];
                                             }
                                             numberOfURLsLeftToSend--;
                                             [self hideProgressIfNeccessary];
                                             NSLog(@"Success %@",[operation responseString]);
                                         }
                                              failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                         {
                                             NSLog(@"Error: %@", error);
                                             
                                             numberOfURLsLeftToSend--;
                                             numberOfImagesLeftToUpload--;
                                             
                                             [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
                                             [self toast:@"Aww fiddlesticks! That share didn’t go through. Try it again!"];
                                             //[self hideProgressIfNeccessary]; --- 2015-06-25
                                         }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog( @"wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite );
        HUD.progress = (CGFloat)totalBytesWritten/(CGFloat)totalBytesExpectedToWrite;
    }];
    [operation start];
    

}
- (void)videoToShare:(NSMutableArray *)remainingArr
{
    
    TakenImageModel *takenThumbnail;
    TakenImageModel *takenThumbnail0 =[remainingArr objectAtIndex:0];
    
    TakenImageModel *takenThumbnail1 =[remainingArr objectAtIndex:1];
    
    if ([takenThumbnail0.imagePath.pathExtension isEqualToString:@"MOV"])
    {
        takenThumbnail = takenThumbnail1;
    }else{
        takenThumbnail = takenThumbnail0;
    }
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;

    
    //////////////// thumbnail upload
    NSMutableArray *pathURLArrays = [[NSMutableArray alloc] init];
    NSMutableArray *dateArray = [[NSMutableArray alloc] init];
    
    
    NSURL *filePathURL = [NSURL fileURLWithPath:takenThumbnail.imagePath];
    [pathURLArrays addObject:filePathURL];
    
    NSString *dateString = [dateFormatter stringFromDate:takenThumbnail.imgTakenDate];
    [dateArray addObject:dateString];

    NSData *dateJSONData = [NSJSONSerialization dataWithJSONObject:dateArray options:kNilOptions error:nil];
    NSString *dateJSONString = [[NSString alloc] initWithData:dateJSONData encoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = requestSerializer;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"multipart/form-data"];
    
    NSString *userCodeString = [NSString stringWithFormat:@"{\"UserCode\":\"%@\",\"ImagesDateCreated\":%@}", currentUserCode,dateJSONString];
    NSDictionary *parameters = @{@"request": userCodeString};
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@", BASE_URL, FILE_UPLOAD_URL];
    AFHTTPRequestOperation *operation = [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                         {
                                             for (NSURL *anURL in pathURLArrays)
                                             {
                                                 
                                                 
                                                 [formData appendPartWithFileURL:anURL
                                                                            name:@"files"
                                                                           error:nil];
                                                 
                                             }
                                             
                                             
                                         }
                                              success:^(AFHTTPRequestOperation *operation, id responseObject)
                                         {
                                             //        numberOfImagesLeftToUpload--;
                                             
                                             NSDictionary *dict = (NSDictionary *)responseObject;
                                             NSDictionary *aaDataDict =      [JsonUtil dictionaryFromKey:@"aaData" inDictionary:dict];
                                             BOOL isSuccess =                [JsonUtil booleanFromKey:@"Success" inDictionary:aaDataDict];
                                             
                                             [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
                                             if (isSuccess) {
                                                 
                                                 
                                                 NSArray *imageList = aaDataDict[@"imageList"];
                                                 NSMutableArray *tempURLArray = [[NSMutableArray alloc] init];
                                                 for (NSDictionary *imageListDict in imageList)
                                                 {
                                                     SuperPicAsset *asset = [[SuperPicAsset alloc] init];
                                                     asset.successFromCloud = [imageListDict[@"Success"] boolValue];
                                                     if (asset.successFromCloud) {
                                                         
                                                         NSDictionary *tempImageData =   [JsonUtil dictionaryFromKey:@"imageData" inDictionary:imageListDict];
                                                         asset.fileName =            [JsonUtil stringFromKey:@"FileName" inDictionary:tempImageData];
                                                         asset.fileCode =            [JsonUtil stringFromKey:@"Code" inDictionary:tempImageData];
                                                         asset.serverFileURL =       [JsonUtil stringFromKey:@"Url" inDictionary:tempImageData];
                                                         asset.userCode =                 [JsonUtil stringFromKey:@"UserCode" inDictionary:tempImageData];
                                                         asset.imageId =             [JsonUtil numberFromKey:@"ID" inDictionary:tempImageData];
                                                         
                                                         
                                                         [self videoToShareStep2:asset.fileCode];
                                                     }
                                                     else
                                                     {
                                                         NSLog(@"ERROR IN SERVER SIDE> MOST PROBALY PRIMARY KEY DUPLICATION ERROR");
                                                     }
                                                 }
                                         
                                                 
                                             }
                                         
                                         }
                                              failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                         {
                                             NSLog(@"Error: %@", error);
                                             
                                             [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
                                             [self toast:@"Aww fiddlesticks! That share didn’t go through. Try it again!"];
                                         
                                         }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog( @"wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite );
        HUD.progress = (CGFloat)totalBytesWritten/(CGFloat)totalBytesExpectedToWrite;
    }];
    [operation start];
    

    
    ////////////////
    
}


- (void)imagesToShare:(NSMutableArray *)remainingArr
{
    NSMutableArray *tempImageCodeLists = [[NSMutableArray alloc] init];
    NSMutableArray *imagesToUpload = [[NSMutableArray alloc] init];
    
    numberOfURLsLeftToSend = 0;
    numberOfImagesLeftToUpload = 0;
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
    HUD.progress = 0;
    for (int i = 0; i < [remainingArr count]; i++)
    {
        TakenImageModel *takenImg =[remainingArr objectAtIndex:i];
        
        NSString *tempImgPath = takenImg.imagePath;
        NSString *tempImgName = [self imageName:tempImgPath];
        
        SPSQLiteManager *tempSQLManager = [[SPSQLiteManager alloc] init];
        /*
         * check whether the image is already shared or uploaded to server in db
         */
        BOOL foundImage = [tempSQLManager findImage:tempImgName];
        
        if (foundImage)
        {
            numberOfImagesLeftToUpload--;
            [tempImageCodeLists addObject:tempSQLManager.imageCode];
            NSLog(@"Image found in DB");
        }
        else
        {
            /*
             * upload remaining images
             */
            //            numberOfURLsLeftToSend++;
            //            [self uploadImagePath:takenImg];
            [imagesToUpload addObject:takenImg];
        }
    }
    
    numberOfURLsLeftToSend++;
    [self uploadImagePaths:imagesToUpload];
    numberOfURLsLeftToSend++;
    [self postUploadedImagesURLArr:tempImageCodeLists];
}


// Upload image to server.
- (void)uploadImagePaths:(NSArray *)takenImageModelArray
{
    numberOfImagesLeftToUpload ++;
    
    NSMutableArray *pathURLArrays = [[NSMutableArray alloc] init];
    NSMutableArray *dateArray = [[NSMutableArray alloc] init];
    
    
    for (TakenImageModel *aModel in takenImageModelArray) {
        NSURL *filePathURL = [NSURL fileURLWithPath:aModel.imagePath];
        [pathURLArrays addObject:filePathURL];
        
        NSString *dateString = [dateFormatter stringFromDate:aModel.imgTakenDate];
        [dateArray addObject:dateString];
    }
    NSData *dateJSONData = [NSJSONSerialization dataWithJSONObject:dateArray options:kNilOptions error:nil];
    NSString *dateJSONString = [[NSString alloc] initWithData:dateJSONData encoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = requestSerializer;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"multipart/form-data"];
    
    NSString *userCodeString = [NSString stringWithFormat:@"{\"UserCode\":\"%@\",\"ImagesDateCreated\":%@}", currentUserCode,dateJSONString];
    NSDictionary *parameters = @{@"request": userCodeString};
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@", BASE_URL, FILE_UPLOAD_URL];
    AFHTTPRequestOperation *operation = [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                         {
                                             for (NSURL *anURL in pathURLArrays)
                                             {
                                                
                                                 
                                                 [formData appendPartWithFileURL:anURL
                                                                            name:@"files"
                                                                           error:nil];
                                             
                                             }
                                             
                                             
                                         }
                                              success:^(AFHTTPRequestOperation *operation, id responseObject)
                                         {
                                             //        numberOfImagesLeftToUpload--;
                                             
                                             NSDictionary *dict = (NSDictionary *)responseObject;
                                             NSDictionary *aaDataDict =      [JsonUtil dictionaryFromKey:@"aaData" inDictionary:dict];
                                             BOOL isSuccess =                [JsonUtil booleanFromKey:@"Success" inDictionary:aaDataDict];
                                             if (isSuccess) {
                                                 [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
                                                 
                                                 NSArray *imageList = aaDataDict[@"imageList"];
                                                 NSMutableArray *tempURLArray = [[NSMutableArray alloc] init];
                                                 for (NSDictionary *imageListDict in imageList)
                                                 {
                                                     SuperPicAsset *asset = [[SuperPicAsset alloc] init];
                                                     asset.successFromCloud = [imageListDict[@"Success"] boolValue];
                                                     if (asset.successFromCloud) {
                                                         
                                                         NSDictionary *tempImageData =   [JsonUtil dictionaryFromKey:@"imageData" inDictionary:imageListDict];
                                                         asset.fileName =            [JsonUtil stringFromKey:@"FileName" inDictionary:tempImageData];
                                                         asset.fileCode =            [JsonUtil stringFromKey:@"Code" inDictionary:tempImageData];
                                                         asset.serverFileURL =       [JsonUtil stringFromKey:@"Url" inDictionary:tempImageData];
                                                         asset.userCode =                 [JsonUtil stringFromKey:@"UserCode" inDictionary:tempImageData];
                                                         asset.imageId =             [JsonUtil numberFromKey:@"ID" inDictionary:tempImageData];
                                                         
                                                         [self storeResponseInTable:asset];
                                                         [tempURLArray addObject:asset.fileCode];
                                                         
                                                     }
                                                     else
                                                     {
                                                         NSLog(@"ERROR IN SERVER SIDE> MOST PROBALY PRIMARY KEY DUPLICATION ERROR");
                                                     }
                                                 }
                                                 [self postUploadedImagesURLArr:tempURLArray];
                                                 
                                                 //             NSDictionary *imageListDict = (NSDictionary *)[aaDataDict[@"imageList"] firstObject];
                                             }
                                             numberOfURLsLeftToSend--;
                                             [self hideProgressIfNeccessary];
                                             NSLog(@"Success %@",[operation responseString]);
                                         }
                                              failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                         {
                                             NSLog(@"Error: %@", error);
                                             
                                             numberOfURLsLeftToSend--;
                                             numberOfImagesLeftToUpload--;
                                             
                                             [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
                                             [self toast:@"Aww fiddlesticks! That share didn’t go through. Try it again!"];
                                             //[self hideProgressIfNeccessary]; --- 2015-06-25
                                         }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog( @"wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite );
        HUD.progress = (CGFloat)totalBytesWritten/(CGFloat)totalBytesExpectedToWrite;
    }];
    [operation start];
    
}



//
//- (void)discardSelectedImages {
//    /*
//     * delete images
//     */
//    nDiscardedImages = (int)[self.notToShareImagesArr count];
//    //NSLog(@"discard imagess=%d", [self.notToShareImagesArr count]);
//    for (TakenImageModel *aModel in self.notToShareImagesArr) {
//        
//        [[NSFileManager defaultManager] removeItemAtPath:aModel.imagePath error:nil];
//    }
//    [self.notToShareImagesArr removeAllObjects];
//}


- (void)hideProgressIfNeccessary
{
    NSLog(@"hide progress if neccessary!");
    if (numberOfURLsLeftToSend <= 0)
    {
        [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
        [self toast:@"🍍😎🍍😎🍍😎"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            //////////////////////Image share push notification
            ParseHandler* handler = [[ParseHandler alloc] init];
            handler.delegate = nil; // notToShareImagesArr
            NSLog(@"shared notification count===%d", (int)(self.shareImageArray.count - nDiscardedImages));
            
            [handler shareNotification:appDel.selectedFriendsArrList count:(int)(self.shareImageArray.count - nDiscardedImages)];
            nDiscardedImages = 0;
            
            [appDel showHomeScreen];
            [appDel.selectedFriendsArrList removeAllObjects];
            
            [appDel.recentlyCuaghtImagesArr removeAllObjects];
        });
    }
}






- (void)uploadImagePath:(TakenImageModel *)model
{
    numberOfImagesLeftToUpload ++;
    
    NSURL *filePathURL = [NSURL fileURLWithPath:model.imagePath];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = requestSerializer;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"multipart/form-data"];
    
    //    NSString  {"UserCode":"0ALH4IPM1LKK","ImagesDateCreated":["2015-05-07 12:05:11.84"]}
    
    //    NSDate *curentDate = [NSDate date];
    
    
    
    NSString *userCodeString = [NSString stringWithFormat:@"{\"UserCode\":\"%@\",\"ImagesDateCreated\":[\"%@\"]}", currentUserCode,[dateFormatter stringFromDate:model.imgTakenDate]];
    NSDictionary *parameters = @{@"request": userCodeString};
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@", BASE_URL, FILE_UPLOAD_URL];
    [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
     {
         [formData appendPartWithFileURL:filePathURL
                                    name:@"files"
                                   error:nil];
     } success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //        numberOfImagesLeftToUpload--;
         
         NSDictionary *dataDictionary = (NSDictionary *)responseObject;
         SuperPicAsset *asset = [[SuperPicAsset alloc] initWithFileUploadDictionary:dataDictionary];
         
         if (asset.successFromCloud)
         {
             [self storeResponseInTable:asset];
         }
         
         numberOfImagesLeftToUpload--;
         numberOfURLsLeftToSend--;
         [self hideProgressIfNeccessary];
         
         
         
         NSLog(@"Success %@",[operation responseString]);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
         
         numberOfURLsLeftToSend--;
         numberOfImagesLeftToUpload--;
         [self hideProgressIfNeccessary];
         
     }];
}


- (NSString *)imageName:(NSString *)imagePath {
    NSString *tempImgName = [[imagePath componentsSeparatedByString:@"/"] lastObject];
    return tempImgName;
}


- (void)postUploadedImagesURLArr:(NSArray *)imgsURLArr {
    /*
     * post link to server if shared or uploaded
     */
    //    NSString *currentUserCode = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_USER_CODE];
    
    NSLog(@"Post URLS has called");
    if ([imgsURLArr count] > 0)
    {
        
        [appDel.selectedFriendsIndexArrList removeAllObjects];
        [appDel.selectedFriendsArrList removeAllObjects];
        appDel.selectedFriendsIndexArrList = [self.friendsTableView.indexPathsForSelectedRows mutableCopy];
        
        NSMutableArray *filteredArray = [NSMutableArray array];
        
        appDel.selectedFriendsArrList = [NSMutableArray array];
        
        
        for (int i = 0; i < self.friendsTableView.indexPathsForSelectedRows.count; ++i)
        {
            NSIndexPath *tempIndexPathForSelectedRow = [self.friendsTableView.indexPathsForSelectedRows objectAtIndex:i];
            if (tempIndexPathForSelectedRow.row > 1)
            {
                FriendListsModel *tempFriendName = [self.friendstableData objectAtIndex:tempIndexPathForSelectedRow.row-2];
                
                [filteredArray addObject:tempFriendName.code];
                
                
                [appDel.selectedFriendsArrList addObject:tempFriendName];
       
          
                
            }
        }
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Share" properties:@{@"username" : [[NSUserDefaults standardUserDefaults] objectForKey:PROFILE_NAME_KEY]}];
        
        [appDel sendPushToUsersbyTags:filteredArray message:[NSString stringWithFormat:@"%@ has shared %d photos with you",[[NSUserDefaults standardUserDefaults] objectForKey:PROFILE_NAME_KEY],imgsURLArr.count]];
        
        NSData *JSONValueData = [NSJSONSerialization dataWithJSONObject:@{@"FriendList":filteredArray, @"ImageList":imgsURLArr}
                                                                options:kNilOptions
                                                                  error:nil];
        NSString *JSONValueString =[[NSString alloc] initWithData:JSONValueData
                                                         encoding:NSUTF8StringEncoding];
        
        NSDictionary *jsonDict = @{@"request":@{@"UserCode":currentUserCode, @"JSON":JSONValueString}};
        
        NSData *parameterData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                                options:kNilOptions
                                                                  error:nil];
        NSString *parameterString = [[NSString alloc] initWithData:parameterData
                                                          encoding:NSUTF8StringEncoding];
        
        DataProvider *tempDataProvider = [DataProvider new];
        [tempDataProvider postJsonContentWithUrl:IMAGE_SHARE_URL
                                      parameters:parameterString
                                      completion:^(BOOL success, id responseJsonObject, id responseObject, NSError *error) {
                                          
                                          numberOfURLsLeftToSend--;
                                          
                                          if (success)
                                          {
                                              NSDictionary *dataDictionary = (NSDictionary *)responseJsonObject;
                                              NSLog(@"%@", dataDictionary);
                                          }
                                          else
                                          {
                                              NSLog(@"****Err: %@", error.description);
                                          }
                                          
                                          if (numberOfURLsLeftToSend <= 0)
                                          {
                                              [self toast:@"That didn't work.😢Try sharing again!"];
                                          }
                                          [self hideProgressIfNeccessary];
                                      }];
        
    }else
    {
        numberOfURLsLeftToSend--;
        [self hideProgressIfNeccessary];
    }
    
    // {"request":{"UserCode":"LGPEAQXNLEZI","JSON":"{'FriendList':['1212','12112'],'ImageUrlList':['Q1RRT1U6R83P','2323232']}"}}
}

- (void)postUploadedVideo:(NSArray *)imgsURLArr thumbfileCode:(NSString*)thumbfileCode{
    /*
     * post link to server if shared or uploaded
     */
    //    NSString *currentUserCode = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_USER_CODE];
    
    NSLog(@"Post URLS has called");
    if ([imgsURLArr count] > 0)
    {
        
        [appDel.selectedFriendsIndexArrList removeAllObjects];
        [appDel.selectedFriendsArrList removeAllObjects];
        appDel.selectedFriendsIndexArrList = [self.friendsTableView.indexPathsForSelectedRows mutableCopy];
        
        NSMutableArray *filteredArray = [NSMutableArray array];
        
        appDel.selectedFriendsArrList = [NSMutableArray array];
        
        
        for (int i = 0; i < self.friendsTableView.indexPathsForSelectedRows.count; ++i)
        {
            NSIndexPath *tempIndexPathForSelectedRow = [self.friendsTableView.indexPathsForSelectedRows objectAtIndex:i];
            if (tempIndexPathForSelectedRow.row > 1)
            {
                FriendListsModel *tempFriendName = [self.friendstableData objectAtIndex:tempIndexPathForSelectedRow.row-2];
                
                [filteredArray addObject:tempFriendName.code];
                
                
                [appDel.selectedFriendsArrList addObject:tempFriendName];
                
                
                
            }
        }
        
        [appDel sendPushToUsersbyTags:filteredArray message:[NSString stringWithFormat:@"%@ has shared a video with you",[[NSUserDefaults standardUserDefaults] objectForKey:PROFILE_NAME_KEY]]];
        
        NSData *JSONValueData = [NSJSONSerialization dataWithJSONObject:@{@"FriendList":filteredArray, @"VideoCode":imgsURLArr[0], @"ImageCode":thumbfileCode}
                                                                options:kNilOptions
                                                                  error:nil];
        NSString *JSONValueString =[[NSString alloc] initWithData:JSONValueData
                                                         encoding:NSUTF8StringEncoding];
        
        NSDictionary *jsonDict = @{@"request":@{@"UserCode":currentUserCode, @"JSON":JSONValueString}};
        
        NSData *parameterData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                                options:kNilOptions
                                                                  error:nil];
        NSString *parameterString = [[NSString alloc] initWithData:parameterData
                                                          encoding:NSUTF8StringEncoding];
        
        DataProvider *tempDataProvider = [DataProvider new];
        [tempDataProvider postJsonContentWithUrl:VIDEO_SHARE_URL
                                      parameters:parameterString
                                      completion:^(BOOL success, id responseJsonObject, id responseObject, NSError *error) {
                                          
                                          numberOfURLsLeftToSend--;
                                          
                                          if (success)
                                          {
                                              NSDictionary *dataDictionary = (NSDictionary *)responseJsonObject;
                                              NSLog(@"%@", dataDictionary);
                                          }
                                          else
                                          {
                                              NSLog(@"****Err: %@", error.description);
                                          }
                                          
                                          if (numberOfURLsLeftToSend <= 0)
                                          {
                                              [self toast:@"That was a rad share! Do it again!"];
                                          }
                                          [self hideProgressIfNeccessary];
                                      }];
        
    }else
    {
        numberOfURLsLeftToSend--;
        [self hideProgressIfNeccessary];
    }
    
    // {"request":{"UserCode":"LGPEAQXNLEZI","JSON":"{'FriendList':['1212','12112'],'ImageUrlList':['Q1RRT1U6R83P','2323232']}"}}
}


- (IBAction)addressBookContactsAction:(id)sender {
    [self.friendsView setHidden:NO];
    [self.friendsRequestTableView setHidden:YES];
    [self.friendsSelectedBtnVw setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SelectedTab"]]];
    [self.requestsSelectedBtnVw setBackgroundColor:[UIColor clearColor]];
    //    isFriendsRequestTableData = NO;
    [self getFriendsListFormAPI];
    [self getAllFriendRequests];

}

-(void)getFriendsListFormAPI
{
    NSString *code =  [[NSUserDefaults standardUserDefaults] valueForKey:CURRENT_USER_CODE];
    
    NSString *URL = [NSString stringWithFormat:@"%@%@",FRIEND_LIST_URL,code];
    DataProvider * dp= [DataProvider new];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [dp getJsonContentWithUrl:URL completion:^(BOOL success, id responseJsonObject, id responseObject, NSError *error)
     {
         if (success) {
             NSDictionary *dataDictionary = (NSDictionary *)responseJsonObject;
             SuperPicAsset *asset = [[SuperPicAsset alloc] initWithFriendsList:dataDictionary];
             
             [self.friendstableData removeAllObjects];
             for (id obj in asset.friendList)
             {
                 FriendListsModel *friendList = [[FriendListsModel alloc] init];
                 
                 friendList.code = [JsonUtil stringFromKey:@"code" inDictionary:obj];
                 friendList.profileName = [JsonUtil stringFromKey:@"profilename" inDictionary:obj];
                 friendList.email = [JsonUtil stringFromKey:@"email" inDictionary:obj];
                 [self.friendstableData addObject:friendList];
             }


             
             
             [self.friendsTableView reloadData];
         }else
         {
             
         }
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
     }];
}



- (IBAction)newRequestsAction:(id)sender {
    [self.friendsView setHidden:YES];
    [self.friendsRequestTableView setHidden:NO];
    [self.friendsSelectedBtnVw setBackgroundColor:[UIColor clearColor]];//SelectedTab
    [self.requestsSelectedBtnVw setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"SelectedTab"]]];
    //    isFriendsRequestTableData = YES;
    [self getAllFriendRequests];
}

-(void)getAllFriendRequests
{
    DataProvider *dp = [DataProvider new];
    
    NSString *code =  [[NSUserDefaults standardUserDefaults] valueForKey:CURRENT_USER_CODE];
    NSString *URL = [NSString stringWithFormat:@"%@%@",GET_ALL_FRIENDS_REQUEST_URL,code];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [dp getJsonContentWithUrl:URL completion:^(BOOL success, id responseJsonObject, id responseObject, NSError *error) {
        if (success)
        {
            NSDictionary *dataDict = (NSDictionary *)responseJsonObject;
            SuperPicAsset *asset = [[SuperPicAsset alloc] initWithAllFriendsRequests:dataDict];
            self.friendsRequestData = [[NSMutableArray alloc] init];
            
            for (id obj  in asset.allFriendRequests)
            {
                FriendRequestModel *friendReq = [[FriendRequestModel alloc] init];
                friendReq .code = [JsonUtil stringFromKey:@"requestCode" inDictionary:obj];
                friendReq.profileName = [JsonUtil stringFromKey:@"profileName" inDictionary:obj];
                friendReq.email = [JsonUtil stringFromKey:@"email" inDictionary:obj];
                [self.friendsRequestData addObject:friendReq];
            }
            [self.friendsRequestTableView reloadData];
            
            [[NSUserDefaults standardUserDefaults]setInteger:[self.friendsRequestData count] forKey:BADGE_COUNT];
            [[NSUserDefaults standardUserDefaults] synchronize];
            requesterBadgeCount = [[NSUserDefaults standardUserDefaults]integerForKey:BADGE_COUNT];
            
            NSString *codeStr = [NSString stringWithFormat:@"%li",(long)requesterBadgeCount];
            
            self.requestNotificationLabel.text = codeStr;
            
            if (requesterBadgeCount>0)
            {
                self.requestNotificationLabel.hidden=NO;
                self.badgeIcon.hidden = NO;

            }else
            {
                self.requestNotificationLabel.hidden=YES;
                self.badgeIcon.hidden = YES;

                
            }
            
            
        }else
        {
            
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    }];
}


#pragma mark - Friends TableView delegates

- (void)unfriendButtonPressed:(id)cell {
    if ([self indexPathForFriendsTableViewCell:cell] != nil) {
        
    }
}

- (NSIndexPath *)indexPathForFriendsTableViewCell:(id)cell {
    if ([cell isKindOfClass:[RequestTableViewCell class]]) {
        RequestTableViewCell* tempCell = (RequestTableViewCell *)cell;
        return [self.friendsRequestTableView indexPathForCell:tempCell];
    }
    return nil;
}

#pragma mark - Request Tableview delegates

- (void)confirmFriendRequestButtonPressed:(id)cell
{
    if ([self indexPathForRequestTableViewCell:cell] != nil)
    {
        NSIndexPath *indexPath = [self indexPathForFriendsTableViewCell:cell];

        FriendRequestModel *friendReq = self.friendsRequestData[indexPath.row];

        NSString *code = friendReq.code;

        NSString *URL = [NSString stringWithFormat:@"%@%@",ACCEPT_FRIEND_REQUEST_URL,code];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        DataProvider *db = [DataProvider new];
        [db postJsonContentWithUrl:URL parameters:@"" completion:^(BOOL success, id responseJsonObject, id responseObject, NSError *error) {
            if (success)
            {
                NSDictionary *dataDict = (NSDictionary *)responseJsonObject;
                
                SuperPicAsset *asset = [[SuperPicAsset alloc] initWithAcceptFriendRequest:dataDict];
                if (asset.isConform)
                {
                    self.confirmIndexPath = indexPath;
                    
                    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
                    
                    [appDelegate sendPushToUsersbyTags:@[friendReq.code] message:[NSString stringWithFormat:@"%@ has accepted your friend request",friendReq.profileName]];


                }
                else
                {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                }
            }
            else
            {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
            //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        }];
    }
}

- (void)ignoreFriendRequestButtonPressed:(id)cell
{
    if ([self indexPathForRequestTableViewCell:cell] != nil)
    {
        NSIndexPath *indexPath = [self indexPathForFriendsTableViewCell:cell];
        
        FriendRequestModel *friendReq = self.friendsRequestData[indexPath.row];
        
        NSString *code = friendReq.code;
        
        NSString *URL = [NSString stringWithFormat:@"%@%@",REJECT_FRIEND_REQUEST_URL,code];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        DataProvider *db = [DataProvider new];
        [db postJsonContentWithUrl:URL parameters:@"" completion:^(BOOL success, id responseJsonObject, id responseObject, NSError *error) {
            if (success)
            {
                NSDictionary *dataDict = (NSDictionary *)responseJsonObject;
                
                SuperPicAsset *asset = [[SuperPicAsset alloc] initWithIgnoreFriendRequest:dataDict];
                if (asset.isIgnore)
                {
                    [self.friendsRequestData removeObjectAtIndex:indexPath.row];
                    [self.friendsRequestTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
                    
                  NSInteger badge =   [self.friendsRequestData count];
                    NSLog(@"======= %li",(long)badge);
                    
                    [self getAllFriendRequests];

                }
            }
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        }];

    }
}



- (void)ignoreAPI:(NSString*)forCode
{
    
}

- (NSIndexPath *)indexPathForRequestTableViewCell:(id)cell
{
    if ([cell isKindOfClass:[RequestTableViewCell class]]) {
        RequestTableViewCell* tempCell = (RequestTableViewCell *)cell;
        return [self.friendsRequestTableView indexPathForCell:tempCell];
    }
    return nil;
}

- (void)postFriendRequest:(NSIndexPath *)indexPath
{
    __typeof(self) __weak weakSelf = self;
    
    DataProvider *dP = [DataProvider new];
    [dP postJsonContentWithUrl:ACCEPT_FRIEND_REQUEST_URL parameters:nil completion:^(BOOL success, id responseJsonObject, id responseObject, NSError *error) {
        if (success) {
            NSDictionary *dataDictionary = (NSDictionary *)responseJsonObject;
            NSDictionary *aaDataDict =      [JsonUtil dictionaryFromKey:@"aaData" inDictionary:dataDictionary];
            BOOL isSuccess = [JsonUtil booleanFromKey:@"Success" inDictionary:aaDataDict];
            if (isSuccess) {
                [weakSelf.friendsRequestData removeObjectAtIndex:indexPath.row];
                
                // delete the row from the data source
                [weakSelf.friendsRequestTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
            }
            else {
                [weakSelf toast:[JsonUtil stringFromKey:@"Message" inDictionary:aaDataDict]];
            }
        }
        else {
            [weakSelf toast:responseJsonObject];
        }
    }];
}


- (void)storeResponseInTable:(SuperPicAsset *)asset
{
    SPSQLiteManager *tempSQLManager = [[SPSQLiteManager alloc] init];
    tempSQLManager.imageName = asset.fileName;
    tempSQLManager.imageURL =  asset.serverFileURL;
    tempSQLManager.imageCode =  asset.fileCode;
    
    //#warning make image status (if available in both then 1 else 0)
    tempSQLManager.status =    1;
    
    tempSQLManager.userName = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:PROFILE_NAME_KEY];
    [tempSQLManager addImageInfoRecord];
    

    
}




#pragma mark - parsehandler delegate
#pragma mark - ParseHandlerDelegate
- (void)completedParseReuest:(ParseResponseCode)response error:(NSString*)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    switch (response) {
        case ParseResponseSuccess:
            //
        {
            if ([ParseHandler sharedInstance].parseRequest == ParseRequestFriendAccept) {
                [self.friendsRequestData removeObjectAtIndex:self.confirmIndexPath.row];
                [self.friendsRequestTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:self.confirmIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
                
                NSInteger badge =   [self.friendsRequestData count];
                NSLog(@"======= %li",(long)badge);
                
                [self getAllFriendRequests];
            }
        }
            break;
        case ParseResponseSignUpError:
            break;
        case ParseResponseUserAlreadyLoggedIn:
        default:
            break;
    }
}

- (void)analyzeResult
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

@end
