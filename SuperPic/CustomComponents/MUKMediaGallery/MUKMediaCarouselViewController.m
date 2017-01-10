#import "MUKMediaCarouselViewController.h"

#import "MUKMediaCarouselFullImageViewController.h"
#import "MUKMediaCarouselPlayerViewController.h"

#import "MUKMediaAttributesCache.h"
#import "MUKMediaCarouselFlowLayout.h"
#import "MUKMediaGalleryUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"
#import "Postman.h"
#import "Constant.h"
#define DEBUG_YOUTUBE_EXTRACTION_ALWAYS_FAIL    0
#define DEBUG_LOAD_LOGGING                      0

@interface MUKMediaCarouselViewController () <MUKMediaCarouselItemViewControllerDelegate, MUKMediaCarouselFullImageViewControllerDelegate, MUKMediaCarouselPlayerViewControllerDelegate, postmanDelegate>
{
    Postman *postman;
    NSString* getReadURL;
}
@property (nonatomic) MUKMediaAttributesCache *mediaAttributesCache;
@property (nonatomic) MUKMediaModelCache *imagesCache, *thumbnailImagesCache;
@property (nonatomic) NSMutableIndexSet *loadingImageIndexes, *loadingThumbnailImageIndexes;

@property (nonatomic) BOOL shouldReloadDataInViewWillAppear;
@property (nonatomic) NSMutableArray *pendingViewControllers;
@property (nonatomic) UIButton* closeButton ;
@property (nonatomic) UIButton* downloadButton ;
@property (nonatomic) UIView* bottomview;
@property (nonatomic) UIView* topview;
@property (nonatomic) UILabel* nameLable;
@property (nonatomic) UILabel* dateLable;
@property (nonatomic) NSURL *mediaURL;
@property (nonatomic) MUKMediaAttributes *currentMediaAttribute;

@end

@implementation MUKMediaCarouselViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        CommonInitialization(self);
    }
    
    return self;
}

- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)options
{
    self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
    if (self) {
        CommonInitialization(self);
    }
    
    return self;
}

- (id)init {
    return [self initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{ UIPageViewControllerOptionInterPageSpacingKey : @4.0f }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    postman = [[Postman alloc] init];
    postman.delegate = self;
    
    
    self.view.backgroundColor = [UIColor blackColor];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.bottomview = [[UIView alloc] initWithFrame:CGRectMake(0, size.height-54, size.width, 54)];
    self.bottomview.backgroundColor = [UIColor blackColor];
    
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 30, 30)];
    [self.closeButton addTarget:self action:@selector(onTapClose) forControlEvents:UIControlEventTouchUpInside];
    [self.closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.bottomview addSubview:self.closeButton];
    
    
    self.downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(size.width-50, 0, 30, 30)];
    [self.downloadButton addTarget:self action:@selector(onTapDownload) forControlEvents:UIControlEventTouchUpInside];
    [self.downloadButton setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
    [self.bottomview addSubview:self.downloadButton];
    
    [self.view addSubview:self.bottomview];
    
    self.topview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, 60)];
    self.topview.backgroundColor = [UIColor blackColor];
    
    self.nameLable = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, size.width-16, 24)];
    self.nameLable.textColor = [UIColor whiteColor];
    [self.topview addSubview:self.nameLable];
    
    self.dateLable = [[UILabel alloc] initWithFrame:CGRectMake(16, 12+24, size.width-16, 24)];
    self.dateLable.textColor = [UIColor whiteColor];
    [self.topview addSubview:self.dateLable];
    
    [self.view addSubview:self.topview];

    
    
    self.currentMediaAttribute = [self.carouselDelegate carouselViewController:self attributesForItemAtIndex:self.currentIndex];
    self.nameLable.text = self.currentMediaAttribute.caption;
    self.dateLable.text = [self convertDateString: self.currentMediaAttribute.date];
    //[self sendMarkAsReadbyCode];
    
}

-(NSString*) convertDateString:(NSString*) datestring
{
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc]init];
    dateFormat.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS ZZZ";
    dateFormat.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    NSDate* date = [dateFormat dateFromString:datestring];
    
    [dateFormat setDateFormat:@"MMM d, yyyy"];
    dateFormat.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    NSString * dateStr = [dateFormat stringFromDate:date];
    
    return dateStr;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
 
    
    
    if (self.shouldReloadDataInViewWillAppear) {
        self.shouldReloadDataInViewWillAppear = NO;
        
        // Reload data after -viewDidDisappear has cancelled all loadings
        for (MUKMediaCarouselItemViewController *viewController in self.viewControllers)
        {
            // Load attributes
            MUKMediaAttributes *attributes = [self mediaAttributesForItemAtIndex:viewController.mediaIndex];
            [self configureItemViewController:viewController forMediaAttributes:attributes];
        } // for
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    for (MUKMediaCarouselItemViewController *viewController in self.viewControllers)
    {
        [self cancelAllLoadingsForItemViewController:viewController];
        self.shouldReloadDataInViewWillAppear = YES;
    }
}

