//
//  ViewController.m
//  IT Support
//
//  Created by Yin Hua on 12/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "AppDelegate.h"



@interface ViewController ()
{
    AppDelegate *mDelegate_;
    MBProgressHUD *hud_;
}


@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //setting
    mDelegate_ = [[UIApplication sharedApplication] delegate];
    
//    hud_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud_.labelText = @"获取最新频道列表...";
//    [hud_ hide:YES];
    
    
//    [self uploadImage];
    
}

- (IBAction)sendNotification:(id)sender {
    
    [self localNotificationTest];
//    [self performSegueWithIdentifier:@"To Test2 View" sender:self];
    
}


- (void)applicationDidFinishLaunching:(UIApplication *)app {
    // other setup tasks here....
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    const void *devTokenBytes = [devToken bytes];
//    self.registered = YES;
    [self sendProviderDeviceToken:devToken]; // custom method
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}


-(void)sendProviderDeviceToken:(NSData *)devTokenBytes
{
    NSLog(@"%@",devTokenBytes);
}

-(void)localNotificationTest
{
    
//    // New for iOS 8 - Register the notifications
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    
    NSDate *currentDate = [NSDate date];
    //populate localnotification
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    if (localNotification) {
        localNotification.fireDate = [currentDate dateByAddingTimeInterval:5.0];
        localNotification.alertBody = [NSString stringWithFormat:@"Alert Fired at %@", currentDate];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;;
    }
    
    
    
    // 设定通知的userInfo，用来标识该通知
    NSMutableDictionary *aUserInfo = [[NSMutableDictionary alloc] init];
    aUserInfo[@"kLocalNotificationID"] = @"LocalNotificationID";
    localNotification.userInfo = aUserInfo;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}
























-(void)uploadImage
{
    NSLog(@"retrieving data");
//    NSURL *baseURL = [NSURL URLWithString:NewsListURLString];
    
    NSURL *baseURL = [NSURL URLWithString:@""];
    NSDictionary *parameters = @{};
    

    
//    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //http://ec2-52-64-98-132.ap-southeast-2.compute.amazonaws.com/NewsManagement/API/newsinfo
    //request 10 records
    
//    [manager POST:@"/NewsManagement/API/newsinfo" parameters:parameters  success:^(NSURLSessionDataTask *task, id responseObject) {

    [manager POST:@"http://10.0.0.142/ApiTest/api/upload" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
       

        
        
        for (int num = 1; num<3; num++) {
            
            NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"room%d",num]
                                                                 ofType:@"jpg"];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            
            [formData appendPartWithFileURL:fileURL name:@"room3" error:nil];
            
//            [formData appendPartWithFileData:data1
//                                        name:@"image1"
//                                    fileName:@"image1.jpg"
//                                    mimeType:@"image/jpeg"];
        }
        
        
        
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
//        self.tableViewData = [[NSMutableArray alloc]init];
//        self.tableViewData = responseObject;
//        [self.tableView reloadData];
//
        
        
        NSString *message = [responseObject objectForKey:@"message"];
        NSString *status = [responseObject objectForKey:@"status"];
        NSString *name =[responseObject objectForKey:@"name"];
        
        NSLog(@"%@: %@",status, message);
        NSLog(@"Name: %@",name);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud_ hide:YES];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"获取后台文件失败"
                                                            message:error
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
