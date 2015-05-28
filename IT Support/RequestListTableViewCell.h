//
//  RequestListTableViewCell.h
//  IT Support
//
//  Created by Yin Hua on 20/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdDateLabel;


@end
