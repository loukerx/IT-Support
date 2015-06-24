//
//  LoginViewController.m
//  ez4rent
//
//  Created by Yin Hua on 2/02/2015.
//  Copyright (c) 2015 Yin Hua. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"


@interface LoginViewController ()
{
    AppDelegate *mDelegate_;
    MBProgressHUD *HUD_;
    
    //keyboard animation
    BOOL keyboardISVisible_;
}

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *switchUserButton;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end



@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    //logo
    CGFloat width = self.view.frame.size.width*0.5;
    CGFloat height = width*0.435;
    CGFloat x = self.view.frame.size.width*0.25;
    CGFloat y = self.view.frame.size.height*0.25 - height*0.25;
    CGRect newFrame = CGRectMake(x, y, width, height);
    [self.iconImageView setFrame:newFrame];
    [self.iconImageView layoutIfNeeded];
    
    //setting color & loginButton info & user mode
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        [self.loginButton setTitle:clientLogIn forState:UIControlStateNormal];
        [self.signInButton setHidden:NO];
        
    }else{
        [self.loginButton setTitle:supportLogIn forState:UIControlStateNormal];
        [self.signInButton setHidden:YES];
    }
    [self.switchUserButton setTitleColor:mDelegate_.appThemeColor forState:UIControlStateNormal];
    self.loginButton.backgroundColor = mDelegate_.appThemeColor;
    [self.signInButton setTitleColor:mDelegate_.appThemeColor forState:UIControlStateNormal];
    
    //setting guesture & textfield delegate
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    //add observer for keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
//    [self.passwordTextField setSecureTextEntry:YES];
    
    //test
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        self.emailTextField.text = @"hua.yin@itexpresspro.com.au";
        self.passwordTextField.text = @"qwe";
    }else{
        self.emailTextField.text = @"william.wu@itexpresspro.com.au";
        self.passwordTextField.text = @"12345";
    }

}


#pragma mark - mandatory field check

- (BOOL)checkAllField
{
    if ([self.emailTextField.text length]>0  && [self.passwordTextField.text length]>0) {
        return true;
    }else{
        return false;
    }
}


#pragma mark - login

- (IBAction)loginAction:(id)sender {
    if ([self checkAllField]) {
        
        //submit and create an account
        HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD_.labelText = @"Logging In...";
        [self userLogin];
        
    }else{
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please complete all fields"
//                                                            message:@"Username & Password required"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"Ok"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Please complete all fields"
                                                                       message:@"Username & Password required"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}



- (IBAction)switchUserAction:(id)sender {
    
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        //switch to support theme color
        mDelegate_.appThemeColor = mDelegate_.supportThemeColor;
        [self.loginButton setTitle:supportLogIn forState:UIControlStateNormal];
        [self.signInButton setHidden:YES];
        
    }else{
        //switch to client theme color
        mDelegate_.appThemeColor = mDelegate_.clientThemeColor;
        [self.loginButton setTitle:clientLogIn forState:UIControlStateNormal];
        [self.signInButton setHidden:NO];
    }
    
    self.loginButton.backgroundColor = mDelegate_.appThemeColor;
    [self.switchUserButton setTitleColor:mDelegate_.appThemeColor forState:UIControlStateNormal];
    [self.signInButton setTitleColor:mDelegate_.appThemeColor forState:UIControlStateNormal];
    
    
    //test
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        self.emailTextField.text = @"hua.yin@itexpresspro.com.au";
        self.passwordTextField.text = @"qwe";
    }else{
        self.emailTextField.text = @"william.wu@itexpresspro.com.au";
        self.passwordTextField.text = @"12345";
    }
}


