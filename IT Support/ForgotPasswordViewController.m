//
//  ForgotPasswordViewController.m
//  IT Support
//
//  Created by Yin Hua on 25/06/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface ForgotPasswordViewController ()
{
    AppDelegate *mDelegate_;
    MBProgressHUD *HUD_;
}

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;


@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.navigationController.navigationBar.tintColor = mDelegate_.appThemeColor;
    [self.submitButton setBackgroundColor:mDelegate_.appThemeColor];
}


#pragma mark - Button Action
- (IBAction)cancelAction:(id)sender {
    
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submitAction:(id)sender {
  
    if ([self.emailTextField.text length]>0) {
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
             //submit and create an account
             [self sendNewPassword];
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
    }else {
        UIAlertController* alert =
        [UIAlertController alertControllerWithTitle:@"Error!!"
                                            message:@"Please Enter Your Email."
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction =
        [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {}];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - update password
-(void)sendNewPassword{
    
    HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD_.labelText = @"Processing...";
    
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    NSString *email = self.emailTextField.text;

    
    NSString *URLString;
    NSDictionary *parameters;
    
    URLString =[NSString stringWithFormat:@"/ITSupportService/API/Login"];
    parameters = @{@"email" : email
                   };
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:mDelegate_.userEmail password:mDelegate_.userToken];
    
    [manager GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [HUD_ hide:YES];
        NSLog(@"%@",responseObject);
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];
        
        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"1"]) {
            
            UIAlertController* alert =
            [UIAlertController alertControllerWithTitle:@"Success"
                                                message:@"New password has been sent to your email."
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction =
            [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
             {
                 NSLog(@"NEW password has been sent");
                 [self.view endEditing:YES];
                 [self dismissViewControllerAnimated:YES completion:nil];
             }];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }else if ([responseStatus isEqualToString:@"0"]) {
            NSString *errorMessage =[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"Message"]];
            
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
        [UIAlertController alertControllerWithTitle:@"Server Error"
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
