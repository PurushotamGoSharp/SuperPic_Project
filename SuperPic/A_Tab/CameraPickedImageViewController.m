//
//  CameraPickedImageViewController.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 15/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "CameraPickedImageViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "StagingViewController.h"
#import "AppDelegate.h"
#import "HomeViewController.h"

#import "ELCImagePickerController.h"
#import "TakenImageModel.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Constant.h"

#import "ALAssetsLibrary+CustomPhotoAlbum.h"


@interface CameraPickedImageViewController () <UITabBarControllerDelegate, ELCImagePickerControllerDelegate>
{
    int count;//, countCaughtImgs;
    NSDateFormatter *dateFormatter;
    NSMutableArray *arrOfImagData;
    
}
@property (weak, nonatomic) IBOutlet UIImageView *caughtImgVw;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UILabel *caughtImgCounterLbl;
@property (weak, nonatomic) IBOutlet UIButton *tiltCamBtn;
@property (strong, nonatomic) IBOutlet UIView* viewBottom;
@property (strong, nonatomic) IBOutlet UIButton* btnBadge;
@property (nonatomic, strong) UIImagePickerController *cameraImagePickerController;
@property (nonatomic, strong) UIImagePickerController *photoLibraryPickerController;

@property (weak, nonatomic) IBOutlet UIButton *cancelCaughtImageButton;

@property (nonatomic, strong) NSMutableArray *caughtImagesMutArr;
@property (weak, nonatomic) IBOutlet UIButton *nextBtnOutlet;
@property (weak, nonatomic) IBOutlet UIButton* btnGalleryCount;
@property (weak, nonatomic) IBOutlet UIButton* btnFlash;
@property (weak, nonatomic) IBOutlet UIButton* btnClose;
@property (weak, nonatomic) IBOutlet UIButton* btnSwitchGallery;
@property (strong, nonatomic) IBOutlet UIImageView* imgNoPhotoTaken;

@end

@implementation CameraPickedImageViewController
{
    BOOL shouldShowCamera;
    BOOL cameraIsShown;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.library = [[ALAssetsLibrary alloc] init];

    shouldShowCamera = YES;
    self.caughtImagesMutArr = [[NSMutableArray alloc] init];
    arrOfImagData = [[NSMutableArray alloc] init];

    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // There is not a camera on this device, so don't show the camera button.
        NSMutableArray *toolbarItems = [self.toolBar.items mutableCopy];
        [toolbarItems removeObjectAtIndex:2];
        [self.toolBar setItems:toolbarItems animated:NO];
    }
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationSharePhoto:) name:@"NotificationRespondToShareImage" object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didBecomeActiveNotification:)
     name:UIApplicationDidBecomeActiveNotification
     object:nil
    ];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    dateFormatter = [[NSDateFormatter alloc]init];
   // dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSSZZZZ";
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";

    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSInteger takenImgCount = (int) delegate.recentlyCuaghtImagesArr.count + self.caughtImagesMutArr.count;

    [self.caughtImgCounterLbl setText:[NSString stringWithFormat:@"%ld",(long) takenImgCount ]];

    if ([self.caughtImgCounterLbl.text isEqualToString:@"0"])
        self.nextBtnOutlet.hidden = YES;
    else
        self.nextBtnOutlet.hidden = NO;
    
    
    
    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.currentIndex = 0;
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
//    if (self.cameraImagePickerController)
//    {
//        [self.cameraImagePickerController dismissViewControllerAnimated:NO completion:^{
//            
//        }];
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self readAndSetImageCount];
//    self.tabBarController.delegate = self;
    //    if (shouldShowCamera) //After we take an image using camera, this method will be called. At that time we should not show camera again.
    //    {
//    [self showImagePickerForCamera:nil];
    //    }

    [self performSelector:@selector(showImagePickerForCamera:) withObject:nil afterDelay:0.3];



    shouldShowCamera = YES;
    [self performSelector:@selector(setButtonTitle:) withObject:nil afterDelay:0.3];
}
         
- (void)notificationSharePhoto:(NSNotification *)notification {
    [self setButtonTitle:nil];
}
         

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    //    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)readAndSetImageCount
{
    
    
}



