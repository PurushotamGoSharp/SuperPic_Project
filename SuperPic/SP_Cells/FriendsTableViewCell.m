//
//  FriendsTableViewCell.m
//  SuperPic
//
//  Created by Syed Hyder Zubair on 24/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "FriendsTableViewCell.h"
#import "FriendRequestModel.h"

@implementation FriendsTableViewCell

-(void)awakeFromNib {
    [self.friendNameLbl sizeToFit];
    //    self.thumbnailImageView.clipsToBounds = YES;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    //    self.friendNameLbl.backgroundColor = [UIColor whiteColor];
    //    self.friendNameLbl.textColor = [UIColor blackColor];
}

- (void)configureCell:(NSString *)friendName
{
    [self.friendNameLbl setText:friendName];
    
    if ([friendName isEqualToString:@"You"]) {
        self.selectionStyle  = UITableViewCellSelectionStyleNone;
    }
    else {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    [self.unfriendBtn setHidden:YES];
    
//    
//    if (([friendName isEqualToString:@"You"]) || ([friendName isEqualToString:@"Send to All Friends"])) {
//        [self.unfriendBtn setHidden:YES];
//        [self.unfriendBtn setUserInteractionEnabled:NO];
//        [self.unfriendBtn setEnabled:NO];
//    }
//    else {
//        [self.unfriendBtn setHidden:NO];
//        [self.unfriendBtn setUserInteractionEnabled:YES];
//        [self.unfriendBtn setEnabled:YES];
//    }
}

#pragma mark - Action

- (IBAction)unfriendAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(unfriendButtonPressed:)]) {
        [self.delegate unfriendButtonPressed:self];
    }
}

@end
