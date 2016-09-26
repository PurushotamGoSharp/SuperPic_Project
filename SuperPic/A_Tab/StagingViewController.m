//
//  StagingViewController.m
//  SuperPic
//
//  Created by Varghese Simon on 4/15/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "StagingViewController.h"

#import "ShareViewController.h"
#import "AppDelegate.h"
#import "StagingFriendTableViewCell.h"
#import "StagingCollectionViewCell.h"

#import "Constant.h"
#import "DataProvider.h"
#import "SuperPicAsset.h"

#import "HomeViewController.h"
#import "CameraPickedImageViewController.h"

#import "JsonUtil.h"

#import "ParseHandler.h"
#import "TakenImageModel.h"
#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>


@interface StagingViewController () <StagingFriendTableViewCellDelegate, UIGestureRecognizerDelegate> {
    AppDelegate *appDel;
    NSDateFormatter *dateFormatter;

    //    NSArray *stagingFriendstableData;
}

@property (nonatomic, strong) NSMutableArray *stagingFriendstableData, *notToShareImagesArr;//, *sharedImageURLsListsArr;
//@property (strong, nonatomic) IBOutlet UITableView *stagingFriendsTableView;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *stagGalleryCollectionViewOutlet;

//@property (strong, nonatomic) MCPercentageDoughnutView *percentageDoughnut;
//@property (strong, nonatomic) UIView *percentageDoughnutGrap;
@property (retain , nonatomic) MPMoviePlayerController* videoController;
@end

@implementation StagingViewController
{
   

}

@synthesize stagingFriendstableData;
@synthesize stagingGalleryImgsArr;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.shareBtn.layer.cornerRadius = 10.0;
    self.cancelBtn.layer.cornerRadius = 10.0;
    self.cancelBtn.clipsToBounds = YES;
    self.stagGalleryCollectionViewOutlet.allowsMultipleSelection = YES;
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
 
    TakenImageModel *firstTakenImg = [delegate.recentlyCuaghtImagesArr objectAtIndex:0];
    if ([[[firstTakenImg.imagePath pathExtension] uppercaseString] isEqualToString:@"MOV"])
    {
    
        self.videoController = [[MPMoviePlayerController alloc] init];
        self.videoController.controlStyle = MPMovieControlStyleNone;
        self.videoController.scalingMode = MPMovieScalingModeAspectFill;
        self.videoController.repeatMode = MPMovieRepeatModeOne;
        [self.videoController setContentURL:[NSURL fileURLWithPath:firstTakenImg.imagePath]];
        [self.videoController.view setFrame:CGRectMake (0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [self.view addSubview:self.videoController.view];
        
        [self.videoController play];
        self.stagGalleryCollectionViewOutlet.hidden = true;
        
        [self.view bringSubviewToFront:self.shareBtn];
        [self.view bringSubviewToFront:self.cancelBtn];
    }else{
        
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Tabbar:
    appDel = [UIApplication sharedApplication].delegate;
   
    
    self.tabBarController.tabBar.hidden = YES;
    //    [self pressedButton:nil];


    self.navigationController.navigationBar.hidden = true;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setUp];
}

- (void)viewDidDisappear:(BOOL)animated {
    //    self.tabBarController.tabBar.hidden = NO;
    [super viewDidDisappear:animated];
    //    [self.tabBarController setHidesBottomBarWhenPushed:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    //    [self pressedButton:nil];
    
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.hidden = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goback //WE are overriding BACK_BUTTON Action in BASE_VC.
{
    UINavigationController *navController = (UINavigationController *)self.tabBarController.viewControllers[1];
    CameraPickedImageViewController *cameraVC = (CameraPickedImageViewController *)[navController.viewControllers firstObject];
    cameraVC.commingFromHome = YES;//no need of showing home screen again. commingFromHome = YES will prevent Home screen from showing
    [navController popToRootViewControllerAnimated:NO];
    
    [self.tabBarController setSelectedIndex:1];
}


#pragma mark - SetUp View


- (void)setUp
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.stagingGalleryImgsArr = [delegate.recentlyCuaghtImagesArr mutableCopy];
    
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"imgTakenDate" ascending:NO];
    [self.stagingGalleryImgsArr sortUsingDescriptors:@[sortDesc]];

    [self.stagGalleryCollectionViewOutlet reloadData];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isStagingKey"];
    

    
    self.notToShareImagesArr = [[NSMutableArray alloc] initWithCapacity:self.stagingFriendstableData.count];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"shareitentifier"]) {
        NSSet *set1 = [NSSet setWithArray:self.notToShareImagesArr];
        NSMutableSet *set2 = [NSMutableSet setWithArray:self.stagingGalleryImgsArr];
        [set2 minusSet:set1];
        
        NSMutableArray *tempArray = [[set2 allObjects] mutableCopy];

        
        
        ShareViewController *shareVC = [segue destinationViewController];
         shareVC.shareImageArray = tempArray;
        shareVC.hidesBottomBarWhenPushed = YES;
        
        
    
    }
}


