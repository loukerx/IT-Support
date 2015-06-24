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
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface ViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    AppDelegate *mDelegate_;
    MBProgressHUD *HUD_;
    NSArray *pickerData_;
}

@property (strong, nonatomic) UIPickerView *pickerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //setting
    mDelegate_ = [[UIApplication sharedApplication] delegate];
    //    [self uploadImage];
    
//    HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    HUD_.labelText = @"获取最新频道列表...";
//    [HUD_ hide:YES];
    
    pickerData_ = @[@"Item 1", @"Item 2", @"Item 3", @"Item 4", @"Item 5", @"Item 6"];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    

}



- (IBAction)sendNotification:(id)sender {
    
    

//    [self actionSheetExample:sender];
//    [self restfulConfirmTest];
//    [self localNotificationTest];
//    [self performSegueWithIdentifier:@"To Test2 View" sender:self];
    
}


-(void)actionSheetPickerView
{
    
}
#pragma mark -  Picker View DataSource

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return pickerData_.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return pickerData_[row];
}

#pragma mark - Picker View Delegate
// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    
    NSLog(@"click the pickerView");
}

#pragma mark - UIAlertController example display ActionSheet example

-(void)actionSheetExample:(id)sender
{
    
    NSString *alertTitle = NSLocalizedString(@"ActionTitle", @"Archive or Delete Data");
    NSString *alertMessage = NSLocalizedString(@"ActionMessage", @"Deleted data cannot be undone");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:alertMessage
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"Delete action")
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Delete action");
                                   }];
    
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Archive", @"Archive action")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action)
                                    {
                                        NSLog(@"Archive action");
                                    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    [alertController addAction:archiveAction];
    
    
    
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



#pragma mark - PUT restful method test

-(void)restfulConfirmTest
{
    
    NSURL *baseURL =[NSURL URLWithString:@"http://52.64.43.116"];// [NSURL URLWithString:AWSLinkURL];
    
    NSString *URLString = @"/test/api/test";
    NSDictionary *parameters =@{@"testString" : @"adsdf"};;

    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    
//    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    [manager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        NSLog(@"%@",responseObject);


    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Creating Request"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
}


#pragma mark - local notification test

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

#pragma mark - upload image to server
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
        [HUD_ hide:YES];
        
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