#pragma mark - Overrides

- (BOOL)prefersStatusBarHidden {
    return self.topview.hidden;
}

#pragma mark - Methods

- (void)scrollToItemAtIndex:(NSInteger)idx animated:(BOOL)animated completion:(void (^)(BOOL finished))completionHandler
{
    MUKMediaCarouselItemViewController *itemViewController = [self newItemViewControllerForMediaAtIndex:idx];
    MUKMediaCarouselItemViewController *currentViewController = [self firstVisibleItemViewController];
    
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    if (currentViewController && currentViewController.mediaIndex > itemViewController.mediaIndex)
    {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    
    // Load attributes & configure
    self.currentMediaAttribute = [self mediaAttributesForItemAtIndex:idx];
    [self configureItemViewController:itemViewController forMediaAttributes:self.currentMediaAttribute];
    
    // Display view controller
    [self setViewControllers:@[itemViewController] direction:direction animated:animated completion:completionHandler];
}

#pragma mark - Private

static void CommonInitialization(MUKMediaCarouselViewController *viewController)
{
    // <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
    viewController.delegate = viewController;
    viewController.dataSource = viewController;
    
    if ([viewController respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)])
    {
        viewController.automaticallyAdjustsScrollViewInsets = NO;
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        viewController.wantsFullScreenLayout = YES;
#pragma clang diagnostic pop
    }
    
    viewController.imagesCache = [[MUKMediaModelCache alloc] initWithCountLimit:2 cacheNulls:NO];
    viewController.thumbnailImagesCache = [[MUKMediaModelCache alloc] initWithCountLimit:7 cacheNulls:NO];
    viewController.mediaAttributesCache = [[MUKMediaAttributesCache alloc] initWithCountLimit:7 cacheNulls:YES];
    
    viewController.loadingImageIndexes = [[NSMutableIndexSet alloc] init];
    viewController.loadingThumbnailImageIndexes = [[NSMutableIndexSet alloc] init];
    
    
}

- (void)cancelAllLoadingsForItemViewController:(MUKMediaCarouselItemViewController *)viewController
{
    [self cancelAllImageLoadingsForItemAtIndex:viewController.mediaIndex];
    
    viewController = viewController ?: [self visibleItemViewControllerForMediaAtIndex:viewController.mediaIndex];
    
    // If it's a video player and there is no movie player presented full screen,
    // stop playback
    if ([viewController isKindOfClass:[MUKMediaCarouselPlayerViewController class]] &&
        !viewController.presentedViewController)
    {
        [self cancelMediaPlaybackInPlayerViewController:(MUKMediaCarouselPlayerViewController *)viewController];
    }
}

#pragma mark - Private — Item View Controllers

- (MUKMediaCarouselItemViewController *)newItemViewControllerForMediaAtIndex:(NSInteger)idx
{
    // Load attributes
    self.currentMediaAttribute = [self mediaAttributesForItemAtIndex:idx];
    
    // Choose the most appropriate class based on media kind
    Class vcClass = [MUKMediaCarouselFullImageViewController class];
    
    if (self.currentMediaAttribute) {
        switch (self.currentMediaAttribute.kind) {
            case MUKMediaKindAudio:
            case MUKMediaKindVideo:
                vcClass = [MUKMediaCarouselPlayerViewController class];
                break;
                
            default:
                break;
        }
    }
    
    // Allocate an instance
    MUKMediaCarouselItemViewController *viewController = [[vcClass alloc] initWithMediaIndex:idx];
    viewController.captionLabel.text = self.currentMediaAttribute.caption;
    
    return viewController;
}

- (void)configureItemViewController:(MUKMediaCarouselItemViewController *)viewController forMediaAttributes:(MUKMediaAttributes *)attributes
{
    // Common configuration
    viewController.delegate = self;
    viewController.view.backgroundColor = self.view.backgroundColor;
    
    viewController.captionLabel.text = attributes.caption;
    if ([attributes.caption length] && ![self areBarsHidden]) {
        [viewController setCaptionHidden:NO animated:NO completion:nil];
    }
    else {
        [viewController setCaptionHidden:YES animated:NO completion:nil];
    }
    
    // Specific configuration
    if ([viewController isMemberOfClass:[MUKMediaCarouselFullImageViewController class]])
    {
        [self configureFullImageViewController:(MUKMediaCarouselFullImageViewController *)viewController forMediaAttributes:attributes];
    }
    else if ([viewController isMemberOfClass:[MUKMediaCarouselPlayerViewController class]])
    {
        [self configurePlayerViewController:(MUKMediaCarouselPlayerViewController *)viewController forMediaAttributes:attributes];
    }
    
}