- (IBAction)dismissStagingVCAction:(id)sender
{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"SuperPic" message:@"Are you sure you want to lose these pictures?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    alert.tag = 777;
    [alert show];
    
    
    
    
    
}

- (IBAction)shareAndUploadImages:(id)sender
{

    
    if ((self.stagingGalleryImgsArr.count - self.notToShareImagesArr.count) > 0)
    {
        if ((self.stagingGalleryImgsArr.count - self.notToShareImagesArr.count) <= 10)
        {
            
            [self performSegueWithIdentifier:@"shareitentifier" sender:nil];
            
            [self.tabBarController dismissViewControllerAnimated:YES completion:NULL];
            
           
            /*
             * select home
             */

        }else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"SuperPic" message:@"Only 10 images can be shared at a time" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];

            
        }
        
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Hey!" message:@"At least 1 image is required to share!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];

        
    }
}

- (IBAction)selectHomeFriends:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isStagingKey"];
//    [self backToHome];
    
    UINavigationController *navController = [self.tabBarController.viewControllers firstObject];
    [navController popToRootViewControllerAnimated:NO];
    
    HomeViewController *homeVC = (HomeViewController *)[navController.viewControllers firstObject];
    homeVC.isCommingFormCamera = YES;
    [self.tabBarController setSelectedIndex:0];
}

//#pragma mark - Collection Delegates

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.stagingGalleryImgsArr count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StagingCollectionViewCell *cell = (StagingCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SCVCell" forIndexPath:indexPath];
    
//    [cell configureCell:self.stagingGalleryImgsArr[indexPath.row]];
    
    TakenImageModel *takenImg = self.stagingGalleryImgsArr[indexPath.row];
    
    if ([self.notToShareImagesArr containsObject:takenImg])
    {
        [cell.selecteImgView setHidden:NO];
    }else
    {
        [cell.selecteImgView setHidden:YES];
    }
    
    [cell configureCell:takenImg.imagePath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    StagingCollectionViewCell *cell = (StagingCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [self.notToShareImagesArr addObject:self.stagingGalleryImgsArr[indexPath.row]];
    [cell.selecteImgView setHidden:NO];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    StagingCollectionViewCell *cell = (StagingCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [self.notToShareImagesArr removeObject:self.stagingGalleryImgsArr[indexPath.row]];
    [cell.selecteImgView setHidden:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.bounds.size.width / 2.0 - 8, self.view.bounds.size.width / 2.0 - 8);
}


#pragma AlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 777) {
        if (buttonIndex == 0) {
        
            AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
            [delegate.selectedFriendsArrList removeAllObjects];
            [delegate.recentlyCuaghtImagesArr removeAllObjects];
            
            
            
            [delegate showHomeScreen];
        }
        
    }
    
}
@end
