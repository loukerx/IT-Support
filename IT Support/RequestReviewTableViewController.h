//
//  RequestReviewTableViewController.h
//  IT Support
//
//  Created by Yin Hua on 19/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestReviewTableViewController : UITableViewController


//property
@property (strong, nonatomic) NSString *requestTitle;
@property (strong, nonatomic) NSString *requestDescription;
@property (strong, nonatomic) NSString *requestPrice;
//add 2015 07 13
@property (strong, nonatomic) NSDate *requestDeadline;
@property (nonatomic) BOOL negotiable;

- (IBAction)sendAction:(UIBarButtonItem *)sender;

@end