- (MUKMediaCarouselItemViewController *)visibleItemViewControllerForMediaAtIndex:(NSInteger)idx
{
    for (MUKMediaCarouselItemViewController *viewController in self.viewControllers)
    {
        if (viewController.mediaIndex == idx) {
            return viewController;
        }
    }
    
    return nil;
}

- (MUKMediaCarouselItemViewController *)pendingItemViewControllerForMediaAtIndex:(NSInteger)idx
{
    for (MUKMediaCarouselItemViewController *viewController in self.pendingViewControllers)
    {
        if (viewController.mediaIndex == idx) {
            return viewController;
        }
    }
    
    return nil;
}

#pragma mark - Private — Full Image View Controllers

- (void)configureFullImageViewController:(MUKMediaCarouselFullImageViewController *)viewController forMediaAttributes:(MUKMediaAttributes *)attributes
{
    MUKMediaImageKind foundImageKind = MUKMediaImageKindNone;
    UIImage *image = [self biggestCachedImageOrRequestLoadingForItemAtIndex:viewController.mediaIndex foundImageKind:&foundImageKind];
    [self setImage:image ofKind:foundImageKind inFullImageViewController:viewController];
}

- (void)setImage:(UIImage *)image ofKind:(MUKMediaImageKind)kind inFullImageViewController:(MUKMediaCarouselFullImageViewController *)viewController
{
    BOOL shouldShowActivityIndicator = (kind != MUKMediaImageKindFullSize);
    if (shouldShowActivityIndicator) {
        [viewController.activityIndicatorView startAnimating];
    }
    else {
        [viewController.activityIndicatorView stopAnimating];
    }
    
    [viewController setImage:image ofKind:kind];
}

- (BOOL)shouldSetLoadedImageOfKind:(MUKMediaImageKind)imageKind intoFullImageViewController:(MUKMediaCarouselFullImageViewController *)viewController
{
    if (!viewController) return NO;
    
    BOOL shouldSetImage = NO;
    
    // It's still visible or it will be visible
    if ([self isVisibleItemViewControllerForMediaAtIndex:viewController.mediaIndex] || [self isPendingItemViewControllerForMediaAtIndex:viewController.mediaIndex])
    {
        // Don't overwrite bigger images
        if (imageKind == MUKMediaImageKindThumbnail &&
            viewController.imageKind == MUKMediaImageKindFullSize)
        {
            shouldSetImage = NO;
        }
        else {
            shouldSetImage = YES;
        }
    }
    
    return shouldSetImage;
}

#pragma mark - Private — Player View Controllers

- (void)configurePlayerViewController:(MUKMediaCarouselPlayerViewController *)viewController forMediaAttributes:(MUKMediaAttributes *)attributes
{
    NSURL *mediaURL = [self.carouselDelegate carouselViewController:self mediaURLForItemAtIndex:viewController.mediaIndex];
    [self configurePlayerViewController:viewController mediaURL:mediaURL forMediaAttributes:attributes];
}

- (void)configurePlayerViewController:(MUKMediaCarouselPlayerViewController *)viewController mediaURL:(NSURL *)mediaURL forMediaAttributes:(MUKMediaAttributes *)attributes
{
    self.mediaURL = mediaURL;
    self.currentMediaAttribute = attributes;
    // Set media URL (this will create room for thumbnail)
    if (mediaURL) {
        [viewController setMediaURL:mediaURL];
    }
    
    // Nullify existing thumbnail
    viewController.thumbnailImageView.image = nil;
    
    // Try to load thumbnail to appeal user eye, from cache
    UIImage *thumbnail = [[self cacheForImageKind:MUKMediaImageKindThumbnail] objectAtIndex:viewController.mediaIndex isNull:NULL];
    
    // Thumbnail available: display it
    if (thumbnail) {
        [self setThumbnailImage:thumbnail stock:NO inPlayerViewController:viewController hideActivityIndicator:YES];
    }
    
    // Thumbnail unavailable: request to delegate
    else {
        // Show loading
        [viewController.activityIndicatorView startAnimating];
        
        // Request loading
        [self loadImageOfKind:MUKMediaImageKindThumbnail forItemAtIndex:viewController.mediaIndex inNextRunLoop:YES];
        
        // Use stock thumbnail in the meanwhile
        if (viewController.thumbnailImageView.image == nil) {
            thumbnail = [self stockThumbnailForMediaKind:attributes.kind];
            [self setThumbnailImage:thumbnail stock:YES inPlayerViewController:viewController hideActivityIndicator:NO];
        }
    }
}

