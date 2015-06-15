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

@interface SignInViewController ()<UIActionSheetDelegate>
{
    AppDelegate *mDelegate_;
    MBProgressHUD *HUD_;
}


@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmTextField;
@property (weak, nonatomic) IBOutlet UITextField *companyPhoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;


@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.submitButton setBackgroundColor:mDelegate_.appThemeColor];
    self.navigationController.navigationBar.tintColor = mDelegate_.appThemeColor;
    //test
    self.emailAddressTextField.text = @"hua.yin@itexpresspro.com.au";
    self.passwordTextField.text = @"qwe";
    self.passwordConfirmTextField.text = @"qwe";
    self.companyPhoneTextField.text = @"022234";
    self.mobileNumberTextField.text =@"123123";
}

#pragma mark - mandatory field check

- (BOOL)checkAllField
{
    if ([self.emailAddressTextField.text length]>0 &&[self.passwordTextField.text length]>0 && [self.passwordConfirmTextField.text length]>0 && [self.companyPhoneTextField.text length]>0  && [self.mobileNumberTextField.text length]>0) {
        return true;
    }else{
        return false;
    }
}

#pragma mark - actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            //check password
            if ([self.passwordTextField.text isEqualToString:self.passwordConfirmTextField.text]) {
                
                if ([self checkAllField]) {
                    HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    HUD_.labelText = @"Processing...";
                    //submit and create an account
                    [self createClientAccount];
                    
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
            break;
        default:
            break;
    }
    
}

#pragma mark - Button Action
- (IBAction)submitAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Submit"
                                                    otherButtonTitles:nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

-(void)createClientAccount{
    
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    //http://ec2-54-79-39-165.ap-southeast-2.compute.amazonaws.com/ITSupportService/api/Client
    
    
    NSString *email = self.emailAddressTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *companyName = self.companyName;
    NSString *contactName = self.contactName;
    NSString *phone = self.companyPhoneTextField.text;
    NSString *mobile = self.mobileNumberTextField.text;
    
    NSDictionary *parameters = @{@"email" : email,
                                 @"password" : password,
                                 @"companyName": companyName,
                                 @"contactName" : contactName,
                                 @"phone" : phone,
                                 @"mobile" : mobile
                                 };
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:@"/ITSupportService/API/Client" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [HUD_ hide:YES];
        NSString *requestResultStatus =[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"RequestResultStatus"]];
        // 1 == success, 0 == fail
        if ([requestResultStatus isEqualToString:@"1"]) {
            
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                message:@"Account Created."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
            NSLog(@"Client account is created");
            [self performSegueWithIdentifier:@"Unwind From SignIn View" sender:self];
            
        }else if ([requestResultStatus isEqualToString:@"0"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!!"
                                                                message:[responseObject valueForKey:@"Message"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [HUD_ hide:YES];
        
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