- (void) userLogin
{

    NSLog(@"User Login...");

    //http://ec2-54-79-39-165.ap-southeast-2.compute.amazonaws.com/ITSupportService/api/Login
    
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *userType = userTypeClient;
    //set user type
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        userType = userTypeClient;
    }else{
        userType = userTypeSupport;
    }

    NSDictionary *parameters = @{@"email": email,
                                 @"password":password,
                                 @"userType":userType
                                 };
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:@"/ITSupportService/api/Login" parameters:parameters  success:^(NSURLSessionDataTask *task, id responseObject) {
        [HUD_ hide:YES];
        
        NSLog(@"%@",responseObject);
        //convert to NSDictionary
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];

        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"0"]) {
            
            NSString *errorMessage =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Message"]];
            
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
        
        }else if ([responseStatus isEqualToString:@"1"]) {

            //return values
//            {
//                Message = "";
//                Result =     {
//                    AccountBalance = 100;
//                    AvailableFunds = 100;
//                    ContactName = "Benson Shi";
//                    Email = "hua.yin@itexpresspro.com.au";
//                    TokenString = "d6427b42-74c2-4df8-bcd8-cac0d342b1a6";
//                    UserAccountID = "e5041aa9-53d6-4dff-a7f0-875806d6bbcc";
//                };
//                Status = 1;
//            }


            
            mDelegate_.userDictionary = [responseDictionary valueForKey:@"Result"];

            //user mode
            if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
                mDelegate_.clientID = [NSString stringWithFormat:@"%@",[mDelegate_.userDictionary valueForKey:@"UserAccountID"]];
            }else{
                mDelegate_.supportID = [NSString stringWithFormat:@"%@",[mDelegate_.userDictionary valueForKey:@"UserAccountID"]];
            }

            //NSUserDefaults local variables
            mDelegate_.userEmail = self.emailTextField.text;
            mDelegate_.userPassword = self.passwordTextField.text;
            [[NSUserDefaults standardUserDefaults] setObject:self.emailTextField.text
                                                      forKey:@"userEmail"];
            [[NSUserDefaults standardUserDefaults] setObject:self.passwordTextField.text
                                                      forKey:@"userPassword"];
            
            //save uicolor
            NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:mDelegate_.appThemeColor];
            [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"appThemeColor"];
            
            //set default searchType
            mDelegate_.searchType =@"Active";
            if (mDelegate_.loginIsRoot) {
                
                [self performSegueWithIdentifier:@"To RequestList TableView" sender:self];
            }else{
                
                [self performSegueWithIdentifier:@"Unwind From Login View" sender:self];
            }

        }
        
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        [HUD_ hide:YES];
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Error Log In"
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

#pragma mark - guesture
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - notification textfield animation
-(void)keyboardFrameDidChange:(NSNotification *)notification
{
    
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardEndFrame.size.height;
    
    //keyboard displays 10 poins below login button
    const int distance = 10;
    CGFloat bottomMargin = self.view.frame.size.height - self.loginButton.frame.origin.y - self.loginButton.frame.size.height - distance;
    
    //whether or not to move the view
    CGFloat animationDistance = keyboardHeight - bottomMargin;
    
    CGRect newFrame = self.view.frame;
   
        if (newFrame.origin.y == 0 && animationDistance > 0) {
            newFrame.origin.y -= animationDistance;
            [self.switchUserButton setHidden:YES];
        }
        
        if (newFrame.origin.y < 0 && newFrame.size.height == keyboardEndFrame.origin.y) {
            newFrame.origin.y = 0;
            [self.switchUserButton setHidden:NO];
        }
        
        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] integerValue];
        
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.view.frame = newFrame;
                         } completion:nil];
}

#pragma mark - textfield delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
        [self.switchUserButton setHidden:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
        [self.switchUserButton setHidden:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self checkAllField]) {
        //submit and create an account
        [self userLogin];
    }else{
        UIAlertController* alert =
        [UIAlertController alertControllerWithTitle:@"Please complete all fields"
                                            message:@"Username & Password required"
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction =
        [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {}];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    return NO;
}

#pragma mark - Others

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - unwind segue
-(IBAction)unwindToLogin:(UIStoryboardSegue *)segue {

    if ([segue.identifier isEqualToString:@"Unwind From SignIn View"] )
    {
        NSLog(@"Unwind From SignIn View.");

    }
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
