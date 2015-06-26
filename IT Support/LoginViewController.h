//
//  LoginViewController.h
//  IT Support
//
//  Created by Yin Hua on 19/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate>

- (IBAction)loginAction:(id)sender;
- (IBAction)switchUserAction:(id)sender;
- (IBAction)forgotPasswordAction:(id)sender;

@end
