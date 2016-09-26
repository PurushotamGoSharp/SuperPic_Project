//
//  AddContactsViewController.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 15/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "AddContactsViewController.h"
#import <AddressBook/AddressBook.h>
#import "Person.h"
#import <MessageUI/MessageUI.h>
#import "FriendContactTableViewCell.h"
#import "AppDelegate.h"
#import "DataProvider.h"
#import "Constant.h"
#import "SuperPicAsset.h"
#import "JsonUtil.h"
#import "AllUsersModel.h"

#import "Postman.h"
#import "ParseHandler.h"

//#define SEARCH_USEFBY_FILTER @"http://superpic.azurewebsites.net/Search"

@interface AddContactsViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UISearchDisplayDelegate,MFMessageComposeViewControllerDelegate, FriendContactTableViewCellDelegate, UISearchResultsUpdating, UISearchBarDelegate,postmanDelegate, ParseHandlerDelegate>

@property (nonatomic, strong) NSMutableArray *searchResults; // Filtered search results


@property (weak, nonatomic) IBOutlet UITableView *tableViewOutlet;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendFriendRequestOutlet;
//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *friendContactDataArr;

//@property (nonatomic, strong) NSMutableArray *tableData, *searchedArray;

@property (nonatomic) BOOL isDeviceContactBtnSelected;

@end

#pragma mark -

@implementation AddContactsViewController {
    ABAddressBookRef addressBook;
    NSInteger selectedContactIndex;
    NSMutableArray *selectedContactArr;
    int countOfContactedSelected;
    
    NSMutableArray *remoteUsersContactListArr;
    
    Postman *postman;
    
    AFHTTPRequestOperation *previousOperation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = YES;
    
    [self.searchbar setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchbarbackground"] forState:UIControlStateNormal];
    
    [self searchUserAction:nil];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)searchUserAction:(id)sender {
    self.isDeviceContactBtnSelected = NO;
    
    
//    [self allUsersFromAPI];
    [self.tableViewOutlet reloadData];
}

-(void)allUsersFromAPI
{
    
    DataProvider * dp= [DataProvider new];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *curentUserCode =  [[NSUserDefaults standardUserDefaults] valueForKey:CURRENT_USER_CODE];
    
    NSString *parameter = [NSString stringWithFormat:@"{\"request\":{\"code\":\"%@\",\"profileName\":\"\"}}",curentUserCode];
    
    [dp postJsonContentWithUrl:GET_ALL_USERS_URL parameters:parameter completion:^(BOOL success, id responseJsonObject, id responseObject, NSError *error) {
        if (success) {
            NSDictionary *dataDictionary = (NSDictionary *)responseJsonObject;
            SuperPicAsset *asset = [[SuperPicAsset alloc] initWithAllUsers:dataDictionary];
            remoteUsersContactListArr = [[NSMutableArray alloc] init];
            for (id obj in asset.allUsers)
            {
                AllUsersModel *alluser = [[AllUsersModel alloc] init];
                alluser.code = [JsonUtil stringFromKey:@"code" inDictionary:obj];
                alluser.profileName = [JsonUtil stringFromKey:@"profileName" inDictionary:obj];
                [remoteUsersContactListArr addObject:alluser];
            }
//            if (self.searchController.active)
//            {
//                self.searchResults =[remoteUsersContactListArr copy];
//            
//            }
            [self.tableViewOutlet reloadData];
            
        }else
        {
            
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    }];

    
}





#pragma mark TableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    /*
     If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
     */
    
    
    
    return [self.searchResults count];
    
    
    
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"searchFriendCellIdentifier";
    //        FriendContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    FriendContactTableViewCell *cell = (FriendContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    
    AllUsersModel *alluse = self.searchResults[indexPath.row];
    
    [cell.friendContactNameLabel setText:alluse.profileName];
        //        [cell configureCell:person];
    cell.pointLabel.text = [NSString stringWithFormat:@"%ld", (long)alluse.point];
    [cell setDelegate:self];
    
    
    
    return cell;
}




-(void)searchUsersByFilterFromAPI:(NSString *)searchString
{
    postman = [[Postman alloc] init];
    postman.delegate = self;
    remoteUsersContactListArr = [[NSMutableArray alloc] init];
     NSString *curentUserCode =  [[NSUserDefaults standardUserDefaults] valueForKey:CURRENT_USER_CODE];
    
    NSString *parameter = [NSString stringWithFormat:@"{\"request\":{\"code\":\"%@\",\"profileName\":\"%@\"}}",curentUserCode,searchString];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",BASE_URL,GET_ALL_USERS_URL];
    [postman post:URLString withParameters:parameter];

}

-(void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    [remoteUsersContactListArr removeAllObjects];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:nil];
    
    NSArray *arrUsers = json[@"aaData"][@"Users"];

    for (NSDictionary *aUser in arrUsers)
    {
        AllUsersModel *aModel = [[AllUsersModel alloc] init];
        aModel.code = aUser[@"code"];
        aModel.profileName = aUser[@"profileName"];
        [remoteUsersContactListArr addObject:aModel];
    }
    [self.tableViewOutlet reloadData];
}

