//
//  RequestTableViewCell.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 24/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "RequestTableViewCell.h"

@implementation RequestTableViewCell

-(void)awakeFromNib {
    [self.requestedFriendNameLbl sizeToFit];
    //    self.thumbnailImageView.clipsToBounds = YES;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    //    self.requestedFriendNameLbl.backgroundColor = [UIColor whiteColor];
    //    self.requestedFriendNameLbl.textColor = [UIColor blackColor];
}

- (void)configureCell:(NSString *)requestedFriendName {
    self.selectionStyle  = UITableViewCellEditingStyleNone;
    [self.requestedFriendNameLbl setText:requestedFriendName];
}

#pragma mark - Actions

- (IBAction)confirmFriendRequestAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(confirmFriendRequestButtonPressed:)]) {
        [self.delegate confirmFriendRequestButtonPressed:self];
    }
}

- (IBAction)ignoreFriendRequestAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ignoreFriendRequestButtonPressed:)]) {
        [self.delegate ignoreFriendRequestButtonPressed:self];
    }
}


@end
