//
//  RequestTableViewCell.h
//  SuperPic
//
//  Created by Syed Hyder Zubair on 24/04/15.
//  Copyright (c) 2015 Vmoksha Technologies Pvt Ltd. All rights reserved.
//

#import "BaseTableViewCell.h"

@protocol RequestTableViewCellDelegate <NSObject>

- (void)confirmFriendRequestButtonPressed:(id)cell;
- (void)ignoreFriendRequestButtonPressed:(id)cell;

@end


@interface RequestTableViewCell : BaseTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *requestedFriendNameLbl;
@property (nonatomic) IBOutlet UILabel* pointLabel;

@property (nonatomic,weak) id <RequestTableViewCellDelegate> delegate;

- (void)configureCell:(NSString *)requestedFriendName;

- (IBAction)confirmFriendRequestAction:(id)sender;
- (IBAction)ignoreFriendRequestAction:(id)sender;

@end
