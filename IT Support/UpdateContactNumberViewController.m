//
//  UpdateContactNumberViewController.m
//  IT Support
//
//  Created by Yin Hua on 25/06/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "UpdateContactNumberViewController.h"
#import "AppDelegate.h"
#import "AppHelper.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface UpdateContactNumberViewController ()
{
    AppDelegate *mDelegate_;
    AppHelper *appHelper_;
    MBProgressHUD *HUD_;
}
@property (weak, nonatomic) IBOutlet UITextField *contactNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmContactNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation UpdateContactNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.submitButton setBackgroundColor:mDelegate_.appThemeColor];
}

#pragma mark - mandatory field check
- (BOOL)checkAllField
{
    //check password
    if ([self.contactNumberTextField.text isEqualToString:self.confirmContactNumberTextField.text]) {
        //check all textfield
        if ([self.contactNumberTextField.text length]>0 && [self.confirmContactNumberTextField.text length]>0) {
            
            return true;
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
    }else{
        UIAlertController* alert =
        [UIAlertController alertControllerWithTitle:@"Contact Number Error"
                                            message:@"Please Confirm Your Contact Number."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction =
        [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {}];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
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
             //submit and create an account
             [self updateContactNumber];
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

#pragma mark - update password
-(void)updateContactNumber{
    
    HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD_.labelText = @"Processing...";
    
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    NSString *contactNumber = self.contactNumberTextField.text;
    
    NSString *URLString;
    NSDictionary *parameters;
    //User Mode
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        NSString *clientID = mDelegate_.clientID;
        URLString =[NSString stringWithFormat:@"/ITSupportService/API/ClientUpdate"];
        parameters = @{@"clientID" : clientID,
                       @"contactNumber" : contactNumber
                       };
        
    }else{
        NSString *supportID = mDelegate_.supportID;
        URLString =[NSString stringWithFormat:@"/ITSupportService/API/SupportUpdate"];
        parameters = @{@"supportID" : supportID,
                       @"contactNumber" : contactNumber
                       };
    }
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:mDelegate_.userEmail password:mDelegate_.userToken];
    
    [manager POST:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"%@",responseObject);
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];
        
        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"1"]) {
            
            UIAlertController* alert =
            [UIAlertController alertControllerWithTitle:@"Success"
                                                message:@"Contact Number Updated."
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction =
            [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
             {
                 NSLog(@"User contact number has been updated");
                 [self retrieveUserInfo];
             }];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }else if ([responseStatus isEqualToString:@"0"]) {
            
            [HUD_ hide:YES];
            
            NSDictionary *errorDic = [responseDictionary valueForKey:@"Error"];
            
            NSString *errorMessage =[NSString stringWithFormat:@"%@",[errorDic valueForKey:@"Message"]];
            NSString *errorCode =[NSString stringWithFormat:@"%@",[errorDic valueForKey:@"Code"]];
            
            
            if ([errorCode isEqualToString:@"1002"]) {
                //log out
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Process Error"
                                                                    message:invalidTokenMessage
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
                [appHelper_ initialViewController:@"LoginViewStoryboardID"];
            }else{
               
                
  
            
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

-(void)retrieveUserInfo{
    
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    NSString *URLString;
    NSDictionary *parameters;
    
    //Client Mode
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        NSString *clientID = mDelegate_.clientID;
        URLString =[NSString stringWithFormat:@"/ITSupportService/API/Client"];
        parameters = @{@"clientID" : clientID
                       };
        
    }else{//Support Mode
        NSString *supportID = mDelegate_.supportID;
        URLString =[NSString stringWithFormat:@"/ITSupportService/API/Support"];
        parameters = @{@"supportID" : supportID
                       };
    }
    
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
        
            mDelegate_.userDictionary = [responseDictionary valueForKey:@"Result"];
            [self.navigationController popViewControllerAnimated:YES];
            
        }else if ([responseStatus isEqualToString:@"0"]) {
            NSDictionary *errorDic = [responseDictionary valueForKey:@"Error"];
            
            NSString *errorMessage =[NSString stringWithFormat:@"%@",[errorDic valueForKey:@"Message"]];
               NSString *errorCode =[NSString stringWithFormat:@"%@",[errorDic valueForKey:@"Code"]];
            
            
            if ([errorCode isEqualToString:@"1002"]) {
                //log out
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Process Error"
                                                                    message:invalidTokenMessage
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
                [appHelper_ initialViewController:@"LoginViewStoryboardID"];
            }else{
            
            UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"Update User Info Error!!"
                                                message:errorMessage
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction =
            [UIAlertAction actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       [self.navigationController popViewControllerAnimated:YES];
                                   }];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [HUD_ hide:YES];
        
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Update User Info Error!!"
                                            message:[error localizedDescription]
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   [self.navigationController popViewControllerAnimated:YES];
                               }];
        
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