-(void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *searchString = [self.searchbar text];
    
    if (searchString.length >0)
    {
        //        [self searchUsersByFilterFromAPI:searchString];
        
        postman = [[Postman alloc] init];
        postman.delegate = self;
        remoteUsersContactListArr = [[NSMutableArray alloc] init];
        NSString *curentUserCode =  [[NSUserDefaults standardUserDefaults] valueForKey:CURRENT_USER_CODE];
        
        NSString *parameter = [NSString stringWithFormat:@"{\"request\":{\"code\":\"%@\",\"profileName\":\"%@\"}}",curentUserCode,searchString];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        if (previousOperation)
        {
            [previousOperation cancel];
        }
        NSString *URLString = [NSString stringWithFormat:@"%@%@",BASE_URL,GET_ALL_USERS_URL];
        
        previousOperation = [postman post:URLString withParameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject)
                             {
                                 NSLog(@"Response came for %li", (long) searchString.length);
                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                 
                                 NSData *responseData = [operation responseData];
                                 
                                 NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
                                 
                                 NSArray *arrUsers = json[@"aaData"][@"Users"];
                                 
                                 for (NSDictionary *aUser in arrUsers)
                                 {
                                     AllUsersModel *aModel = [[AllUsersModel alloc] init];
                                     aModel.code = aUser[@"code"];
                                     aModel.profileName = aUser[@"profileName"];
                                     aModel.point = [aUser[@"point"] integerValue];
                                     [remoteUsersContactListArr addObject:aModel];
                                 }
                                 NSString *scope = nil;
                                 
                                 NSInteger selectedScopeButtonIndex = [self.searchbar selectedScopeButtonIndex];
                                 if (selectedScopeButtonIndex > 0)
                                 {
                                     scope = [remoteUsersContactListArr objectAtIndex:(selectedScopeButtonIndex - 1)];
                                 }
                                 
                                 [self updateFilteredContentForPersonName:searchString type:scope];
                                 
                                 
                                 
                                 [self.tableViewOutlet reloadData];
                                 
                                 
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                 
                             }];
        
    }else
    {
        [remoteUsersContactListArr removeAllObjects];
        [self.searchResults removeAllObjects];
        [self.tableViewOutlet reloadData];
    }
}




#pragma mark - Content Filtering

