//
//  LoginViewController.m
//  IT Support
//
//  Created by Yin Hua on 19/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "AppHelper.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"


@interface LoginViewController ()
{
    AppDelegate *mDelegate_;
    AppHelper *appHelper_;
    MBProgressHUD *HUD_;
    
    //keyboard animation
    BOOL keyboardISVisible_;
    CGFloat inputViewOriginalY_;
}

//textfield image
@property (weak, nonatomic) IBOutlet UIImageView *usernameImage;
@property (weak, nonatomic) IBOutlet UIImageView *passwordImage;


//textfield
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;


//button
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *switchUserButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;


//background
//@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
//animation
@property (weak, nonatomic) IBOutlet UIView *loginInputView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginInputViewCenterY;


@end



@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appHelper_ = [[AppHelper alloc]init];
    
    [self viewSetting];

    
    //test
//    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
//        self.emailTextField.text = @"";// @"hua.yin@itexpresspro.com.au";
//        self.passwordTextField.text = @"";//@"qwe";
//    }else{
//        self.emailTextField.text = @"william.wu@itexpresspro.com.au";
//        self.passwordTextField.text = @"12345";
//    }
    
    self.emailTextField.text = mDelegate_.userEmail;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    inputViewOriginalY_ = self.loginInputView.frame.origin.y;
}

-(void)viewSetting{
    
    //set TextField PlaceHolder color
    self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], }];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], }];
    
    //set Button color
    [self.switchUserButton setTitleColor:mDelegate_.appThemeColor forState:UIControlStateNormal];
    self.loginButton.backgroundColor = mDelegate_.appThemeColor;
//    [self.signUpButton setTitleColor:mDelegate_.appThemeColor forState:UIControlStateNormal];
//    [self.forgotPasswordButton setTintColor:mDelegate_.appThemeColor];
    [self.usernameImage setTintColor:mDelegate_.appThemeColor];
    [self.passwordImage setTintColor:mDelegate_.appThemeColor];
    
    //setting Button info & user mode
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        [self.loginButton setTitle:clientLogIn forState:UIControlStateNormal];
        [self.signUpButton setHidden:NO];
        [self.switchUserButton setTitle:switchToSupport forState:UIControlStateNormal];
        //        [self.backgroundImageView setImage:[UIImage imageNamed:@"Login_bg_red"]];
        
    }else{
        [self.loginButton setTitle:supportLogIn forState:UIControlStateNormal];
        [self.signUpButton setHidden:YES];
        [self.switchUserButton setTitle:switchToClient forState:UIControlStateNormal];
        //        [self.backgroundImageView setImage:[UIImage imageNamed:@"Login_bg_blue"]];
    }
    
    
    //set guesture & textfield delegate
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    //add observer for keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];

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


#pragma mark - button action
- (IBAction)loginAction:(id)sender {
    if ([self checkAllField]) {

        //loading view
        HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD_.labelText = @"Logging In...";
        [self userLogin];
        
    }else{

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
        [self.signUpButton setHidden:YES];
        [self.switchUserButton setTitle:switchToClient forState:UIControlStateNormal];
        
        mDelegate_.userMode = supportMode;
        [[NSUserDefaults standardUserDefaults] setObject:supportMode
                                                  forKey:@"userMode"];
//        [self.backgroundImageView setImage:[UIImage imageNamed:@"Login_bg_blue"]];
    }else{
        //switch to client theme color
        mDelegate_.appThemeColor = mDelegate_.clientThemeColor;
        [self.loginButton setTitle:clientLogIn forState:UIControlStateNormal];
        [self.signUpButton setHidden:NO];
        [self.switchUserButton setTitle:switchToSupport forState:UIControlStateNormal];
        
        mDelegate_.userMode = clientMode;
        [[NSUserDefaults standardUserDefaults] setObject:clientMode
                                                  forKey:@"userMode"];
//        [self.backgroundImageView setImage:[UIImage imageNamed:@"Login_bg_red"]];
    }
    //set color
    self.loginButton.backgroundColor = mDelegate_.appThemeColor;
    [self.switchUserButton setTitleColor:mDelegate_.appThemeColor forState:UIControlStateNormal];
//    [self.signUpButton setTitleColor:mDelegate_.appThemeColor forState:UIControlStateNormal];
//    [self.forgotPasswordButton setTintColor:mDelegate_.appThemeColor];
    [self.usernameImage setTintColor:mDelegate_.appThemeColor];
    [self.passwordImage setTintColor:mDelegate_.appThemeColor];
    
    self.emailTextField.text = @"";//@"hua.yin@itexpresspro.com.au";
    self.passwordTextField.text = @"";//@"qwe";
    
    //test
//    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
//        self.emailTextField.text = @"";//@"hua.yin@itexpresspro.com.au";
//        self.passwordTextField.text = @"";//@"qwe";
//    }else{
//        self.emailTextField.text = @"william.wu@itexpresspro.com.au";
//        self.passwordTextField.text = @"12345";
//    }
}

- (IBAction)forgotPasswordAction:(id)sender {
    [self performSegueWithIdentifier:@"To ForgotPassword View" sender:self];
}

