//
//  FriendsTableViewCell.h
//  SuperPic
//
//  Created by Syed Hyder Zubair on 24/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "BaseTableViewCell.h"

@protocol FriendsTableViewCellDelegate <NSObject>

- (void)unfriendButtonPressed:(id)cell;

@end


@interface FriendsTableViewCell : BaseTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *friendNameLbl;
@property (nonatomic, weak) IBOutlet UIButton *unfriendBtn;
@property (nonatomic) IBOutlet UILabel* pointLabel;
@property (nonatomic,weak) id <FriendsTableViewCellDelegate> delegate;

- (void)configureCell:(NSString *)friendName;

- (IBAction)unfriendAction:(id)sender;

@end
