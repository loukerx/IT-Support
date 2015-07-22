//
//  EventBoardTableViewCell.h
//  IT Support
//
//  Created by Yin Hua on 22/07/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventBoardTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *userColorView;

@property (weak, nonatomic) IBOutlet UILabel *dueDayLabel;

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end