- (BOOL)shouldSetLoadedImageOfKind:(MUKMediaImageKind)imageKind intoPlayerViewController:(MUKMediaCarouselPlayerViewController *)viewController
{
    if (!viewController) return NO;
    
    BOOL shouldSetImage = NO;
    
    // Only thumbnails and when view controller is still visible (or
    // it will be visible soon)
    if (imageKind == MUKMediaImageKindThumbnail &&
        ([self isVisibleItemViewControllerForMediaAtIndex:viewController.mediaIndex] || [self isPendingItemViewControllerForMediaAtIndex:viewController.mediaIndex]))
    {
        shouldSetImage = YES;
    }
    
    return shouldSetImage;
}

- (void)setThumbnailImage:(UIImage *)image stock:(BOOL)isStock inPlayerViewController:(MUKMediaCarouselPlayerViewController *)viewController hideActivityIndicator:(BOOL)hideActivityIndicator
{
    if (hideActivityIndicator) {
        [viewController.activityIndicatorView stopAnimating];
    }
    
    viewController.thumbnailImageView.image = image;
    viewController.thumbnailImageView.contentMode = (isStock ? UIViewContentModeCenter : UIViewContentModeScaleAspectFit);
}

- (void)dismissThumbnailInPlayerViewController:(MUKMediaCarouselPlayerViewController *)viewController
{
    // Cancel thumbnail loading
    [self cancelAllImageLoadingsForItemAtIndex:viewController.mediaIndex];
    
    // Hide thumbnail
    [self setThumbnailImage:nil stock:NO inPlayerViewController:viewController hideActivityIndicator:YES];
}


#pragma mark - Private — Current State