#pragma mark - Action
- (IBAction)galleryPressed:(id)sender
{
    cameraIsShown = NO;
    //    self.cameraImagePickerController = nil;
    UINavigationController *navController = [self.tabBarController.viewControllers firstObject];
    [navController popToRootViewControllerAnimated:NO];
    
    HomeViewController *homeVC = (HomeViewController *)[navController.viewControllers firstObject];
    homeVC.isCommingFormCamera = NO;
    [self.tabBarController setSelectedIndex:2];
    [self.tabBarController dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction)nextIsPressed:(UIButton *)sender
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.recentlyCuaghtImagesArr addObjectsFromArray:self.caughtImagesMutArr];
    [self.caughtImagesMutArr removeAllObjects];
    delegate.caughtImagesCount = 0;

    
    [self performSegueWithIdentifier:@"CameraNextIdentifier" sender:nil];

    
    [self.tabBarController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)showImagePickerForPhotoPicker:(id)sender
{
    [self.cameraImagePickerController dismissViewControllerAnimated:NO completion:^{
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
}

- (IBAction)showImagePickerForCamera:(id)sender
{
//    if (cameraIsShown) return;

    cameraIsShown = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    }

}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController;
    
    
    if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
        elcPicker.maximumImagesCount = 100; //Set the maximum number of images to select to 100
        elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
        elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
        elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
        elcPicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie]; //Supports image and movie types
        elcPicker.imagePickerDelegate = self;

        [self presentViewController:elcPicker animated:YES completion:nil];
 
        return;
    }

    if (self.cameraImagePickerController == nil)
    {
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
        imagePickerController.delegate = self;
        self.cameraImagePickerController = imagePickerController;

        imagePickerController.sourceType = sourceType;

        if (sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
            imagePickerController.cameraOverlayView = self.overlayView;

            CGSize screenBounds = [UIScreen mainScreen].bounds.size;
            
            CGFloat cameraAspectRatio = 4.0f/3.0f;
            
            CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
            CGFloat scale = screenBounds.height / camViewHeight;
            
            
            CGAffineTransform translate = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
            
            CGAffineTransform scaletransform = CGAffineTransformScale(translate, scale, scale);
    
            imagePickerController.cameraViewTransform = scaletransform;
            
            
            
            CGRect frame = CGRectMake(0,0, 70, 70);
            self.radialView = [[MDRadialProgressView alloc]initWithFrame:frame];
            self.radialView.progressTotal = 300;
            
            self.radialView.theme.sliceDividerHidden = YES;
            
            CGSize screen = [UIScreen mainScreen].bounds.size;
            
            
            
            self.radialView.center = CGPointMake(screen.width/2, screen.height - 42);
            [self.overlayView setFrame:CGRectMake(0, 0, screen.width, screen.height)];
            
            [imagePickerController.cameraOverlayView addSubview:self.radialView];

            UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePhoto)];
            
            [self.radialView addGestureRecognizer:tapGesture];
            
            UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startRecord:)];
            
            [self.radialView addGestureRecognizer:longPressGesture];
            

        }

    }

    imagePickerController.sourceType = sourceType;
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        [imagePickerController setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
        imagePickerController.showsCameraControls = NO;
        
        /*
         Load the overlay view from the OverlayView nib file. Self is the File's Owner for the nib file, so the overlayView outlet is set to the main view in the nib. Pass that view to the image picker controller to use as its overlay view, and set self's reference to the view to nil.
         */

        
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [self.caughtImgCounterLbl setText:[NSString stringWithFormat:@"%ld",(long) (delegate.recentlyCuaghtImagesArr.count + self.caughtImagesMutArr.count) ]];
        
        if ([self.caughtImgCounterLbl.text isEqualToString:@"0"])
        {
            self.nextBtnOutlet.hidden = YES;
        }else
        {
            self.nextBtnOutlet.hidden = NO;
            
        }

        self.overlayView = nil;

  
        
    }

    [self.tabBarController presentViewController:self.cameraImagePickerController animated:NO completion:^
    {
    }];
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)didBecomeActiveNotification:(NSNotification *)notification
{
    [self setButtonTitle:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ( [mediaType isEqualToString:@"public.movie" ])
    {
        [[Mixpanel sharedInstance] track:@"TakeVideo" properties:@{  @"username" : [[NSUserDefaults standardUserDefaults] objectForKey:PROFILE_NAME_KEY]}];
        NSLog(@"Picked a movie at URL %@",  [info objectForKey:UIImagePickerControllerMediaURL]);
        NSURL *videoUrl =  [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *moviePath = [videoUrl path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
        }
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate.recentlyCuaghtImagesArr removeAllObjects];
        [self.caughtImagesMutArr removeAllObjects];
        TakenImageModel *imgModel = [[TakenImageModel alloc] init];
        
        NSDate *curentDate = [NSDate date];
        
        imgModel.imgTakenDate = curentDate;
        imgModel.imagePath = moviePath;
        
        NSLog( @"%@",moviePath);
        
        [self.caughtImagesMutArr addObject:imgModel];
        [self nextIsPressed:nil];
    }
    
    else
    {
    

        
        [[Mixpanel sharedInstance] track:@"TakePhoto" properties:@{  @"username" : [[NSUserDefaults standardUserDefaults] objectForKey:PROFILE_NAME_KEY]}];
        if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
        {
            [self.tabBarController dismissViewControllerAnimated:NO completion:^{
                UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Image imported from Photo Album"
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:nil, nil];
                [toast show];

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
                               {
                                   [toast dismissWithClickedButtonIndex:0 animated:YES];
                               });

            }];
        }

        self.nextBtnOutlet.enabled=YES;

        cameraIsShown = NO;
        shouldShowCamera = NO;
        UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];



        [self.library saveImage:chosenImage toAlbum:@"SuperPic" withCompletionBlock:^(NSError *error) {
            if (error!=nil) {
                NSLog(@"Big error: %@", [error description]);
            }
        }];


        [self.caughtImgVw setImage:chosenImage];
        UIImage *lowResImage = [UIImage imageWithData:UIImageJPEGRepresentation(chosenImage, 0.01)];

        [self finishAndUpdateMoveToHome:NO];
        [self saveImageToDoc:lowResImage];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    cameraIsShown = NO;
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
    {
        [self.tabBarController dismissViewControllerAnimated:NO completion:NULL];
    }

}