#pragma mark - user log in
- (void) userLogin
{

    NSLog(@"User Login...");

    //http://ec2-54-79-39-165.ap-southeast-2.compute.amazonaws.com/ITSupportService/api/Login
    
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *userType = userTypeClient;
    NSString *notificationToken = mDelegate_.notificationToken;
    //set user type
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        userType = userTypeClient;
    }else{
        userType = userTypeSupport;
    }

    NSDictionary *parameters = @{@"email": email,
                                 @"password":password,
                                 @"userType":userType,
                                 @"notificationToken" : notificationToken
                                 };
    NSLog(@"\n parameters:\n%@",parameters);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];    
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    [manager.requestSerializer setValue:mDelegate_.userToken forHTTPHeaderField:@"Authorization"];

    [manager POST:@"/ITSupportService/api/Login" parameters:parameters  success:^(NSURLSessionDataTask *task, id responseObject) {
        [HUD_ hide:YES];
        
        NSLog(@"%@",responseObject);
        //convert to NSDictionary
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];

        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"0"]) {
            
            NSDictionary *errorDic = [responseDictionary valueForKey:@"Error"];
            
            NSString *errorMessage =[NSString stringWithFormat:@"%@",[errorDic valueForKey:@"Message"]];
            
            UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"Check your username or password!!"
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
//                Error = "<null>";
//                Result =     {
//                    AccountBalance = 20000;
//                    AvailableFunds = 19335;
//                    CompanyName = "IT Express Pro";
//                    ContactName = newone;
//                    ContactNumber = 333;
//                    Email = "hua.yin@itexpresspro.com.au";
//                    TokenString = "cbaf73ca-202a-4926-8347-ffb8d1d22e72";
//                    UserAccountID = "e5041aa9-53d6-4dff-a7f0-875806d6bbcc";
//                };
//                Status = 1;
//            }


            
            mDelegate_.userDictionary = [responseDictionary valueForKey:@"Result"];
            [[NSUserDefaults standardUserDefaults] setObject:mDelegate_.userDictionary forKey:@"userDictionary"];
            mDelegate_.userToken =[NSString stringWithFormat:@"%@",[mDelegate_.userDictionary valueForKey:@"TokenString"]];
            [[NSUserDefaults standardUserDefaults] setObject:mDelegate_.userToken
                                                      forKey:@"userToken"];
            
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
//            NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:mDelegate_.appThemeColor];
//            [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"appThemeColor"];
//            
            //set default searchType
            mDelegate_.searchType =@"Active";
            

            if (mDelegate_.loginIsRoot) {
           
                mDelegate_.loginIsRoot = NO;
                [appHelper_ initialViewController:@"MainEntryTabBarStoryBoardID"];
//                [self performSegueWithIdentifier:@"To RequestList TableView" sender:self];
            }else{
                [self dismissViewControllerAnimated:YES completion:nil];
//                [self performSegueWithIdentifier:@"Unwind From Login View" sender:self];
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

#pragma mark - textfield animation
-(void)keyboardFrameDidChange:(NSNotification *)notification
{
    
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardEndFrame.size.height;
    
    //keyboard displays 10 poins below login button
    const int distance = 10;
    CGFloat bottomMargin = self.view.frame.size.height - self.loginInputView.frame.origin.y - self.loginInputView.frame.size.height - distance;
    
    //do or do not to move the view
    CGFloat animationDistance = keyboardHeight - bottomMargin;

    //new frame & constrant
    CGRect newFrame = self.loginInputView.frame;

    CGFloat newConstant = self.loginInputViewCenterY.constant;
    
    //move loginInputView
    if (newFrame.origin.y == inputViewOriginalY_ && animationDistance > 0) {
        newFrame.origin.y -= animationDistance;
        newConstant += animationDistance;
    }
    
    //move loginInputView back to Original Position
    if (newFrame.origin.y != inputViewOriginalY_ && self.view.frame.size.height == keyboardEndFrame.origin.y) {
        newFrame.origin.y = inputViewOriginalY_;
        newConstant = 0;
    }
    
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] integerValue];
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear//UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         //have to update both frame and constraint
                         [self.loginInputViewCenterY setConstant: newConstant];
                         self.loginInputView.frame = newFrame;

                     } completion:nil];
}

//-(void)keyboardFrameDidChange2:(NSNotification *)notification
//{
//    
//    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGFloat keyboardHeight = keyboardEndFrame.size.height;
//    
//    //keyboard displays 10 poins below login button
//    const int distance = 10;
//    CGFloat bottomMargin = self.view.frame.size.height - self.loginButton.frame.origin.y - self.loginButton.frame.size.height - distance;
//    
//    //do or do not to move the view
//    CGFloat animationDistance = keyboardHeight - bottomMargin;
//    
//    CGRect newFrame = self.view.frame;
//   
//        if (newFrame.origin.y == 0 && animationDistance > 0) {
//            newFrame.origin.y -= animationDistance;
////            [self.switchUserButton setHidden:YES];
//        }
//        
//        if (newFrame.origin.y < 0 && newFrame.size.height == keyboardEndFrame.origin.y) {
//            newFrame.origin.y = 0;
////            [self.switchUserButton setHidden:NO];
//        }
//        
//        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] integerValue];
//        
//        [UIView animateWithDuration:animationDuration
//                              delay:0
//                            options:UIViewAnimationOptionCurveLinear//UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
//                             self.view.frame = newFrame;
//                         } completion:nil];
//}

#pragma mark - textfield delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.switchUserButton setHidden:YES];
    [self.forgotPasswordButton setHidden:YES];
    [self.signUpButton setHidden:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    [self.switchUserButton setHidden:NO];
    [self.forgotPasswordButton setHidden:NO];
    [self.signUpButton setHidden:NO];
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
