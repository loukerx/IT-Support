//
//  MenuListViewController.h
//  ez4rent
//
//  Created by Yin Hua on 13/04/2015.
//  Copyright (c) 2015 Yin Hua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>


- (IBAction)hideMuneButtonClick:(id)sender;
@property (weak, nonatomic) UIViewController *superController;



- (IBAction)logInAction:(id)sender;

@end
