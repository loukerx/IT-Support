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

@interface ViewController ()<UIScrollViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate>
{
    AppDelegate *mDelegate_;
    MBProgressHUD *HUD_;
    NSArray *pickerData_;
}

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIScrollView *scrollView;

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
    
//        [self prepareScrollViewContent];

//    [self restfulConfirmTest];

    [self performSegueWithIdentifier:@"To Test2 View" sender:self];
    
}

#pragma mark - scrollView content

- (void)prepareScrollViewContent
{
    CGFloat scrollViewHeight_ = self.view.frame.size.width * cellHeightRatio;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, scrollViewHeight_)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    
    
    [self.view addSubview:self.scrollView];
//    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollviewSingleTapGesture:)];
//    [self.scrollView addGestureRecognizer:singleTapGestureRecognizer];
    
    //test image data
//    for (int num=1;num<6; num++) {
//        [mDelegate_.mRequestImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"image%d.jpg",num]]];
//
//        [mDelegate_.mRequestImageDescriptions addObject:@"For additional question, please leave your message."];
//    }
    
    NSArray *photos = [NSArray arrayWithArray: mDelegate_.mRequestImages];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    self.scrollView.contentSize =  CGSizeMake(width * photos.count,0);
    
    int count = 0;
    
    for(UIImage *image in photos)
    {
        UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
        imageview.contentMode = UIViewContentModeScaleAspectFit;
        imageview.frame = CGRectMake(0, 0, width, height);
        
        UIScrollView *pageScrollView = [[UIScrollView alloc]
                                        initWithFrame:CGRectMake(width * count, 0, width, height)];
        pageScrollView.minimumZoomScale = 1.0f;
        pageScrollView.maximumZoomScale = 2.5f;
        //scrollView.contentSize = CGSizeMake(scrollView.contentSize.width,scrollView.frame.size.height);
        //        pageScrollView.contentSize = CGSizeMake(imageview.frame.size.width, pageScrollView.frame.size.height);
        pageScrollView.contentSize = CGSizeMake(width,height);
        //        pageScrollView.scrollEnabled = NO;
        pageScrollView.decelerationRate = 1.0f;
        pageScrollView.delegate = self;
        [pageScrollView addSubview:imageview];
        
        [self.scrollView addSubview:pageScrollView];
        count++;
    }
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




#pragma mark - PUT restful method test

-(void)restfulConfirmTest
{
    
    NSURL *baseURL =[NSURL URLWithString:@"http://52.64.43.116"];// [NSURL URLWithString:AWSLinkURL];
    
    NSString *URLString = @"/test/api/test";
    NSDictionary *parameters =@{@"testString" : @"adsdf"};;

    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:mDelegate_.userEmail password:mDelegate_.userToken];
    
    
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





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
