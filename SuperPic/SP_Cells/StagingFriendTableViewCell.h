//
//  StagingFriendTableViewCell.h
//  SuperPic
//
//  Created by Syed Hyder Zubair on 21/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "BaseTableViewCell.h"

@protocol StagingFriendTableViewCellDelegate <NSObject>

-(void)removeFriendButtonPressed:(id)cell;
//removeStagingFriendSelectorDelegate

@end

@interface StagingFriendTableViewCell : BaseTableViewCell

@property (nonatomic) IBOutlet UILabel* friendNameLabel;
@property (nonatomic) IBOutlet UIButton* removeFriendButton;

@property (nonatomic,weak) id <StagingFriendTableViewCellDelegate> delegate;

- (IBAction)removeStagingFriendPressed:(id)sender;

- (void)configureCellWithFriendName:(NSString *)fName isRemoveFriendBtnHidden:(BOOL)remBtnHidden;

@end
