//
//  AppHelper.h
//  IT Support
//
//  Created by Yin Hua on 21/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppHelper : NSObject

typedef NS_ENUM(NSInteger, RequestStatus){
    Active = 0,
    Processing,//1
    Processed,//2
    Finished,//3
    
};

//initial View Controller
-(void)initialViewController:(NSString *)viewControllerIdentifier;

//convert Dictionary Array to JsonString
//-(NSString *)convertDictionaryArrayToJsonString:(NSString *)searchType;

-(NSString *)converToJsonStringByCategoryID:(NSString *)categoryID
                                  searchDueDate:(NSDate *)dueDate
                                    searchTitle:(NSString *)title;
//Request Status
-(int)getRequestStatusIndex:(NSString *)searType;
-(NSString*)convertRequestStatusStringWithInt:(NSInteger)requestStatusInt;
-(NSString*)nextRequestStatusInt:(NSInteger)requestCurrentStatusInt;


//Request Category 整理
-(NSMutableArray*)convertCategoryArray:(NSArray *)categoryArray;
//-(NSString*)categoryNameFromCategoryID:(NSString *)categoryID;
-(UIImage*)imageFromCategoryID:(NSString *)categoryIDString;

//Create radom Code
- (int)createRandomCode;

//Color HexString
-(UIColor*)colorWithHexString:(NSString*)hex;

//check email format
-(BOOL)checkNSStringIsValidEmail:(NSString*)emailString;


@end
