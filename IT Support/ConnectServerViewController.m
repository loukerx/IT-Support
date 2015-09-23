//
//  ConnectServerViewController.m
//  IT Support
//
//  Created by Yin Hua on 26/06/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "ConnectServerViewController.h"
#import "AppDelegate.h"
#import "AppHelper.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "UIProgressView+AFNetworking.h"

@interface ConnectServerViewController ()
{
    AppDelegate *mDelegate_;
    AppHelper *appHelper_;
    MBProgressHUD *HUD_;
}

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@end

@implementation ConnectServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appHelper_ = [[AppHelper alloc]init];
    
    HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD_.labelText = @"Connecting Server...";

    
    //test
//    [appHelper_ initialViewController:@"TestNavigationControllerID"];
//    [appHelper_ initialViewController:@"UpdatePagesViewStoryboardID"];
    
    //initialise a view controller
    if (mDelegate_.userEmail.length>0 && mDelegate_.userPassword.length >0) {
        
        [self initialProgressView];
        [self userLogin];
        
    }else{

        //[appHelper_ initialViewController:@"LoginViewStoryboardID"];
    }
}

- (void)setupTimerWithTimer{
   [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                    target:self
                                                  selector:@selector(updateTimer)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void)updateTimer{
    //预计6秒左右
    if (self.progressView.progress <0.98) {
        float newProgress = [self.progressView progress] + 0.014;
        [self.progressView setProgress:newProgress animated:YES];
    }
}

#pragma mark - initial progress view
-(void)initialProgressView
{
    self.progressView.progressTintColor = mDelegate_.clientThemeColor;
    self.progressView.trackTintColor = [UIColor whiteColor];
    self.progressView.progress = 0.0f;

}


#pragma mark - initial and login check
-(void)initialViewController:(NSString *)viewControllerIdentifier
{
    mDelegate_.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:viewControllerIdentifier];
    
    mDelegate_.window.rootViewController = viewController;
    [mDelegate_.window makeKeyAndVisible];
}

#pragma mark - User Login
- (void) userLogin
{
    [self setupTimerWithTimer];
    NSLog(@"User Login...");
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    NSString *email = mDelegate_.userEmail;
    NSString *password = mDelegate_.userPassword;
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
// manager.requestSerializer = [AFJSONRequestSerializer serializer];   
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    [manager.requestSerializer setValue:mDelegate_.userToken forHTTPHeaderField:@"Authorization"];

    [manager POST:@"/ITSupportService/api/Login" parameters:parameters  success:^(NSURLSessionDataTask *task, id responseObject) {
    
        
        [HUD_ hide:YES];
        //convert to NSDictionary
        NSLog(@"\nLog in response\n%@",responseObject);
        
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];
        
        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"0"]) {

            NSLog(@"fail");
            //To Login View
            //[appHelper_ initialViewController:@"LoginViewStoryboardID"];
            
        }else if ([responseStatus isEqualToString:@"1"]) {
            
            NSLog(@"success");
            
            mDelegate_.userDictionary = [responseDictionary valueForKey:@"Result"];
            mDelegate_.userToken =[NSString stringWithFormat:@"%@",[mDelegate_.userDictionary valueForKey:@"TokenString"]];
            [[NSUserDefaults standardUserDefaults] setObject:mDelegate_.userToken
                                                      forKey:@"userToken"];
            //user mode
            if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
                mDelegate_.clientID = [NSString stringWithFormat:@"%@",[mDelegate_.userDictionary valueForKey:@"UserAccountID"]];
            }else{
                mDelegate_.supportID = [NSString stringWithFormat:@"%@",[mDelegate_.userDictionary valueForKey:@"UserAccountID"]];
            }
            //To RequestList TableView
//            mDelegate_.loginIsRoot = NO;
            [appHelper_ initialViewController:@"MainRequestListStoryboardID"];
            
        }
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [HUD_ hide:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Loging In"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        //To Login View
        //[appHelper_ initialViewController:@"LoginViewStoryboardID"];
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
