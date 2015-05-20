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
    MBProgressHUD *hud_;
}

@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *switchUserButton;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;


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
    
    //color
    [self.switchUserButton setTitleColor:mDelegate_.clientThemeColor forState:UIControlStateNormal];
    self.loginButton.backgroundColor = mDelegate_.clientThemeColor;
    
    //setting
    self.mobileTextField.delegate = self;
    self.passwordTextField.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    //add observer for keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}


#pragma mark - login

- (IBAction)loginAction:(id)sender {
    if ([self checkAllField]) {
        //submit and create an account
        
        hud_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud_.labelText = @"登录中...";
        [hud_ hide:YES];
        
        //test
//            [self dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"To RequestList TableView" sender:self];
        
        //        [self userLogin];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please complete all fields"
                                                            message:@"Username & Password required"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
}

- (BOOL)checkAllField
{
    if ([self.mobileTextField.text length]>0  && [self.passwordTextField.text length]>0) {
        return true;
    }else{
        return false;
    }
}


- (IBAction)switchUserAction:(id)sender {
    if ([self.loginButton.titleLabel.text isEqualToString:@"Client Log In"]){
        self.loginButton.backgroundColor = mDelegate_.supportThemeColor;
        [self.switchUserButton setTitleColor:mDelegate_.supportThemeColor forState:UIControlStateNormal];
        [self.loginButton setTitle:@"Support Log In" forState:UIControlStateNormal];
    }else{
        self.loginButton.backgroundColor = mDelegate_.clientThemeColor;
        [self.loginButton setTitle:@"Client Log In" forState:UIControlStateNormal];
        [self.switchUserButton setTitleColor:mDelegate_.clientThemeColor forState:UIControlStateNormal];
    }

//    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) userLogin
{
    //save username and password
    NSLog(@"retrieving data");
    
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    NSString *mobile = self.mobileTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *functionName = @"UserLogin";
    NSDictionary *parameters = @{@"mobile": mobile,
                                 @"password":password,
                                 @"functionName":functionName
                                 };
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //http://admin.netcube.tv/membership.php?
    
    [manager GET:@"/membership.php" parameters:parameters  success:^(NSURLSessionDataTask *task, id responseObject) {
        [hud_ hide:YES];

        NSDictionary *parsedObject = responseObject;
        
        NSString *status = [[NSString alloc]initWithString:[parsedObject objectForKey:@"status"]];
        
        if([status isEqualToString:@"fail"])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Email or Password"
                                                                message:@"Please check your email or password"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }else if ([status isEqualToString:@"success"])
        {
            
            //save user infomation in .plist
            NSString *displayName = [NSString stringWithFormat:@"%@ %@",[parsedObject objectForKey:@"lastname"], [parsedObject objectForKey:@"firstname"]];
            
//            [mDelegate_ setMMobileNumber:self.mobileTextField.text];
//            [mDelegate_ setMPassword:self.passwordTextField.text];
//            [mDelegate_ setMDisplayName:displayName];
//            
//            
//            [[NSUserDefaults standardUserDefaults] setObject:[mDelegate_ mMobileNumber] forKey:@"mMobileNumber"];
//            [[NSUserDefaults standardUserDefaults] setObject:[mDelegate_ mPassword] forKey:@"mPassword"];
//            [[NSUserDefaults standardUserDefaults] setObject:[mDelegate_ mDisplayName] forKey:@"mDisplayName"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //go to main view
//            [mDelegate_ setMGuestModeOn:NO];
//            [self dismissViewControllerAnimated:YES completion:nil];
            [self performSegueWithIdentifier:@"To RequestList TableView" sender:self];
        }
        
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        [hud_ hide:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Loging In"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    
}

#pragma mark - guesture
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - textfield delegate
-(void)keyboardFrameDidChange:(NSNotification *)notification
{
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardEndFrame.size.height;
   
    //keyboard displays 10 poins below login button
    const int distance = 10;
    CGFloat bottomMargin = self.view.frame.size.height - self.loginButton.frame.origin.y - self.loginButton.frame.size.height - distance;

    //whether or not to move the view
    CGFloat animationDistance = keyboardHeight - bottomMargin;
    
    if (animationDistance > 0) {
        
        CGRect newFrame = self.view.frame;
        
        if(keyboardEndFrame.origin.y < self.view.frame.size.height)
        {
            newFrame.origin.y -= animationDistance;
            [self.switchUserButton setHidden:YES];
        }else{
            newFrame.origin.y += animationDistance;
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
}

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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please complete all fields"
                                                            message:@"Username & Password required"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    return NO;
}


#pragma mark - Others

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
