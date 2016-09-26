//
//  FriendContactTableViewCell.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 21/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "FriendContactTableViewCell.h"

@implementation FriendContactTableViewCell


-(void)awakeFromNib {
    [self.friendContactNameLabel sizeToFit];
    //    self.thumbnailImageView.clipsToBounds = YES;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    //    self.friendNameLabel.backgroundColor = [UIColor whiteColor];
    //    self.friendNameLabel.textColor = [UIColor blackColor];
}

- (void)configureCell:(Person *)aPerson {
    [self.friendContactNameLabel setText:aPerson.fullName];
}


#pragma mark -  Action

- (IBAction)sendFriendRequestPressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendRequestFriendButtonPressed:)]) {
        [self.delegate sendRequestFriendButtonPressed:self];
    }
}

@end
