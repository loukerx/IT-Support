//
//  AppDelegate.h
//  IT Support
//
//  Created by Yin Hua on 12/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>



static NSString *const AWSLinkURL = @"http://admin.netcube.tv";
static float const cellHeightRatio = 0.625f;



@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;



//setting local variables
@property (strong, nonatomic) NSString *requestCategory;
@property (strong, nonatomic) NSString *requestSubCategory;
@property (strong, nonatomic) NSString *requestSubject;
@property (strong, nonatomic) NSString *requestDescription;



//photo data
@property (strong, nonatomic) NSMutableArray *mRequestImages;
@property (strong, nonatomic) NSMutableArray *mRequestImageDescriptions;

//color
-(UIColor*)colorWithHexString:(NSString*)hex;
@property (strong, nonatomic) UIColor *clientThemeColor;
@property (strong, nonatomic) UIColor *supportThemeColor;
@property (strong, nonatomic) UIColor *textFieldColor;
@property (strong, nonatomic) UIColor *textViewBoardColor;





@end