- (void)saveImageToDoc:(UIImage *)image
{
    //    NSData *pngData = UIImagePNGRepresentation(image);
    NSData *jpgData = UIImageJPEGRepresentation(image, 0.01);
    NSUInteger imageSize = jpgData.length;
    NSLog(@"SIZE OF IMAGE: %ld ", (unsigned long)imageSize);
    
    count = (int)[[NSUserDefaults standardUserDefaults]integerForKey:@"Image_Name"];
    count++;
    
    NSString *fileName = [NSString stringWithFormat:@"image%i.jpg",count];
    NSLog(@"Img Name = %@", fileName);
    NSString *filePath = [[self docPath] stringByAppendingPathComponent:fileName]; //Add the file name
    [jpgData writeToFile:filePath atomically:YES];
    
    TakenImageModel *imgModel = [[TakenImageModel alloc] init];
    
    NSDate *curentDate = [NSDate date];

    imgModel.imgTakenDate = curentDate;
    imgModel.imagePath = filePath;
    
    NSLog( @"%@",imgModel.imgTakenDate);

    [self.caughtImagesMutArr addObject:imgModel];
    
    
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:@"Image_Name"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [self.caughtImgCounterLbl setText:[NSString stringWithFormat:@"%ld",(long) (delegate.recentlyCuaghtImagesArr.count + self.caughtImagesMutArr.count) ]];
    
    if ([self.caughtImgCounterLbl.text isEqualToString:@"0"])
    {
        self.nextBtnOutlet.hidden = YES;
    }else
    {
        self.nextBtnOutlet.hidden = NO;
        
    }
    delegate.caughtImagesCount++;
}

- (NSString *)docPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0]; //Get the docs directory
}

#pragma mark - Toolbar actions
- (IBAction) setButtonTitle:(id)sender
{
    
    NSInteger gallerycount = [[NSUserDefaults standardUserDefaults]integerForKey:@"GalleryBadgeCount"];
    [self.btnGalleryCount setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if ( gallerycount == 0 )
        {
            
            
            [self.btnGalleryCount setImage:[UIImage imageNamed:@"picture.png"] forState:UIControlStateNormal];
            
            
            [self.btnGalleryCount setTitle:@"" forState:UIControlStateNormal];
            
            
        }
        else{
            [self.btnGalleryCount setImage:[UIImage imageNamed:@"picture_unread.png"] forState:UIControlStateNormal];

            
        }
    });
    int friend_request = (int)[[NSUserDefaults standardUserDefaults]integerForKey:BADGE_COUNT];
    
    
    if (friend_request == 0) {
        self.btnBadge.hidden = YES;
        [self.btnClose setImage:[UIImage imageNamed:@"camerahome.png"] forState:UIControlStateNormal];
        
    }else
    {
        self.btnBadge.hidden = YES;
//        [self.btnBadge setTitle:[NSString stringWithFormat:@"%d", friend_request] forState:UIControlStateNormal];
        [self.btnClose setImage:[UIImage imageNamed:@"camerahome_unread.png"] forState:UIControlStateNormal];
    }
    
    
}

-(void)takePhoto
{
    self.cameraImagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
    [self.cameraImagePickerController takePicture];
}

