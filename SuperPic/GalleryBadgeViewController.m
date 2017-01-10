//
//  GalleryBadgeViewController.m
//  SuperPic
//
//  Created by Vmoksha on 07/05/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "GalleryBadgeViewController.h"
#import "GalleryViewController.h"
#import "Constant.h"
#import "AppDelegate.h"
@interface GalleryBadgeViewController ()<UITabBarControllerDelegate>

@end

@implementation GalleryBadgeViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.delegate = self;

        NSMutableArray* viewcontrollers = [[NSMutableArray alloc]initWithArray:self.viewControllers];
        
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:[[GalleryViewController alloc] init]];
        
        
        [viewcontrollers addObject:nav];
        self.viewControllers = viewcontrollers;
  
        UITabBarItem *tabBarItem3 = [self.tabBar.items objectAtIndex:2];
    
        [tabBarItem3 setTitle:@""];
    
    
        tabBarItem3.image = [UIImage imageNamed:@"tabgallery"];
        tabBarItem3.selectedImage = [UIImage imageNamed:@"tabgallery_sel"];
    
        tabBarItem3.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateGalleryBadgeCount)
                                                 name:@"GalleryNotification"
                                               object:nil];

}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self updateGalleryBadgeCount];
}

- (void)updateGalleryBadgeCount
{
    NSInteger count = [[NSUserDefaults standardUserDefaults]integerForKey:@"GalleryBadgeCount"];
    
    UITabBarItem *tabBarItem = self.tabBar.items[2];
    
    if (count == 0)
    {
        tabBarItem.badgeValue = nil;
    }else
    { 
        tabBarItem.badgeValue = [NSString stringWithFormat:@"%li",(long)count];
    }
   
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