- (BOOL)isPendingItemViewControllerForMediaAtIndex:(NSInteger)idx {
    for (MUKMediaCarouselItemViewController *viewController in self.pendingViewControllers)
    {
        if (viewController.mediaIndex == idx) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isVisibleItemViewControllerForMediaAtIndex:(NSInteger)idx {
    for (MUKMediaCarouselItemViewController *viewController in self.viewControllers)
    {
        if (viewController.mediaIndex == idx) {
            return YES;
        }
    }
    
    return NO;
}

- (MUKMediaCarouselItemViewController *)firstVisibleItemViewController {
    return [self.viewControllers firstObject];
}

#pragma mark - Private — Media Attributes

- (MUKMediaAttributes *)mediaAttributesForItemAtIndex:(NSInteger)idx {
    return [self.mediaAttributesCache mediaAttributesAtIndex:idx cacheIfNeeded:YES loadingHandler:^MUKMediaAttributes *
    {
        if ([self.carouselDelegate respondsToSelector:@selector(carouselViewController:attributesForItemAtIndex:)])
        {
            return [self.carouselDelegate carouselViewController:self attributesForItemAtIndex:idx];
        }
      
        return nil;
    }];
}

#pragma mark - Private — Images

- (MUKMediaModelCache *)cacheForImageKind:(MUKMediaImageKind)kind {
    MUKMediaModelCache *cache;
    
    switch (kind) {
        case MUKMediaImageKindThumbnail:
            cache = self.thumbnailImagesCache;
            break;
            
        case MUKMediaImageKindFullSize:
            cache = self.imagesCache;
            break;
            
        default:
            cache = nil;
            break;
    }
    
    return cache;
}

- (NSMutableIndexSet *)loadingIndexesForImageKind:(MUKMediaImageKind)kind {
    NSMutableIndexSet *indexSet;
    
    switch (kind) {
        case MUKMediaImageKindThumbnail:
            indexSet = self.loadingThumbnailImageIndexes;
            break;
            
        case MUKMediaImageKindFullSize:
            indexSet = self.loadingImageIndexes;
            break;
            
        default:
            indexSet = nil;
            break;
    }
    
    return indexSet;
}

- (BOOL)isLoadingImageOfKind:(MUKMediaImageKind)imageKind atIndex:(NSInteger)idx
{
    return [[self loadingIndexesForImageKind:imageKind] containsIndex:idx];
}

- (void)setLoading:(BOOL)loading imageOfKind:(MUKMediaImageKind)imageKind atIndex:(NSInteger)idx
{
    NSMutableIndexSet *indexSet = [self loadingIndexesForImageKind:imageKind];
    
    if (loading) {
        [indexSet addIndex:idx];
    }
    else {
        [indexSet removeIndex:idx];
    }
}

- (UIImage *)biggestCachedImageOrRequestLoadingForItemAtIndex:(NSInteger)idx foundImageKind:(MUKMediaImageKind *)foundImageKind
{
#if DEBUG_LOAD_LOGGING
    NSLog(@"Loading image for media at index %i...", idx);
#endif
    // Try to load biggest image
    UIImage *fullImage = [[self cacheForImageKind:MUKMediaImageKindFullSize] objectAtIndex:idx isNull:NULL];
    
    // If full image is there, we have just finished :)
    if (fullImage) {
        if (foundImageKind != NULL) {
            *foundImageKind = MUKMediaImageKindFullSize;
        }
        
#if DEBUG_LOAD_LOGGING
        NSLog(@"Found in cache!");
#endif
        
        return fullImage;
    }
    
    // No full image in cache :(
    // We need to request full image loading to delegate
    [self loadImageOfKind:MUKMediaImageKindFullSize forItemAtIndex:idx inNextRunLoop:YES];
    
    // Try to load thumbnail to appeal user eye from cache
    UIImage *thumbnail = [[self cacheForImageKind:MUKMediaImageKindThumbnail] objectAtIndex:idx isNull:NULL];

    // Give back thumbnail if it's in memory
    if (thumbnail) {
        if (foundImageKind != NULL) {
            *foundImageKind = MUKMediaImageKindThumbnail;
        }
        
        return thumbnail;
    }
    
    // Thumbnail is not available, too :(
    // Request it to delegate!
    [self loadImageOfKind:MUKMediaImageKindThumbnail forItemAtIndex:idx inNextRunLoop:YES];
    
    // No image in memory
    if (foundImageKind != NULL) {
        *foundImageKind = MUKMediaImageKindNone;
    }
    
    return nil;
}

- (void)loadImageOfKind:(MUKMediaImageKind)imageKind forItemAtIndex:(NSInteger)idx inNextRunLoop:(BOOL)useNextRunLoop
{
    // Mark as loading
    [self setLoading:YES imageOfKind:imageKind atIndex:idx];
    
    // This block is called by delegate which can give back an image
    // asynchronously
    __weak MUKMediaCarouselViewController *weakSelf = self;
    void (^completionHandler)(UIImage *) = ^(UIImage *image) {
        MUKMediaCarouselViewController *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        // If it's still loading
        if ([strongSelf isLoadingImageOfKind:imageKind atIndex:idx]) {
            // Mark as not loading
            [strongSelf setLoading:NO imageOfKind:imageKind atIndex:idx];
            
            // Stop smaller loading
            [strongSelf cancelImageLoadingSmallerThanKind:imageKind atIndex:idx];
            
            // Cache image
            [[strongSelf cacheForImageKind:imageKind] setObject:image atIndex:idx];
            
            // Get actual item view controller, searching for it inside visible
            // view controllers and pending view controllers
            MUKMediaCarouselItemViewController *viewController = [strongSelf visibleItemViewControllerForMediaAtIndex:idx] ?: [self pendingItemViewControllerForMediaAtIndex:idx];
            
            // Set image if needed
            if ([viewController isKindOfClass:[MUKMediaCarouselFullImageViewController class]])
            {
                MUKMediaCarouselFullImageViewController *fullImageViewController = (MUKMediaCarouselFullImageViewController *)viewController;
                
                if ([strongSelf shouldSetLoadedImageOfKind:imageKind intoFullImageViewController:fullImageViewController])
                {
                    [strongSelf setImage:image ofKind:imageKind inFullImageViewController:fullImageViewController];
                }
            }
            
            // Set video if needed
            else if ([viewController isKindOfClass:[MUKMediaCarouselPlayerViewController class]])
            {
                MUKMediaCarouselPlayerViewController *playerViewController = (MUKMediaCarouselPlayerViewController *)viewController;
                if ([strongSelf shouldSetLoadedImageOfKind:imageKind intoPlayerViewController:playerViewController])
                {
                    BOOL stock = NO;
                    
                    if (!image) {
                        // Use stock thumbnail
                        MUKMediaAttributes *attributes = [strongSelf mediaAttributesForItemAtIndex:idx];
                        image = [strongSelf stockThumbnailForMediaKind:attributes.kind];
                        stock = YES;
                    }
                    
                    BOOL hideActivityIndicator = YES;
                    
                    
                    
                    [strongSelf setThumbnailImage:image stock:stock inPlayerViewController:playerViewController hideActivityIndicator:hideActivityIndicator];
                }
            }
        } // if isLoadingImageKind
    }; // completionHandler
    
    // Call delegate in next run loop when we need view controller enters in reuse queue
    if (useNextRunLoop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.carouselDelegate carouselViewController:self loadImageOfKind:imageKind forItemAtIndex:idx completionHandler:completionHandler];
        });
    }
    else {
        [self.carouselDelegate carouselViewController:self loadImageOfKind:imageKind forItemAtIndex:idx completionHandler:completionHandler];
    }
}

