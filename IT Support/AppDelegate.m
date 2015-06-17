//
//  AppDelegate.m
//  IT Support
//
//  Created by Yin Hua on 12/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "AppHelper.h"
#import "AFNetworking.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface AppDelegate ()
{
    AppHelper *appHelper_;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //instant AppHelper
    appHelper_ = [[AppHelper alloc]init];
    
    // New for iOS 8 - Register the notifications
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    [application registerForRemoteNotifications];
    
    //MainBundle version
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    self.appVersion = [NSString stringWithFormat:@"Version %@.%@",majorVersion,minorVersion];
    
    
    //setting user
    self.userToken = @"";
    self.userEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"]?:@"";
    self.userPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPassword"]?:@"";
    
    //login view is root
    self.loginIsRoot = YES;
    
    //setting client
    //test number
    self.clientID = @"0";
    self.supportID = @"0";
    
    //setting categorylists
    self.categoryListArray = [[NSMutableArray alloc]init];
    self.subcategoryListDictionary = [[NSMutableDictionary alloc]init];
    
    
    //search
    self.searchType = @"Active";
    
    //setting request
    self.requestCategory = @"";
    self.requestSubCategory = @"";
    self.requestSubject = @"N/A";
    self.requestDescription = @"N/A";

    
    self.mRequestImages = [[NSMutableArray alloc]init];
    self.mRequestImagesURL = [[NSMutableArray alloc]init];
    self.mRequestImageDescriptions = [[NSMutableArray alloc]init];
    
    
    //setting color
    self.clientThemeColor = [appHelper_ colorWithHexString:@"FF3B30"];
    self.supportThemeColor = [appHelper_ colorWithHexString:@"1D77EF"];
    
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"appThemeColor"]?:nil;
    UIColor *appThemeColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    self.appThemeColor = appThemeColor?:self.clientThemeColor;
    self.textFieldColor = [appHelper_ colorWithHexString:@"F7F7F7"];
    self.textViewBoardColor = [UIColor colorWithRed:215.0 / 255.0 green:215.0 / 255.0 blue:215.0 / 255.0 alpha:1];
    self.menuTextColor =  [appHelper_ colorWithHexString:@"3E444B"]; //[UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f]; //3E444B
    self.footerTextColor = [UIColor colorWithRed:0.298 green:0.337 blue:0.423 alpha:1.000];
    
    //setting font
    self.menuTextFont = [UIFont fontWithName:@"HiraKakuProN-W3" size:20.0];//[UIFont fontWithName:@"HelveticaNeue" size:20.0];
    
    
    
    
    //Auto Login check username & password
    //initialise a view controller
    if (self.userEmail.length>0 && self.userPassword.length >0) {
        
//        [self initialViewController:@"TabMainStoryboard"];
//        //check user mobile and password
        [self userLogin];
        
    }else{
        [self initialViewController:@"LoginViewStoryboardID"];
    }

//    
//    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
//    if (localNotification) {
//        application.applicationIconBadgeNumber = 0;
//    }
    

    
//    return YES;
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

#pragma initial and login check
-(void)initialViewController:(NSString *)viewControllerIdentifier
{
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:viewControllerIdentifier];
    
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
}

- (void) userLogin
{
    
    NSLog(@"User Login...");
    
    //http://ec2-54-79-39-165.ap-southeast-2.compute.amazonaws.com/ITSupportService/api/Login
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    NSString *email = self.userEmail;
    NSString *password = self.userPassword;
    NSString *userType = userTypeClient;
    //set user type
    if ([self.appThemeColor isEqual:self.clientThemeColor]) {
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
        
        //convert to NSDictionary
        NSDictionary *responseDictionary = responseObject;
        NSString *requestResultStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"RequestResultStatus"]];
        
        // 1 == success, 0 == fail
        if ([requestResultStatus isEqualToString:@"0"]) {
            
            NSLog(@"fail");
            //To Login View
            [self initialViewController:@"LoginViewStoryboardID"];
            
        }else if ([requestResultStatus isEqualToString:@"1"]) {
            
            NSLog(@"success");
            self.userToken = [NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Token"]];
            self.userDictionary = [responseDictionary valueForKey:@"User"];
            
            //user mode
            if ([self.appThemeColor isEqual:self.clientThemeColor]) {
                self.clientID = [NSString stringWithFormat:@"%@",[self.userDictionary valueForKey:@"ClientID"]];
            }else{
                self.supportID = [NSString stringWithFormat:@"%@",[self.userDictionary valueForKey:@"SupportID"]];
            }
            //To RequestList TableView
            self.loginIsRoot = NO;
            [self initialViewController:@"MainRequestListStoryboardID"];
            
            //test
//            [self initialViewController:@"TestStoryboardView"];
        }
    }failure:^(NSURLSessionDataTask *task, NSError *error) {

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Loging In"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
}

#pragma mark - Notification

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"Application did receive local notifications");
    
    // 取消某个特定的本地通知
    // ----功能不清楚-----
    for (UILocalNotification *noti in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        NSString *notiID = noti.userInfo[@"kLocalNotificationID"];
        NSString *receiveNotiID = notification.userInfo[@"kLocalNotificationID"];
        if ([notiID isEqualToString:receiveNotiID]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            return;
        }
    }
    
    // alert 提醒
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"welcome" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


#pragma mark - remote notification deviceToken
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}


#pragma mark - facebook
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

#pragma mark - application status
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    //icon badge 设为0
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"clear icon badge Number");
    application.applicationIconBadgeNumber = 0;
    
    //facebook
     [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "au.com.itexpresspro.IT_Support" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"IT_Support" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"IT_Support.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
