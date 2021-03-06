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
@property (weak, nonatomic) IBOutlet UITextField *contactNumberTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBarButtonItem;

@end

@implementation AddUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    mDelegate_ = (AppDelegate *) [[UIApplication sharedApplication]delegate];

    //setting color
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:mDelegate_.appThemeColor];

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
        UIAlertController* alert =
        [UIAlertController alertControllerWithTitle:@"Error!!"
                                            message:@"Please Fill All Blank."
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction =
        [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {}];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

#pragma mark - mandatory field check

- (BOOL)checkAllField
{
    if ([self.companyNameTextField.text length] > 0 &&[self.contactNameTextField.text length] > 0 && [self.contactNumberTextField.text length] > 0) {
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
        sivc.contactNumber = self.contactNumberTextField.text;
        
    }
}


@end
