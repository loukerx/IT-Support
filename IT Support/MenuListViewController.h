//
//  MenuListViewController.h
//  IT Support
//
//  Created by Yin Hua on 19/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>


- (IBAction)hideMuneButtonClick:(id)sender;
@property (weak, nonatomic) UIViewController *superController;



- (IBAction)logOutAction:(id)sender;

@end
