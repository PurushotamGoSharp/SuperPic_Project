//
//  GalleryViewController.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 14/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "GalleryViewController.h"
#import "UIImageView+AFNetworking.h"
#import "GalleryCell.h"

#import "AddContactsViewController.h"
#import "Postman.h"
#import "Constant.h"
#import  "GallerysModel.h"
#import  "GalleryJSONModel.h"
#import "CameraPickedImageViewController.h"
#import <SDImageCache.h>
#import <sqlite3.h>
#import "DBManager.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "UIImage+fixOrientation.h"
#import "MediaAsset.h"
#import "CarouselViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#define GET_SHARED_IMAGE_BY_ME [NSString stringWithFormat:@"%@%@",BASE_URL, @"image/user/"]

#define GET_SHARED_IMAGE_BY_OTHERS  [NSString stringWithFormat:@"%@%@",BASE_URL, @"imageshare/user/"]

@interface GalleryViewController ()<UICollectionViewDataSource,UICollectionViewDelegate, GalleryCellDelegate, postmanDelegate, UIGestureRecognizerDelegate, MUKMediaThumbnailsViewControllerDelegate>
{
    
    Postman *postman;
    NSString *currentUserCode;
    int nCurrentPage;
    NSString* getAllImagesURLString;
    NSDateFormatter *dateFormatter;
    
}
@property (nonatomic) NSOperationQueue *networkQueue;
@end

@implementation GalleryViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.title = @"";
        self.delegate = self;
        _networkQueue = [[NSOperationQueue alloc] init];
        _networkQueue.maxConcurrentOperationCount = 3;
        
        

#if !DEBUG_SIMULATE_ASSETS_DOWNLOADING
        _mediaAssets = [NSMutableArray array];
#endif
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //navigation custom
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"NavBar"] resizableImageWithCapInsets:(UIEdgeInsetsMake(0, 0, 40, 115))] forBarMetrics:UIBarMetricsDefault];
    
    //    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:.13 green:.31 blue:.46 alpha:1]];
    
    UIButton *logOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logOutBtn setBackgroundColor:[UIColor clearColor]];
    [logOutBtn addTarget:self action:@selector(logOut1) forControlEvents:UIControlEventTouchUpInside];
    logOutBtn.frame = CGRectMake(0, 0, 100, 30);
    UIBarButtonItem *logOut = [[UIBarButtonItem alloc] initWithCustomView:logOutBtn] ;
    self.navigationController.navigationItem.rightBarButtonItem = logOut;
    
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.translucent = YES;
    //
    nCurrentPage= 0;
    currentUserCode = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_USER_CODE];
    
    postman = [[Postman alloc] init];
    postman.delegate = self;
    
    dateFormatter = [[NSDateFormatter alloc]init];
    
  
    
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";

    /////////////////
    AppDelegate * appdelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    appdelegate.currentIndex = -1;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.collectionView.bounds];
    self.collectionView.backgroundView = backgroundView;
    
    UIView *wrapperView = [[UIView alloc] initWithFrame:self.collectionView.backgroundView.bounds];
    wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    [wrapperView addSubview:spinner];
    [self.collectionView.backgroundView addSubview:wrapperView];
    
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:spinner attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:spinner.superview attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:spinner attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:spinner.superview attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    wrapperView.translatesAutoresizingMaskIntoConstraints = NO;
    [wrapperView addConstraints:@[centerXConstraint, centerYConstraint]];
    
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.mediaAssets = [NSMutableArray array];
        [self reloadData];
        
        [self.collectionView.backgroundView removeFromSuperview];
        self.collectionView.backgroundView = nil;
    });


    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    
    [self reloadDataFromCoredata];
    
    AppDelegate * appdelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    
    if (appdelegate.currentIndex == -1) {
        
        nCurrentPage = 0;
        getAllImagesURLString = [NSString stringWithFormat:@"%@%@/%d", GET_SHARED_IMAGE_BY_OTHERS, currentUserCode,nCurrentPage];
        
        [postman get:getAllImagesURLString];

    }else{
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:appdelegate.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            
        
    }
    
    
    

    [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"GalleryBadgeCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GalleryNotification" object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [(UINavigationController*)[self.tabBarController.viewControllers objectAtIndex:1] popToRootViewControllerAnimated:NO];
    


}

