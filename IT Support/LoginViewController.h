//
//  LoginViewController.h
//  ez4rent
//
//  Created by Yin Hua on 2/02/2015.
//  Copyright (c) 2015 Yin Hua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate>

- (IBAction)loginAction:(id)sender;
- (IBAction)switchUserAction:(id)sender;
- (IBAction)forgotPasswordAction:(id)sender;

@end
