//
//  StagingFriendTableViewCell.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 21/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "StagingFriendTableViewCell.h"

@implementation StagingFriendTableViewCell

-(void)awakeFromNib {
//    self.thumbnailImageView.clipsToBounds = YES;
//    [self changeSelectedBackgroundCellViewColor];
}

- (void)configureCellWithFriendName:(NSString *)fName isRemoveFriendBtnHidden:(BOOL)remBtnHidden {
    [self.friendNameLabel setText:fName];
    [self.removeFriendButton setHidden:remBtnHidden];
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    //    self.friendNameLabel.backgroundColor = [UIColor whiteColor];
    //    self.friendNameLabel.textColor = [UIColor blackColor];
}

/*
- (void)changeSelectedBackgroundCellViewColor {
    UIView *myBackView = [[UIView alloc] initWithFrame:self.frame];
    myBackView.backgroundColor = [UIColor colorWithRed:110.0/255.0 green:193.0/255.0 blue:252/255.0 alpha:1];
    //    myBackView.layer.cornerRadius = 10;
    
    myBackView.layer.borderColor = [UIColor whiteColor].CGColor;
    myBackView.layer.borderWidth = 1.5f;
    
    self.selectedBackgroundView = myBackView;
    
}
 */


#pragma mark - Actions

- (IBAction)removeStagingFriendPressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(removeFriendButtonPressed:)]) {
        [self.delegate removeFriendButtonPressed:self];
    }
}

@end