//////

-(void) logOut1

{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Logout", nil];
    [actionSheet showInView:self.view];
    
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        UIAlertView *logOutAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        
        [logOutAlert show];
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SIGNED_UP_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PROFILE_NAME_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:CURRENT_USER_PASSWORD_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [appDel.selectedFriendsArrList removeAllObjects];
        [appDel.recentlyCuaghtImagesArr removeAllObjects];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:CURRENT_USER_CODE];
        
        //t--[UAirship push].tags = @[];
        //t--[[UAirship push] updateRegistration];
        [appDel showLoganScreen];
        
        //        if ([PFUser currentUser]) {
        //            [PFUser logOut];
        //        }
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (bEnd) {
        return;
    }
    
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if (bottomEdge >= scrollView.contentSize.height) {
    
        nCurrentPage++;
        getAllImagesURLString = [NSString stringWithFormat:@"%@%@/%d", GET_SHARED_IMAGE_BY_OTHERS, currentUserCode,nCurrentPage];
        [postman get:getAllImagesURLString];
    }
    

}

- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
    if ([urlString isEqualToString:getAllImagesURLString])
    {
        NSMutableArray *galleryAPIimages = [[NSMutableArray alloc] init];

        NSDictionary *JSONDict = [NSJSONSerialization JSONObjectWithData:response
                                                                 options:kNilOptions
                                                                   error:nil];
        if (JSONDict[@"aaData"][@"Success"])
        {
            
            NSArray *urlsArray = JSONDict[@"aaData"][@"ImageData"];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS zzz";

            int i = 0;
            for (NSDictionary *anImageURL in urlsArray)
            {
                GallerysModel* model = [GallerysModel fromDictionary:anImageURL];
//                model.id = [NSNumber numberWithInt:nPreviousCount + i];
                
//                NSLog(@"Model ID = %@", model.id);
                
                i++;
                [model save];
               
            }
            
            [self reloadDataFromCoredata];
            
        }

        

        
    }else
    {
        
    }
}

-(void) reloadDataFromCoredata
{
    [self.mediaAssets removeAllObjects];
    
    NSArray* results = [GallerysModel all:@"datecreated"];
    
    int abPage =  results.count/15;
    
    if (abPage >= 5 && nCurrentPage < 3) {
        nCurrentPage = abPage;
    }
    for (GallerysModel *anImageURL in results)
    {
        NSString *dateString = [NSString stringWithFormat:@"%@ UTC", anImageURL.datecreated];
        
        
        if ([anImageURL.filetype isEqualToString:@"photo"]) {
            MediaAsset *asset = [[MediaAsset alloc] initWithKind:MUKMediaKindImage];
            asset.URL = [NSURL URLWithString:anImageURL.url];
            asset.thumbnailURL = [NSURL URLWithString:anImageURL.thumbnailurl];
            asset.caption = anImageURL.ownername;
            asset.code = anImageURL.code;
            asset.ownercode = anImageURL.ownercode;
            
            asset.date = dateString;
            [self.mediaAssets addObject:asset];
        }else{
            MediaAsset *remoteVideoAsset = [[MediaAsset alloc] initWithKind:MUKMediaKindVideo];
            remoteVideoAsset.URL = [NSURL URLWithString:anImageURL.url];
            remoteVideoAsset.thumbnailURL = [NSURL URLWithString:anImageURL.thumbnailurl];
            remoteVideoAsset.code = anImageURL.code;
            remoteVideoAsset.ownercode = anImageURL.ownercode;
            remoteVideoAsset.caption = anImageURL.ownername;
            remoteVideoAsset.date = dateString;
            [self.mediaAssets addObject:remoteVideoAsset];
            
        }
        NSString *curentUserCode =  [[NSUserDefaults standardUserDefaults] valueForKey:CURRENT_USER_CODE];
        
        if (![anImageURL.ownercode isEqualToString:curentUserCode] && anImageURL.read == 0) {
            
            AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            
            NSMutableArray *filteredArray = [NSMutableArray array];
            [filteredArray addObject:anImageURL.ownercode];
            
            [appDelegate sendPushToUsersbyTags:filteredArray message:[NSString stringWithFormat:@"%@ send \\uD83D\\uDE01",[[NSUserDefaults standardUserDefaults] objectForKey:PROFILE_NAME_KEY]]];
            
            
        }
        bEnd =  false;
        
    }
    
    
    [self reloadData];
}
- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    [MBProgressHUD hideAllHUDsForView:self.tabBarController.view animated:YES];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Network error" message:@"Please check your network connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
}

