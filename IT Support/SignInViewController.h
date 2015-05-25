//
//  SignInViewController.h
//  IT Support
//
//  Created by Yin Hua on 20/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController

- (IBAction)submitAction:(id)sender;

@property (strong, nonatomic) NSString *companyName;
@property (strong, nonatomic) NSString *contactName;
@end
