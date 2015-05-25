//
//  RequestDetailTableViewController.h
//  IT Support
//
//  Created by Yin Hua on 19/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestDetailTableViewController : UITableViewController

- (IBAction)confirmAction:(id)sender;

@property (strong, nonatomic) NSDictionary *requestObject;
@end
