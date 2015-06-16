//
//  AddUserInfoViewController.m
//  IT Support
//
//  Created by Yin Hua on 25/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "AddUserInfoViewController.h"
#import "SignInViewController.h"
#import "AppDelegate.h"

@interface AddUserInfoViewController ()
{
    AppDelegate *mDelegate_;
    
}

@property (weak, nonatomic) IBOutlet UITextField *companyNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *contactNameTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBarButtonItem;

@end

@implementation AddUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    mDelegate_ = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    [self.cancelBarButtonItem setTintColor:mDelegate_.appThemeColor];
    [self.nextBarButtonItem setTintColor:mDelegate_.appThemeColor];
    
    
    //test
//    self.companyNameTextField.text = @"IT Express Pro";
//    self.contactNameTextField.text = @"Benson Shi";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Action
- (IBAction)cancelAction:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextAction:(id)sender {
    
    if ([self checkAllField]) {
        
        [self performSegueWithIdentifier:@"To SignIn View" sender:self];
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Please Fill All Blank."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
}

#pragma mark - mandatory field check

- (BOOL)checkAllField
{
    if ([self.companyNameTextField.text length]>0 &&[self.contactNameTextField.text length]>0) {
        return true;
    }else{
        return false;
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"To SignIn View"]) {
        
        SignInViewController *sivc = [segue destinationViewController];
        sivc.companyName = self.companyNameTextField.text;
        sivc.contactName = self.contactNameTextField.text;
        
    }
}


@end