-(void) startRecord:(UILongPressGestureRecognizer*)sender
{
    if ( sender.state == UIGestureRecognizerStateBegan ) {
    
        self.cameraImagePickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 600 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        
            [self.cameraImagePickerController startVideoCapture];
            
            self.duration = 0;
            self.timerRecord = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                target:self
                                                              selector:@selector(onTickRecord)
                                                              userInfo:nil
                                                               repeats:YES];
            
        });
        
        
        
        
    }else if (sender.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"end long tap");
        [self stopRecord];
        
    }
    
}
-(void)stopRecord
{
    
    [self.timerRecord invalidate];
    self.timerRecord = nil;
    [self.cameraImagePickerController stopVideoCapture];
}
-(void)onTickRecord
{
    self.duration ++;
    self.radialView.progressCounter = self.duration;
    if (self.duration > 300) {
    
        [self stopRecord];
    }
    
}

//goto home button
- (IBAction)done:(id)sender
{
    // Dismiss the camera.
    [self finishAndUpdateMoveToHome:YES];
}

- (void)finishAndUpdateMoveToHome:(BOOL)moveToHome
{
    cameraIsShown = NO;
//    self.cameraImagePickerController = nil;
    if (moveToHome)
    {
        UINavigationController *navController = [self.tabBarController.viewControllers firstObject];
        [navController popToRootViewControllerAnimated:NO];

        HomeViewController *homeVC = (HomeViewController *)[navController.viewControllers firstObject];
        homeVC.isCommingFormCamera = NO;
        [self.tabBarController setSelectedIndex:0];
        [self.tabBarController dismissViewControllerAnimated:YES completion:NULL];

    }
}

- (IBAction)cameraFlashSwitchAction:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *tempBtn = (UIButton *)sender;
        
        switch (self.cameraImagePickerController.cameraFlashMode)
        {
            case UIImagePickerControllerCameraFlashModeAuto:
            {
                NSLog(@"Camera flash mode Auto");
            }
                break;
            case UIImagePickerControllerCameraFlashModeOn:
            {
                NSLog(@"b4: Flash On");
                [self.cameraImagePickerController setCameraFlashMode:UIImagePickerControllerCameraFlashModeOff];
                [tempBtn setImage:[UIImage imageNamed:@"flashoff"] forState:UIControlStateNormal];
                NSLog(@"Aftr: Flash Off");
            }
                break;
            case UIImagePickerControllerCameraFlashModeOff:
            {
                NSLog(@"b4: Flash Off");
                [self.cameraImagePickerController setCameraFlashMode:UIImagePickerControllerCameraFlashModeOn];
                [tempBtn setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
                NSLog(@"Aftr: Flash On");
            }
                break;
            default:
                break;
        }
    
    }
}

- (IBAction)tiltCamSwitchAction:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *tempBtn = (UIButton *)sender;
        switch (self.cameraImagePickerController.cameraDevice) {
            case UIImagePickerControllerCameraDeviceRear:
            {
                self.cameraImagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                [tempBtn setImage:[UIImage imageNamed:@"switchcamera"] forState:UIControlStateNormal];
            }
                break;
            case UIImagePickerControllerCameraDeviceFront:
            {
                self.cameraImagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                [tempBtn setImage:[UIImage imageNamed:@"switchcamera"] forState:UIControlStateNormal];
            }
            default:
                break;
        }
    }
}

/*
 TiltcamFront
 //    imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
 //    imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
 */

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"CameraNextIdentifier"]) {
        if (self.caughtImagesMutArr.count > 0)
        {
            AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
            StagingViewController *tempDestination = [segue destinationViewController];
            tempDestination.stagingGalleryImgsArr = delegate.recentlyCuaghtImagesArr;
        }
    }
}

- (IBAction)takeToBackHome:(id)sender
{
    [self backToHome];
}

#pragma mark - TabBar Delegate
#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    //[self dismissViewControllerAnimated:YES completion:nil];

    self.nextBtnOutlet.enabled=YES;
    cameraIsShown = NO;
    shouldShowCamera = NO;
    
    for (NSDictionary *dict in info) {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            UIImage* chosenImage=[dict objectForKey:UIImagePickerControllerOriginalImage];
            [self.caughtImgVw setImage:chosenImage];
            UIImage *lowResImage = [UIImage imageWithData:UIImageJPEGRepresentation(chosenImage, 0.01)];
            
            [self finishAndUpdateMoveToHome:NO];
            [self saveImageToDoc:lowResImage];
        } else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo){
        } else {
            
        }
    }
    
    [self.tabBarController dismissViewControllerAnimated:NO completion:^{
        if ([info count] > 0) {
            UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Image imported from Photo Album"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil, nil];
            [toast show];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^
                           {
                               [toast dismissWithClickedButtonIndex:0 animated:YES];
                           });
        }
    }];

    
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
