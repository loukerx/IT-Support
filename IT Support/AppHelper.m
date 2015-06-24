//
//  AppHelper.m
//  IT Support
//
//  Created by Yin Hua on 21/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "AppHelper.h"
#import "AppDelegate.h"

@implementation AppHelper


#pragma mark - convert dictionary to Json String
-(NSString *)convertDictionaryArrayToJsonString:(NSString *)searchType
{
//    NSString *requestStatusValue;
    //@[@"Active",@"Processing",@"Processed",@"Finished"]
//    if ([searchType isEqualToString:@"Active"]) {
//        requestStatusValue = @"0";
//    }else if ([searchType isEqualToString:@"Processing"]) {
//        requestStatusValue = @"1";
//    }else if ([searchType isEqualToString:@"Processed"]) {
//        requestStatusValue = @"2";
//    }else if ([searchType isEqualToString:@"Finished"]) {
//        requestStatusValue = @"3";
//    }else{
//        requestStatusValue = @"0";
//    }
    //多字段组合array
//    NSDictionary *searchRequestStatusCondition =@{@"Name":@"RequestStatus",
//                                                  @"Ope":@"1",
//                                                  @"Val":requestStatusValue
//                                                  };
    NSDictionary *searchRequestCategotyIDCondition = @{};

    NSDictionary *searchTitleCondition = @{};

    NSDictionary *searchPriorityCondition = @{};

    NSArray *searchConditionArray = @[searchRequestCategotyIDCondition,
//                                      searchRequestStatusCondition,
                                      searchTitleCondition,searchPriorityCondition];
    //json to NSString
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:searchConditionArray
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

#pragma mark - Request Status 转换
-(int)getRequestStatusIndex:(NSString *)searchType;
{
    
    int requestStatusIndex;
    //@[@"Active",@"Processing",@"Processed",@"Finished"]
    if ([searchType isEqualToString:@"Active"]) {
        requestStatusIndex = 0;
    }else if ([searchType isEqualToString:@"Processing"]) {
        requestStatusIndex = 1;
    }else if ([searchType isEqualToString:@"Processed"]) {
        requestStatusIndex = 2;
    }else if ([searchType isEqualToString:@"Finished"]) {
        requestStatusIndex = 3;
    }else{
        requestStatusIndex = 0;
    }
    return requestStatusIndex;
}



-(NSString*)convertRequestStatusStringWithInt:(NSInteger)requestStatusInt
{
   
    NSString *statusString = @"";
    RequestStatus rs = requestStatusInt;

    switch (rs) {
        case Active:
            statusString = @"Active";
            break;
        case Processing:
            statusString = @"Processing";
            break;
        case Processed:
            statusString = @"Processed";
            break;
        case Finished:
            statusString = @"Finished";
            break;
            
        default:
            break;
    }
    
    return statusString;
}

-(NSString*)nextRequestStatusInt:(NSInteger)requestCurrentStatusInt
{
    NSString *nextStatus;
    RequestStatus rs = requestCurrentStatusInt;
    switch (rs) {
        case Active:
            nextStatus = @"1";
            break;
        case Processing:
            nextStatus = @"2";
            break;
        case Processed:
            nextStatus = @"3";
            break;
        case Finished:
            nextStatus = @"3";
            break;
            
        default:
            break;
    }
    
    return nextStatus;
}



#pragma mark - category list
//conver category to categoryArray & subcategoryArray
-(NSMutableArray*)convertCategoryArray:(NSArray *)categoryArray
{
    AppDelegate *mDelegate_ = [[UIApplication sharedApplication] delegate];
    NSMutableArray *originalCategoryArray = [[NSMutableArray alloc]initWithArray:categoryArray];
    NSMutableArray *categoryIDArray = [[NSMutableArray alloc]init];
    NSMutableArray *returnLevelOneCategoryArray = [[NSMutableArray alloc]init];

    //Get level 1 categories [category list]
    for (NSDictionary *categoryDictionary in categoryArray) {
        
        NSString *level =[NSString stringWithFormat:@"%@",[categoryDictionary valueForKey:@"Level"]];
        if ([level isEqualToString:@"1"]) {
            
            [originalCategoryArray removeObject:categoryDictionary];
            [categoryIDArray addObject:[NSString stringWithFormat:@"%@",[categoryDictionary valueForKey:@"RequestCategoryID"]]];
            [returnLevelOneCategoryArray addObject:categoryDictionary];
            
            NSLog(@"one category has been collected");
        }
       
    }
    NSLog(@"All level 1 categories have been collected");
    
    //populate values
    mDelegate_.categoryListArray = [[NSMutableArray alloc]initWithArray:returnLevelOneCategoryArray];
    mDelegate_.subcategoryListArray = [[NSMutableArray alloc]initWithArray:originalCategoryArray];
    
    
    NSMutableDictionary *levelTwoCategoryDictionary = [[NSMutableDictionary alloc]init];
    NSMutableArray *backupCategoryArray = [[NSMutableArray alloc]initWithArray:originalCategoryArray];
    
    
    //company each level1 category ID
   for (int i = 0; i<categoryIDArray.count; i++) {
       
       NSLog(@"processing subcategory");
       NSString *className = [NSString stringWithFormat:@"categoryID[%@]",categoryIDArray[i]];
       
       //foreach left categoryObject
       for (NSDictionary *categoryDictionary in originalCategoryArray) {
               
           NSString *parentID =[NSString stringWithFormat:@"%@",[categoryDictionary valueForKey:@"ParentID"]];
           //find same categoryObject by their parentID
           if ([parentID isEqualToString:categoryIDArray[i]]) {

               NSMutableArray *array = levelTwoCategoryDictionary[className] ?: [NSMutableArray array];
               [array addObject:categoryDictionary];
               levelTwoCategoryDictionary[className] = array;

               //delete used categoryObject
               [backupCategoryArray removeObject:categoryDictionary];
           }
        }
       originalCategoryArray = [[NSMutableArray alloc]initWithArray:backupCategoryArray];
       NSLog(@"one subcategory have been collected");
   }
    
    NSLog(@"All level 2 categories have been collected");
    
    //populate values
    mDelegate_.subcategoryListDictionary = [[NSMutableDictionary alloc]initWithDictionary:levelTwoCategoryDictionary];
    
    
//levelTWoCategoryDictionary example:
//    {
//        "categoryID[1]" =     (
                            //    {
                            //        Level = 2;
                            //        Name = "Website Development";
                            //        ParentID = 1;
                            //        RequestCategoryID = 6;
                            //    }

    
    return returnLevelOneCategoryArray;

}

-(UIImage*)imageFromCategoryID:(NSString *)categoryIDString
{
    UIImage *image;
    
    int categoryID = [categoryIDString intValue];
    
    switch (categoryID) {
        case 0:
            image = [UIImage imageNamed:@"Others"];
            break;
        case 1:
            image = [UIImage imageNamed:@"Website"];
            break;
        case 2:
            image = [UIImage imageNamed:@"Server"];
            break;
        case 3:
            image = [UIImage imageNamed:@"Computer"];
            break;
        case 4:
            image = [UIImage imageNamed:@"Software"];
            break;
        default:
            image = [UIImage imageNamed:@"Others"];
            break;
    }
    
//    switch (categoryID) {
//        case 0:
//            image = [UIImage imageNamed:@"Others2"];
//            break;
//        case 1:
//            image = [UIImage imageNamed:@"Website2"];
//            break;
//        case 2:
//            image = [UIImage imageNamed:@"Server2"];
//            break;
//        case 3:
//            image = [UIImage imageNamed:@"Computer2"];
//            break;
//        case 4:
//            image = [UIImage imageNamed:@"Software2"];
//            break;
//        default:
//            image = [UIImage imageNamed:@"Others2"];
//            break;
//    }
    return image;
}


#pragma mark - colorWithHexString
-(UIColor*)colorWithHexString:(NSString*)hex//#FF3B30
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}



@end
