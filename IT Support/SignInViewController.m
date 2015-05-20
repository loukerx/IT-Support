//
//  SignInViewController.m
//  IT Support
//
//  Created by Yin Hua on 20/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "SignInViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface SignInViewController ()
{
    AppDelegate *mDelegate_;
    MBProgressHUD *hud_;
}


@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmTextField;
@property (weak, nonatomic) IBOutlet UITextField *companyPhoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileNumberTextField;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    
}
- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submitAction:(id)sender {
    //check password
    if ([self.passwordTextField.text isEqualToString:self.passwordConfirmTextField.text]) {
        
        if ([self checkAllField]) {
            //submit and create an account
            [self performSegueWithIdentifier:@"To Login View" sender:self];
//            [self createClientAccount];
            
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Please Fill All Blank."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Password Error"
                                                            message:@"Please Confirm Your Password."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (BOOL)checkAllField
{
    if ([self.emailAddressTextField.text length]>0 &&[self.passwordTextField.text length]>0 && [self.passwordConfirmTextField.text length]>0 && [self.companyPhoneTextField.text length]>0  && [self.mobileNumberTextField.text length]>0) {
        return true;
    }else{
        return false;
    }
}

-(void)createClientAccount{
    
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    NSString *f = @"userRegister";
    NSString *deviceId = @"";
    NSString *mobilenum = @"";
    
    NSDictionary *parameters = @{@"f" : f,
                                 @"deviceId" : deviceId,
                                 @"mobilenum": mobilenum
                                 };
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:@"" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        NSLog(@"create client account");

        [self performSegueWithIdentifier:@"To Login View" sender:self];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Creating Client Account"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
}



#pragma mark - others
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
