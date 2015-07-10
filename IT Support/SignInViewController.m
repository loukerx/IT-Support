//
//  SignInViewController.m
//  IT Support
//
//  Created by Yin Hua on 20/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "SignInViewController.h"
#import "AppDelegate.h"
#import "AppHelper.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface SignInViewController ()<UIActionSheetDelegate>
{
    AppDelegate *mDelegate_;
    AppHelper *appHelper_;
    MBProgressHUD *HUD_;
}


@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;


@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appHelper_ = [[AppHelper alloc]init];
    
    [self.submitButton setBackgroundColor:mDelegate_.appThemeColor];

    //setting color
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:mDelegate_.appThemeColor];
}

#pragma mark - mandatory field check
- (BOOL)checkAllField
{
    NSString *errorTitle =@"";
    NSString *errorMessage =@"";
    
    //check password
    if ([self.passwordTextField.text isEqualToString:self.passwordConfirmTextField.text]) {
        //check all textfield
        if ([self.emailAddressTextField.text length]>0 &&[self.passwordTextField.text length]>0 && [self.passwordConfirmTextField.text length]>0) {
            if ([appHelper_ checkNSStringIsValidEmail:self.emailAddressTextField.text]) {
            
                return true;
            }else{
                errorTitle = @"Invalid Email!";
                errorMessage = @"Please Input A Valid Email Address.";
            }
        }else{
            errorTitle = @"Error!";
            errorMessage = @"Please Fill All Blank.";
        }
    }else{
        errorTitle = @"Password Error";
        errorMessage = @"Please Confirm Your Password.";

    }
    UIAlertController* alert =
    [UIAlertController alertControllerWithTitle:errorTitle
                                        message:errorMessage
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction =
    [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {}];
    
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    return false;
}

#pragma mark - Button Action
- (IBAction)submitAction:(id)sender {

    BOOL checkField = [self checkAllField];
    
    if (checkField) {
        UIAlertController* alertController =
        [UIAlertController alertControllerWithTitle:nil
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* cancelAction =
        [UIAlertAction actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * action) {}];
        UIAlertAction* submitAction =
        [UIAlertAction actionWithTitle:@"Submit"
                                 style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction * action)
         {
             HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
             HUD_.labelText = @"Processing...";
             //submit and create an account
             [self createClientAccount];
         }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:submitAction];
        
        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
        if (popover)
        {
            UIButton *button = (UIButton *)sender;
            popover.sourceView = button;
            popover.sourceRect = button.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - create client account
-(void)createClientAccount{
    
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];

    NSString *email = self.emailAddressTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *companyName = self.companyName;
    NSString *contactName = self.contactName;
    NSString *contactNumber = self.contactNumber;
//    NSString *phone = self.companyPhoneTextField.text;
//    NSString *mobile = self.mobileNumberTextField.text;
    
    NSDictionary *parameters = @{@"email" : email,
                                 @"password" : password,
                                 @"companyName": companyName,
                                 @"contactName" : contactName,
                                 @"contactNumber" : contactNumber
                                 };
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:mDelegate_.userEmail password:mDelegate_.userToken];
    
    [manager POST:@"/ITSupportService/API/Client" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [HUD_ hide:YES];
        NSLog(@"%@",responseObject);
        //convert to NSDictionary
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];
        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"1"]) {
            
            UIAlertController* alert =
            [UIAlertController alertControllerWithTitle:@"Success"
                                                message:@"Account Created."
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction =
            [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
             {
                 NSLog(@"Client account is created");
                 [self performSegueWithIdentifier:@"Unwind From SignIn View" sender:self];
                 
             }];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }else if ([responseStatus isEqualToString:@"0"]) {
            NSDictionary *errorDic = [responseDictionary valueForKey:@"Error"];
            
            NSString *errorMessage =[NSString stringWithFormat:@"%@",[errorDic valueForKey:@"Message"]];
            
            UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"Error!!"
                                                message:errorMessage
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction =
            [UIAlertAction actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {}];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];

        }        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [HUD_ hide:YES];
        
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Error Creating Client Account"
                                            message:[error localizedDescription]
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {}];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
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