////

#pragma mark - <MUKMediaThumbnailsViewControllerDelegate>

- (NSInteger)numberOfItemsInThumbnailsViewController:(MUKMediaThumbnailsViewController *)viewController
{
    return [self.mediaAssets count];
}

- (void)thumbnailsViewController:(MUKMediaThumbnailsViewController *)viewController loadImageForItemAtIndex:(NSInteger)idx completionHandler:(void (^)(UIImage *))completionHandler
{
    MediaAsset *asset = self.mediaAssets[idx];
    
    if (!asset.thumbnailURL) {
        completionHandler(nil);
        return;
    }
    
    if (asset.kind == MUKMediaKindImage) {
        NSURLRequest *request = [NSURLRequest requestWithURL:asset.thumbnailURL];
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.userInfo = @{ @"index" : @(idx) };
        
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            UIImage *image = nil;
            
            if ([responseObject length]) {
                image = [UIImage imageWithData:responseObject];
            }
            
            completionHandler(image);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completionHandler(nil);
        }];
        
        [self.networkQueue addOperation:op];
    }else if (asset.kind == MUKMediaKindVideo)
    {
        UIImage* image =  [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:asset.code];
        if (image) {
            completionHandler(image);
        }else
        {
            
          
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               
                
                
                
                NSURL *url = asset.thumbnailURL;
                
                //    NSURL *url = [NSURL URLWithString:@"http://media.w3.org/2010/05/sintel/trailer.mp4"];
                AVURLAsset *asset1=[AVURLAsset assetWithURL:url];
                AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
                imageGenerator.appliesPreferredTrackTransform = TRUE;
                imageGenerator.maximumSize = CGSizeMake(80, 80);
                
                CMTime thumbTime = [asset1 duration];
                thumbTime.value = 0;
                
                AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
                    if (result != AVAssetImageGeneratorSucceeded) {
                        NSLog(@"Fail generating image = %@", url);
                        completionHandler(nil);
                    }
                    
                    UIImage* resultUIImage = [UIImage imageWithCGImage:im];
                    
                    CGImageRelease(im);
                    
                    //resize image (use some code for resize)
                    //<>
                    //TODO: call some method to resize image
//                    UIImage* resizedImage =  [resultUIImage fixOrientation];
                    //<>
                    
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[SDImageCache sharedImageCache] storeImage:resultUIImage forKey:asset.code];
                        completionHandler(resultUIImage);
                    });
                };
                
                [imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
                
                
                
            });
            
          
        }
    }
    
}

- (void)thumbnailsViewController:(MUKMediaThumbnailsViewController *)viewController cancelLoadingForImageAtIndex:(NSInteger)idx
{
    for (AFHTTPRequestOperation *op in self.networkQueue.operations) {
        if ([op.userInfo[@"index"] integerValue] == idx) {
            [op cancel];
            break;
        }
    }
}

- (MUKMediaAttributes *)thumbnailsViewController:(MUKMediaThumbnailsViewController *)viewController attributesForItemAtIndex:(NSInteger)idx
{
    MediaAsset *asset = self.mediaAssets[idx];
    MUKMediaAttributes *attributes = [[MUKMediaAttributes alloc] initWithKind:asset.kind];
    
    if (asset.duration > 0.0) {
        [attributes setCaptionWithTimeInterval:asset.duration];
    }
    
    return attributes;
}

- (MUKMediaCarouselViewController *)thumbnailsViewController:(MUKMediaThumbnailsViewController *)viewController carouselToPresentAfterSelectingItemAtIndex:(NSInteger)idx
{
    AppDelegate * appdelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;

    appdelegate.currentIndex = idx;
    CarouselViewController *carouselViewController = [[CarouselViewController alloc] init];
    carouselViewController.mediaAssets = self.mediaAssets;
    carouselViewController.hidesBottomBarWhenPushed = YES;
    carouselViewController.currentIndex = idx;
    return carouselViewController;
    
}



@end