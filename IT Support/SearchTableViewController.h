//
//  SearchTableViewController.h
//  IT Support
//
//  Created by Yin Hua on 27/07/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewController : UITableViewController

//segue values from filter controller
@property (strong, nonatomic) NSString *searchCategoryID;
@property (strong, nonatomic) NSDate *searchDueDate;
@property (strong, nonatomic) NSString *searchTitle;


- (IBAction)resetAction:(id)sender;



@end
