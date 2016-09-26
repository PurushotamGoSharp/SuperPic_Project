//
//  FriendContactTableViewCell.h
//  SuperPic
//
//  Created by Syed Hyder Zubair on 21/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "Person.h"

@protocol FriendContactTableViewCellDelegate <NSObject>

-(void)sendRequestFriendButtonPressed:(id)cell;
//removeStagingFriendSelectorDelegate

@end

@interface FriendContactTableViewCell : BaseTableViewCell

@property (nonatomic) IBOutlet UILabel* friendContactNameLabel;
@property (nonatomic) IBOutlet UILabel* pointLabel;

@property (nonatomic,weak) id <FriendContactTableViewCellDelegate> delegate;


- (IBAction)sendFriendRequestPressed:(id)sender;

- (void)configureCell:(Person *)aPerson;

@end