- (void)cancelLoadingForImageOfKind:(MUKMediaImageKind)imageKind atIndex:(NSInteger)index
{
    if ([self isLoadingImageOfKind:imageKind atIndex:index]) {
        // Mark as not loading
        [self setLoading:NO imageOfKind:imageKind atIndex:index];
        
        // Request delegate to abort
        if ([self.carouselDelegate respondsToSelector:@selector(carouselViewController:cancelLoadingForImageOfKind:atIndex:)])
        {
            [self.carouselDelegate carouselViewController:self cancelLoadingForImageOfKind:imageKind atIndex:index];
        }
    }
}

- (void)cancelImageLoadingSmallerThanKind:(MUKMediaImageKind)imageKind atIndex:(NSInteger)idx
{
    if (imageKind == MUKMediaImageKindFullSize) {
        [self cancelLoadingForImageOfKind:MUKMediaImageKindThumbnail atIndex:idx];
    }
}

- (void)cancelAllImageLoadingsForItemAtIndex:(NSInteger)idx {
    [self cancelLoadingForImageOfKind:MUKMediaImageKindFullSize atIndex:idx];
    [self cancelLoadingForImageOfKind:MUKMediaImageKindThumbnail atIndex:idx];
}

- (UIImage *)stockThumbnailForMediaKind:(MUKMediaKind)mediaKind {
    UIImage *thumbnail;
    
    switch (mediaKind) {
        case MUKMediaKindAudio: {
            thumbnail = [MUKMediaGalleryUtils imageNamed:@"audio_big_transparent"];
            
            if ([thumbnail respondsToSelector:@selector(imageWithRenderingMode:)]) {
                
                thumbnail = [thumbnail imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            
            break;
        }
            
        case MUKMediaKindVideo:
        case MUKMediaKindYouTubeVideo: {
            thumbnail = [MUKMediaGalleryUtils imageNamed:@"video_big_transparent"];
            
            if ([thumbnail respondsToSelector:@selector(imageWithRenderingMode:)])
            {
                thumbnail = [thumbnail imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            
            break;
        }
            
        default:
            thumbnail = nil;
            break;
    }
    
    return thumbnail;
}

#pragma mark - Private — Media Playback

- (void)cancelMediaPlaybackInPlayerViewController:(MUKMediaCarouselPlayerViewController *)viewController
{
    [viewController setMediaURL:nil];
    
}

- (BOOL)shouldDismissThumbnailAsNewPlaybackStartsInPlayerViewController:(MUKMediaCarouselPlayerViewController *)viewController
{
    // Load attributes
    self.currentMediaAttribute = [self mediaAttributesForItemAtIndex:viewController.mediaIndex];
    
    BOOL shouldDismissThumbnail;
    
    // Keep thumbnail for audio tracks
    if (self.currentMediaAttribute.kind == MUKMediaKindAudio) {
        shouldDismissThumbnail = NO;
    }
    else {
        if (viewController.moviePlayerController.playbackState != MPMoviePlaybackStateStopped ||
            viewController.moviePlayerController.playbackState != MPMoviePlaybackStatePaused)
        {
            shouldDismissThumbnail = YES;
        }
        else {
            shouldDismissThumbnail = NO;
        }
    }
    
    return shouldDismissThumbnail;
}


#pragma mark - Private — Bars

- (BOOL)areBarsHidden {
    return self.closeButton.hidden;
}

- (void)setBarsHidden:(BOOL)hidden animated:(BOOL)animated {
    BOOL automaticallyManagesStatusBar = [self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    
    if (!automaticallyManagesStatusBar) {
        UIStatusBarAnimation animation = UIStatusBarAnimationNone;
        
        if (animated) {
            if (hidden) {
                animation = UIStatusBarAnimationSlide;
            }
            else {
                animation = UIStatusBarAnimationFade;
            }
        }
        
        [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animation];
    }
    
    
    
    if (automaticallyManagesStatusBar) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    for (MUKMediaCarouselItemViewController *viewController in self.viewControllers)
    {
        if (hidden || (!hidden && [viewController.captionLabel.text length] > 0))
        {
            [viewController setCaptionHidden:hidden animated:animated completion:nil];
        }
    } // for
    
    self.closeButton.hidden = hidden;
    self.downloadButton.hidden = hidden;
    self.bottomview.hidden = hidden;
    
    self.topview.hidden = hidden;
}

- (void)toggleBarsVisibility {
    BOOL barsHidden = [self areBarsHidden];
    [self setBarsHidden:!barsHidden animated:YES];
}

#pragma mark - <UIPageViewControllerDelegate>

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    [self setBarsHidden:YES animated:YES];
    
    // Save pending view controllers
    self.pendingViewControllers = [pendingViewControllers mutableCopy];
    
    // Configure new view controllers
    for (MUKMediaCarouselItemViewController *itemViewController in pendingViewControllers)
    {
#if DEBUG_LOAD_LOGGING
        NSLog(@"Configuring media at index %i at -pageViewController:willTransitionToViewControllers:", itemViewController.mediaIndex);
#endif
        // Load attributes
        MUKMediaAttributes *attributes = [self mediaAttributesForItemAtIndex:itemViewController.mediaIndex];
        [self configureItemViewController:itemViewController forMediaAttributes:attributes];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    // When view controller disappear, stop loadings
    for (MUKMediaCarouselItemViewController *previousViewController in previousViewControllers)
    {
        if (![pageViewController.viewControllers containsObject:previousViewController])
        {
#if DEBUG_LOAD_LOGGING
            NSLog(@"Cancel all loadings for media at index %i at -didFinishAnimating:previousViewControllers:transitionCompleted:", previousViewController.mediaIndex);
#endif
            [self cancelAllLoadingsForItemViewController:previousViewController];
        }
    } // for
    
    MUKMediaCarouselItemViewController* tmp = (MUKMediaCarouselItemViewController*)[pageViewController.viewControllers lastObject];
    
    self.currentIndex = tmp.mediaIndex;
    self.currentMediaAttribute = [self.carouselDelegate carouselViewController:self attributesForItemAtIndex:self.currentIndex];
    
    MUKMediaAttributes* tmpAttributes = [self.carouselDelegate carouselViewController:self attributesForItemAtIndex:self.currentIndex];
    self.nameLable.text = tmpAttributes.caption;
    self.dateLable.text = [self convertDateString:tmpAttributes.date];
    // Clean pending view controllers
    self.pendingViewControllers = nil;
    
    [self sendMarkAsReadbyCode];
}


#pragma mark - <UIPageViewControllerDataSource>

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    MUKMediaCarouselItemViewController *itemViewController = (MUKMediaCarouselItemViewController *)viewController;
    
    // It's first item
    if (itemViewController.mediaIndex <= 0) {
        return nil;
    }
    
    return [self newItemViewControllerForMediaAtIndex:itemViewController.mediaIndex - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    MUKMediaCarouselItemViewController *itemViewController = (MUKMediaCarouselItemViewController *)viewController;
    
    // It's last item
    NSInteger itemsCount = [self.carouselDelegate numberOfItemsInCarouselViewController:self];
    if (itemViewController.mediaIndex + 1 >= itemsCount) {
        return nil;
    }
    
    return [self newItemViewControllerForMediaAtIndex:itemViewController.mediaIndex + 1];
}

#pragma mark - <MUKMediaCarouselItemViewControllerDelegate>

- (void)carouselItemViewControllerDidReceiveTap:(MUKMediaCarouselItemViewController *)viewController
{
    // Show movie controls if bars are hidden and current item is an audio/video
    // Hide movie controls if bars are shows and current item is already playing
    
    if ([viewController isKindOfClass:[MUKMediaCarouselPlayerViewController class]])
    {
        MUKMediaCarouselPlayerViewController *playerViewController = (MUKMediaCarouselPlayerViewController *)viewController;
        if ([self areBarsHidden]) {
            [playerViewController setPlayerControlsHidden:NO animated:YES completion:nil];
        }
        else if (playerViewController.moviePlayerController.playbackState == MPMoviePlaybackStatePlaying)
        {
            [playerViewController setPlayerControlsHidden:YES animated:YES completion:nil];
        }
    }
    
    [self toggleBarsVisibility];
}

#pragma mark - <MUKMediaCarouselFullImageViewControllerDelegate>

- (void)carouselFullImageViewController:(MUKMediaCarouselFullImageViewController *)viewController imageScrollViewDidReceiveTapWithGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer
{
    [self toggleBarsVisibility];
}

#pragma mark - <MUKMediaCarouselPlayerViewControllerDelegate>

- (void)carouselPlayerViewControllerDidChangeNowPlayingMovie:(MUKMediaCarouselPlayerViewController *)viewController
{
    // Dismiss thumbnail (if needed) when new playback starts (or begins scrubbing)
    if ([self shouldDismissThumbnailAsNewPlaybackStartsInPlayerViewController:viewController])
    {
        [self dismissThumbnailInPlayerViewController:viewController];
    }
}

- (void)carouselPlayerViewControllerDidChangePlaybackState:(MUKMediaCarouselPlayerViewController *)viewController
{
    // Hide bars when playback starts
    if (viewController.moviePlayerController.playbackState == MPMoviePlaybackStatePlaying)
    {
        [self setBarsHidden:YES animated:YES];
    }
}


#pragma mark bottom buttons action
-(void) onTapClose
{
    NSLog(@"close");
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}
-(void) onTapDownload
{
    

    NSURL* fullURL = [self.carouselDelegate carouselViewController:self mediaURLForItemAtIndex:self.currentIndex];
    MUKMediaAttributes* attribute = [self.carouselDelegate carouselViewController:self attributesForItemAtIndex:self.currentIndex];
    
    if (attribute.kind == MUKMediaKindVideo) {
        
        //download the file in a seperate thread.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"Downloading Started");
            
            NSData *urlData = [NSData dataWithContentsOfURL:fullURL];
            if ( urlData )
            {
                NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString  *documentsDirectory = [paths objectAtIndex:0];
                
                NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"thefile.mp4"];
                
                //saving is done on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [urlData writeToFile:filePath atomically:YES];
                    
                    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:filePath] completionBlock:^(NSURL *assetURL, NSError *error) {
                        
                        if(assetURL) {
                            [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:filePath] error:nil];

                            UIAlertController *toast = [UIAlertController alertControllerWithTitle:nil message:@"Video saved to gallery" preferredStyle:UIAlertControllerStyleAlert];
                            
                            [self presentViewController:toast animated:YES completion:nil];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                [toast dismissViewControllerAnimated:YES completion:^{
                                    NSLog(@"toast dismissed");
                                }];
                            });
                            
                        } else {
                            NSLog(@"something wrong");
                        }
                    }];
                    
                    NSLog(@"File Saved !");
                });
            }
            
        });
    }else if (attribute.kind == MUKMediaKindImage){
        UIImage *fullImage = [[self cacheForImageKind:MUKMediaImageKindFullSize] objectAtIndex:self.currentIndex isNull:NULL];
        
        // If full image is there, we have just finished :)
        if (fullImage) {
            UIImageWriteToSavedPhotosAlbum(fullImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }else{
            
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^{
                NSData * imageData = [NSData dataWithContentsOfURL:fullURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithData:imageData];
                    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                });
            });
            
            
        }
    }
    
    
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    // Unable to save the image
    if (error) {
        
        NSString *message = @"Unable to save image to Photo Album.";
        if ([UIAlertController class])
        {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
        else
        {
            
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
            
        }
        
    }else
    {// All is well
        NSLog(@"Success!\nImage Saved.");
        //        [SVProgressHUD showSuccessWithStatus:messageHUD];
        //        [self myPerformBlock:^{[SVProgressHUD dismiss];} afterDelay:0.5];
        
        NSString *message = @"Saved image to Photo Album.";
        
        int duration = 1; // duration in seconds
        
        if ([UIAlertController class])
        {
            UIAlertController *toast = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:toast animated:YES completion:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [toast dismissViewControllerAnimated:YES completion:^{
                    NSLog(@"toast dismissed");
                }];
            });
        }
        else
        {
            UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil, nil];
            [toast show];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [toast dismissWithClickedButtonIndex:0 animated:YES];
            });
            
        }
    }
}

