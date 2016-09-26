 //
//  HomeViewController.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 14/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "HomeViewController.h"

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
#import "AddContactsViewController.h"
 #import <SDImageCache.h>
#import "ParseHandler.h"
@interface HomeViewController ()<UITableViewDelegate, FriendsTableViewCellDelegate, RequestTableViewCellDelegate, UITabBarControllerDelegate,UIActionSheetDelegate, ParseHandlerDelegate> {
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

@implementation HomeViewController
{
    NSInteger requesterBadgeCount;
    AppDelegate *appDel, *appDelegate;
    BOOL selectAllFriends;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.friendstableData = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upDateBadgeCount) name:@"RequestNotification" object:nil];

//    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightHandler:)];
//    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
//    [self.view addGestureRecognizer:gestureRecognizer];
}

-(void)viewWillAppear:(BOOL)animated
{

    
    
    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;

    appDelegate.currentIndex = -1;

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
    [(UINavigationController*)[self.tabBarController.viewControllers objectAtIndex:1] popToRootViewControllerAnimated:NO];
    
//    self.tabBarController.delegate = self;
    [self setupView];
    [self.friendsTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upDateBadgeCount) name:@"RequestNotification" object:nil];

    
#warning Please check this one
    appDel = [[UIApplication sharedApplication] delegate];

    
}


- (void)viewWillDisappear:(BOOL)animated {
    
    if (self.friendsTableView.indexPathsForSelectedRows.count > 0)
    {
        [appDel.selectedFriendsIndexArrList removeAllObjects];
        [appDel.selectedFriendsArrList removeAllObjects];
        appDel.selectedFriendsIndexArrList = [self.friendsTableView.indexPathsForSelectedRows mutableCopy];
        
        for (int i = 0; i < self.friendsTableView.indexPathsForSelectedRows.count; ++i)
        {
            NSIndexPath *tempIndexPathForSelectedRow = [self.friendsTableView.indexPathsForSelectedRows objectAtIndex:i];
            if (tempIndexPathForSelectedRow.row > 1)
            {
                FriendListsModel *tempFriendName = [self.friendstableData objectAtIndex:tempIndexPathForSelectedRow.row];
                [appDel.selectedFriendsArrList addObject:tempFriendName];
            }
        }
        

    }
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
    return [self.friendstableData count];
    

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
        cell.pointLabel.text = [NSString stringWithFormat:@"%d", friendsReq.point];
        [cell setDelegate:self];
        cell.selectionStyle  = UITableViewCellEditingStyleNone;
        return cell;
    }
    if (tableView == self.friendsTableView) {
        cellidentifier = @"friendTableCellIdentifier";
         FriendsTableViewCell *cell = (FriendsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellidentifier forIndexPath:indexPath];
        
        NSLog(@"count %lu",(unsigned long)self.friendstableData.count);
        NSString *tempCellTitle;

        
        FriendListsModel *friendList = self.friendstableData[indexPath.row];
        tempCellTitle = friendList.profileName;
        cell.pointLabel.text = [NSString stringWithFormat:@"%d", friendList.point];
        if ([self friendListFor:friendList.code])
        {
            [self selectionOfFriendsByUserFrmIndexPath:indexPath];
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
  
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
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
    
    
}

-(IBAction)clickAddFriends:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    AddContactsViewController *detailVC = (AddContactsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ADDCONTACTVIEWIDENTIFIER"];
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:NO];
    
}

- (IBAction)nextToCamOrStagingAction:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if (self.isCommingFormCamera)
    {
        StagingViewController *detailVC = (StagingViewController *)[storyboard instantiateViewControllerWithIdentifier:@"STAGINGVIEWIDENTIFIER"];
        [self.navigationController pushViewController:detailVC animated:NO];
    }else
    {
        UINavigationController *navController = self.tabBarController.viewControllers[1];
        CameraPickedImageViewController *detailVC = [navController.viewControllers firstObject];
        detailVC.commingFromHome = YES;
        [detailVC.navigationController popToRootViewControllerAnimated:NO];
        [self.tabBarController setSelectedIndex:1];
//        [self.navigationController pushViewController:detailVC animated:NO];
    }

    
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
                 friendList.point = [obj[@"point"] integerValue];
                 [self.friendstableData addObject:friendList];
             }

//             if (appDelegate.frienssListsArrGloble.count == 0)
//             {
//                 appDelegate.frienssListsArrGloble = [self.friendstableData copy];
//             }
             
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
    
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
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
                friendReq.point  = [obj[@"point"] integerValue];
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
                    [self.friendsRequestData removeObjectAtIndex:self.confirmIndexPath.row];
                    [self.friendsRequestTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:self.confirmIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
                    
                    NSInteger badge =   [self.friendsRequestData count];
                    NSLog(@"======= %li",(long)badge);
                    
                    [self getAllFriendRequests];

                    
                    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
                    
                    [appDelegate sendPushToUsersbyTags:@[friendReq.code] message:[NSString stringWithFormat:@"%@ has accepted your friend request",[[NSUserDefaults standardUserDefaults] objectForKey:PROFILE_NAME_KEY]]];
                    
                     
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


- (void)analyzeResult
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

@end