- (void)updateFilteredContentForPersonName:(NSString *)personName type:(NSString *)typeName
{
    [self.view endEditing:true];
    if ((personName == nil) || [personName length] == 0)
    {
        // If there is no search string and the scope is "All".
        if (typeName == nil) {
            self.searchResults = [remoteUsersContactListArr mutableCopy];
        } else
        {
            // If there is no search string and the scope is chosen.
            NSMutableArray *searchResults = [[NSMutableArray alloc] init];
            /*
             for (Person *obj in dummyContacts) {
             if ([obj.fullName isEqualToString:typeName]) {
             [searchResults addObject:obj];
             }
             }
             */
            
            for (AllUsersModel *tempAlluser in remoteUsersContactListArr) {
                if ([tempAlluser.profileName isEqualToString:typeName]) {
                    [searchResults addObject:tempAlluser];
                }
//                if ([str isEqualToString:typeName]) {
//                    [searchResults addObject:str];
//                }
            }
            self.searchResults = searchResults;

        }
        return;
    }
    
    
    self.searchResults = [ NSMutableArray array];
    

    for (AllUsersModel *tempAlluser in remoteUsersContactListArr)
    {
        NSString *str = tempAlluser.profileName;
        if ((typeName == nil) || [str isEqualToString:typeName]) {
            NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
            NSRange productNameRange = NSMakeRange(0, str.length);
            NSRange foundRange = [str rangeOfString:personName options:searchOptions range:productNameRange];
            if (foundRange.length > 0) {
                [self.searchResults addObject:tempAlluser];
            }
    
        }
    }
}
//
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar;                     // called when cancel button pressed
{
    ////    [self.searchController.searchBar setActive:NO animated:YES];
    //    [self.searchController setActive:NO];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}


-(void)makeARequestTo:(NSString*)toUser name:(NSString*)profilename forIndex:(NSIndexPath*)indexpPath
{
    DataProvider *db = [DataProvider new];
    
    NSString *fromUser =  [[NSUserDefaults standardUserDefaults] valueForKey:CURRENT_USER_CODE];
    
    
    NSString *parameter = [NSString stringWithFormat:@"{\"request\":{\"fromUserCode\":\"%@\", \"ToUserCode\":\"%@\"}}",fromUser,toUser];
    [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    [db postJsonContentWithUrl:FRIEND_REQUESTS_URL parameters:parameter completion:^(BOOL success, id responseJsonObject, id responseObject, NSError *error)
    {
        if (success)
        {
            NSDictionary *dataDict = (NSDictionary*)responseJsonObject;
            SuperPicAsset *asset= [[SuperPicAsset alloc] initWithMakeAFriendsRequest:dataDict];
            
            if (asset.isRequestSucess)
            {
                AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
                
                [appDelegate sendPushToUsersbyTags:@[toUser] message:[NSString stringWithFormat:@"%@ has sent you a friend request",[[NSUserDefaults standardUserDefaults] objectForKey:PROFILE_NAME_KEY]]];
                
                [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
                [self toast:@"Friend Request Sent Successfully"];
                [self.searchResults removeObjectAtIndex:indexpPath.row];
                
                [self.tableViewOutlet deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexpPath, nil] withRowAnimation:UITableViewRowAnimationFade];
                
                
//                [self allUsersFromAPI];
                
            }else
            {
                [MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];
            }
        }
        //[MBProgressHUD hideAllHUDsForView:self.view.window animated:YES];

    }];
    
}


- (void)analyzeResult
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
#pragma mark - Delegate

-(void)sendRequestFriendButtonPressed:(id)cell
{
    if (!self.isDeviceContactBtnSelected)
    {
        FriendContactTableViewCell *tempCell = (FriendContactTableViewCell *)cell;
        NSIndexPath *indexPath = [self.tableViewOutlet indexPathForCell:tempCell];
        
        
        AllUsersModel *allUser;
        
        
        
        allUser =  self.searchResults[indexPath.row];
        
        
        [self makeARequestTo:allUser.code name:allUser.profileName forIndex:indexPath];
        
    }else
    {
        if(![MFMessageComposeViewController canSendText]) {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            return;
        }
        if ([cell isKindOfClass:[FriendContactTableViewCell class]]) {
            FriendContactTableViewCell* tempCell = (FriendContactTableViewCell *)cell;
            NSIndexPath *tempIndexPath = [self.tableViewOutlet indexPathForCell:tempCell];
            Person *person = nil;
            if (self.isDeviceContactBtnSelected) {
                person = [self.friendContactDataArr objectAtIndex:tempIndexPath.row];
            }
            else {
                return;
            }
            NSString *message = @"Hey! Try SuperPic App";
            
            MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
            messageController.messageComposeDelegate = self;
            
            NSMutableArray *toRecipients = [[NSMutableArray alloc]init];
            
            //        NSUInteger objIdx = [person.arrOfPhoneNumbers indexOfObject: person.arrOfPhoneNumbers[0]];
            //        if(objIdx != NSNotFound) {
            if ([person.arrOfPhoneNumbers count] > 0) {
                
                
                [toRecipients addObject:person.arrOfPhoneNumbers[0]]; //@"0933660805"];
                [messageController setRecipients:toRecipients];
                [messageController setBody:message];
                
                // Present message view controller on screen
                [self presentViewController:messageController animated:YES completion:nil];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No recipients to send!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
    }
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:true];
}

@end