#define GET_READ  [NSString stringWithFormat:@"%@%@",BASE_URL, @"read/"]
-(void) sendMarkAsReadbyCode
{
    
    if (self.currentMediaAttribute.read != 1) {
        getReadURL = [NSString stringWithFormat:@"%@%@", GET_READ, self.currentMediaAttribute.sharedcode];
        
        [postman get:getReadURL];
    }
    
    
}


//MARK: postman delegate
- (void)postman:(Postman *)postman gotSuccess:(NSData *)response forURL:(NSString *)urlString
{
//    if ([urlString isEqualToString:getReadURL])
//    {
//        
//        NSDictionary *JSONDict = [NSJSONSerialization JSONObjectWithData:response
//                                                                 options:kNilOptions
//                                                                   error:nil];
//        if (JSONDict[@"aaData"][@"Success"])
//        {
//            
//            NSString *curentUserCode =  [[NSUserDefaults standardUserDefaults] valueForKey:CURRENT_USER_CODE];
//            
//            if (![self.currentMediaAttribute.ownercode isEqualToString:curentUserCode] && self.currentMediaAttribute.read == 0) {
//                
//                AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//                
//                NSMutableArray *filteredArray = [NSMutableArray array];
//                [filteredArray addObject:self.currentMediaAttribute.ownercode];
//                
//                [appDelegate sendPushToUsersbyTags:filteredArray message:[NSString stringWithFormat:@"%@ \\uD83D\\uDE01",[[NSUserDefaults standardUserDefaults] objectForKey:PROFILE_NAME_KEY]]];
//                
//                
//            }
//            
//            
//        }
//        
//        
//        
//        
//    }else
//    {
//        
//    }
}
- (void)postman:(Postman *)postman gotFailure:(NSError *)error forURL:(NSString *)urlString
{
    
    
}


@end
