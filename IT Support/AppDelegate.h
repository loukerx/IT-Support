//
//  AppDelegate.h
//  IT Support
//
//  Created by Yin Hua on 12/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


static NSString *const AWSLinkURL = @"http://54.153.139.38";//version 0.1

static float const cellHeightRatio = 0.625f;

#define clientMode @"Client Mode"
#define supportMode @"Support Mode"

#define clientLogIn @"Client Log In"
#define supportLogIn @"Support Log In"

#define userTypeClient @"0"
#define userTypeSupport @"1"

#define invalidTokenMessage @"Login session out of date, please log in again."

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//version
@property (strong, nonatomic) NSString *appVersion;

//user
@property (strong, nonatomic) NSString *notificationToken;
@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSString *userToken;
@property (strong, nonatomic) NSDictionary *userDictionary;
@property (strong, nonatomic) NSString *userEmail;//username
@property (strong, nonatomic) NSString *userPassword;//password
//@property (strong, nonatomic) NSString *contactName;
//login view is root
//@property (nonatomic)BOOL loginIsRoot;

//client user
@property (strong, nonatomic) NSString *clientID;
//support user
@property (strong, nonatomic) NSString *supportID;

//search
@property (strong, nonatomic) NSString *searchType;

//setting request variables
@property (strong, nonatomic) NSString *requestCategoryID;
//@property (strong, nonatomic) NSString *requestSubject;
//@property (strong, nonatomic) NSString *requestDescription;

//category list
@property (strong, nonatomic) NSMutableArray *categoryListArray;
@property (strong, nonatomic) NSMutableArray *subcategoryListArray;
@property (strong, nonatomic) NSMutableDictionary *subcategoryListDictionary;//ordered by 5 Key categories.
@property (strong, nonatomic) NSString *requestCategory;
@property (strong, nonatomic) NSString *requestSubCategory;



//photos data
@property (strong, nonatomic) NSMutableArray *mRequestImages;
@property (strong, nonatomic) NSMutableArray *mRequestImagesURL;
@property (strong, nonatomic) NSMutableArray *mRequestImageDescriptions;

//color
//-(UIColor*)colorWithHexString:(NSString*)hex;
@property (strong, nonatomic) UIColor *clientThemeColor;
@property (strong, nonatomic) UIColor *supportThemeColor;
@property (strong, nonatomic) UIColor *appThemeColor;
@property (strong, nonatomic) UIColor *textFieldColor;
@property (strong, nonatomic) UIColor *textViewBoardColor;
@property (strong, nonatomic) UIColor *menuTextColor;
@property (strong, nonatomic) UIColor *footerTextColor;

//font
@property (strong, nonatomic) UIFont *menuTextFont;



@end

