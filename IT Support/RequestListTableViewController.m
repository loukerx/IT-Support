//
//  RequestListTableViewController.m
//  IT Support
//
//  Created by Yin Hua on 19/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "RequestListTableViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "MenuListViewController.h"
#import "RequestDetailTableViewController.h"
#import "RequestListTableViewCell.h"
#import "AppHelper.h"
#import "RequestReviewTableViewController.h"
#import "UserSettingTableViewController.h"
#import "SearchTableViewController.h"


@interface RequestListTableViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    AppDelegate *mDelegate_;
    AppHelper *appHelper_;
    MBProgressHUD *HUD_;
    
    //data
    NSMutableArray *tableData_;
    //no project
    BOOL noProjectCheck_;
    UIImageView *noProjectView_;
    //load more
    NSString *currentRequestID_;
    NSString *direction_;//时间查询：0 向前; 1 向后;
    UILabel *loadMore_;
    NSUInteger lastLoadingTableDataCount_;
    
    
    //menu
    UIView *menu_;
    MenuListViewController *menuListView_;
    NSString *searchType_;//request status type for seaching
    
    //filter Values
    NSString *searchCategoryID_;
    NSDate *searchDueDate_;
    NSString *searchTitle_;

    
    //For Fun
    NSTimer *sendPositionTimer;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;




@end


#define THE_ITEM_TO_SELECT 0
#define THE_SECTION 0

@implementation RequestListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    mDelegate_ = [[UIApplication sharedApplication] delegate];
    appHelper_ = [[AppHelper alloc]init];
    
    
    self.title = @"My Projects";
    
    //loadmore label
    loadMore_ =[[UILabel alloc]initWithFrame: CGRectMake(0,0,self.tableView.frame.size.width,44)];
    loadMore_.textColor = [UIColor blackColor];
    loadMore_.highlightedTextColor = [UIColor darkGrayColor];
    loadMore_.backgroundColor = [UIColor clearColor];
    loadMore_.font=[UIFont fontWithName:@"Verdana" size:18];
    loadMore_.textAlignment=NSTextAlignmentCenter;
//    loadMore_.font=[UIFont boldSystemFontOfSize:20];
    loadMore_.text= @"正在加载...";
    
    
    //no project
    noProjectCheck_ = NO;
    
    noProjectView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NoProject"]];
    noProjectView_.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    noProjectView_.contentMode = UIViewContentModeScaleAspectFit;
    
    //refreshControl
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    //setting
    searchCategoryID_ = nil;
    searchDueDate_ = nil;
    searchTitle_ = nil;
    
    //tableview delegate
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    [self initialSettingForView];
    

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}


-(void)initialSettingForView
{
    //loading HUD
    HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD_.labelText = @"Progressing...";
    self.menuBarButtonItem.enabled = NO;
    
    //table data
    currentRequestID_ = @"";//version 2.0
    direction_ = @"0";
    lastLoadingTableDataCount_ = 0;
    tableData_ = [[NSMutableArray alloc]init];
    
    searchType_ = mDelegate_.searchType;
    [self prepareRequestList:searchType_];//version 1.1
    
    //menu_ list
    menu_ = [[UIView alloc]init];
    menuListView_ = [[MenuListViewController alloc]init];
    menuListView_.superController = self;
    
    //setting color
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];//mDelegate_.appThemeColor;
    [self.navigationController.navigationBar setBarTintColor:mDelegate_.appThemeColor];


    /* 新建project已经转移到其他页面
    //User Mode
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        
//        self.addBarButtonItem.enabled = YES;
        [self.rightBarButtonItem setTitle:@"New"];
//        self.rightBarButtonItem.tintColor = mDelegate_.appThemeColor;
        
    }else{
        
//        self.addBarButtonItem.enabled = NO;
        [self.rightBarButtonItem setTitle:@"Search"];
//        self.addBarButtonItem.tintColor = [UIColor clearColor];
//        self.rightBarButtonItem.tintColor = mDelegate_.appThemeColor;
    }
     
     */
    
    self.rightBarButtonItem.tintColor = [UIColor whiteColor];

}



#pragma mark - refreshControl
- (void)refresh:(UIRefreshControl *)refreshControl {
    
    if (tableData_.count>0) {
        NSDictionary *dic = tableData_[0];
        currentRequestID_ = [NSString stringWithFormat:@"%@", [dic valueForKey:@"RequestID"]];
    }else{
        currentRequestID_ = @"";//version 2.0
    }

    direction_ = @"1";
    lastLoadingTableDataCount_ = 0;
    self.menuBarButtonItem.enabled = NO;
    [self prepareRequestList:searchType_];//version 2.0
    [refreshControl endRefreshing];
}

#pragma mark - retrieving data 2.0
-(void)prepareRequestList:(NSString *)searchType
{
    //navigationbar title
    self.title = @"My Projects";//searchType;
    mDelegate_.searchType = searchType;
    
    NSLog(@"retrieving requests data...");
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    //default "curID" is "currentRequestID" = 0
    NSString *curID = currentRequestID_;
    NSString *direction = direction_;
    int requestStatus = [appHelper_ getRequestStatusIndex:searchType];
    NSString *status = [NSString stringWithFormat:@"%d",requestStatus];

    NSString *searchCondition = [appHelper_ converToJsonStringByCategoryID:searchCategoryID_ searchDueDate:searchDueDate_ searchTitle:searchTitle_];
    
    NSString *getMethod = @"";
    NSDictionary *parameters;
    //user mode
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        
        NSString *clientID = mDelegate_.clientID;
        parameters = @{@"clientID" : clientID,
                       @"CurID" : curID,
                       @"Direction": direction,
                       @"Status" : status,
                       @"SearchCondition" : searchCondition
                       };
        getMethod = @"/ITSupportService/API/Request/Client";
    }else{
        NSString *supportID = mDelegate_.supportID;
        parameters = @{@"SupportID" : supportID,
                       @"CurID" : curID,
                       @"Direction": direction,
                       @"Status" : status,
                       @"SearchCondition" : searchCondition
                       };
        getMethod = @"/ITSupportService/API/Request/Support";
    }
    
    
    NSLog(@"%@",parameters);
    
    //URL:   /ITSupportService/API/Request/Client
    //URL:   /ITSupportService/API/Request/Support
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:mDelegate_.userEmail password:mDelegate_.userToken];
    
    
    //clientID 放在parameters中
    [manager GET:getMethod parameters:parameters  success:^(NSURLSessionDataTask *task, id responseObject) {
        [HUD_ hide:YES];
        self.menuBarButtonItem.enabled = YES;
      
        NSLog(@"%@",responseObject);
        //convert to NSDictionary
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];
        
        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"0"]) {
           
            
            NSDictionary *errorDic = [responseDictionary valueForKey:@"Error"];
            
            NSString *errorMessage =[NSString stringWithFormat:@"%@",[errorDic valueForKey:@"Message"]];
               NSString *errorCode =[NSString stringWithFormat:@"%@",[errorDic valueForKey:@"Code"]];
            
            
            if ([errorCode isEqualToString:@"1002"]) {
                //log out
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Process Error"
                                                                    message:invalidTokenMessage
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
//                //[appHelper_ initialViewController:@"LoginViewStoryboardID"];
            }else{
                
                UIAlertController *alert =
                [UIAlertController alertControllerWithTitle:@"Error!!"
                                                    message:errorMessage
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction =
                [UIAlertAction actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {}];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }else if ([responseStatus isEqualToString:@"1"]) {
            
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            tempArray = [responseDictionary valueForKey:@"Result"];
            //0 is load earlier data
            if ([direction_ isEqualToString:@"0"]) {
                
                for (NSDictionary *dic in tempArray) {
                    [tableData_ addObject:dic];
                }
                
            }else if ([direction_ isEqualToString:@"1"]){
                //1 is load next data
                for (NSDictionary *dic in tempArray) {
                    [tableData_ insertObject:dic atIndex:0];
                }
            }
            noProjectCheck_ = YES;
            [self.tableView reloadData];
            
//            [loadMore_ setText:@"All Loaded."];
            NSLog(@"Retrieved Request List Data");
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [HUD_ hide:YES];
        self.menuBarButtonItem.enabled = YES;

        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Server Error"
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

#pragma mark - Menu List
- (IBAction)MenuAction:(id)sender {
    [self showMenuListViewController];
}

- (void)showMenuListViewController
{
    menu_ = menuListView_.view;
    CGFloat width = mDelegate_.window.frame.size.width;
    CGFloat height = mDelegate_.window.frame.size.height;
    
    menu_.frame = CGRectMake(-width, 0, width, height);
    [self.navigationController.view addSubview:menu_];
    //    [self.view addSubview:menu_];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         menu_.frame = CGRectMake(0, 0, width, height);
                     }completion:^(BOOL finished) {
                         menu_.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
                     }];
}

- (void)hideMenuListViewController:(NSString *)displayMode
{
    menu_.backgroundColor = [UIColor clearColor];
    
    CGFloat width = mDelegate_.window.frame.size.width;
    CGFloat height = mDelegate_.window.frame.size.height;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         menu_.frame = CGRectMake(-width,0, width,height);
                     } completion:^(BOOL finished) {
                         [menu_ removeFromSuperview];
                     }];
    
    

    if ([displayMode isEqualToString:@"Setting"]){

//        [self performSegueWithIdentifier:@"To UserSetting TableView" sender:self];
        
    }else if (displayMode != nil) {
        
        searchType_ = displayMode;
        currentRequestID_ = @"";//version 2.0
        direction_ = @"0";
        lastLoadingTableDataCount_ = 0;
        tableData_ = [[NSMutableArray alloc]init];
        
        //loading HUD
        HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD_.labelText = @"Progressing...";
        self.menuBarButtonItem.enabled = NO;
        [self prepareRequestList:searchType_];//version 1.1
        
//        tableData_ = [[NSMutableArray alloc] init];
//        [tableData_ addObjectsFromArray:mDelegate_.propertyShortlist];
//        
//        [self.tableView reloadData];
//        if ([tableData_ count]>0) {
//            NSIndexPath *selection = [NSIndexPath indexPathForItem:THE_ITEM_TO_SELECT
//                                                         inSection:THE_SECTION];
//            [self.tableView scrollToRowAtIndexPath:selection atScrollPosition:UITableViewScrollPositionTop animated:NO];
//        }
    }else{

    }
    
}

#pragma mark button action
- (IBAction)rightButtonAction:(id)sender {
    /* 新建project已经转移到其他页面
    if ([self.rightBarButtonItem.title isEqualToString:@"New"]) {
        [self performSegueWithIdentifier:@"To SelectCategory TableView" sender:self];
    }else
       */
        
    if ([self.rightBarButtonItem.title isEqualToString:@"Search"]) {
        [self performSegueWithIdentifier:@"To Search TableView" sender:self];
    }
}

#pragma mark - TableView Datasource

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == [tableData_ count]) {
        return 44;
    }
    return 85;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [tableData_ count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellidentify = @"RequestListCell";
    UITableViewCell *cell = nil;

    if (indexPath.row!= tableData_.count) {
        RequestListTableViewCell *cell = (RequestListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellidentify];
        
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RequestListTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        //populate a cell
        NSDictionary *requestObject = [tableData_ objectAtIndex:indexPath.row];
        
        //--image ----------
        //--title ----------
        //--contact name ---
        //--company name ---
        //--price ----------
        //--created date ---
        //----load more-----
        
        NSString *title = [NSString stringWithFormat:@"%@",[requestObject valueForKey:@"Title"]];
        NSString *price = [NSString stringWithFormat:@"$%@",[requestObject valueForKey:@"Price"]];
        NSString *contactName,*companyName;
        
        
        //client 显示 support name,company
        //support 显示 client name,company
        if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
            contactName = [NSString stringWithFormat:@"%@",[requestObject valueForKey:@"SupportContactName"]?:@"N/A"];
            
            companyName = [NSString stringWithFormat:@"%@",[requestObject valueForKey:@"SupportCompanyName"]?:@"N/A"];

        }else{
            contactName = [NSString stringWithFormat:@"%@",[requestObject valueForKey:@"ClientContactName"]];
            companyName = [NSString stringWithFormat:@"%@",[requestObject valueForKey:@"ClientCompanyName"]];
        }
        
        NSString *dateStr =[NSString stringWithFormat:@"%@",[requestObject valueForKey:@"CreateDate"]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.'zzz"];
        NSDate *date = [dateFormatter dateFromString:dateStr];
        
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSString * createDate = [dateFormatter stringFromDate:date];

        cell.titleLabel.text = title;
        cell.contactNameLabel.text = contactName;
        cell.companyNameLabel.text = companyName;
        cell.priceLabel.text = price;
        cell.createdDateLabel.text = createDate;
        cell.createdDateLabel.textColor = mDelegate_.appThemeColor;
        
        //image
        NSString *parentID = [NSString stringWithFormat:@"%@",[requestObject valueForKey:@"RequestCategoryParentID"]];
        UIImage *image = [appHelper_ imageFromCategoryID:parentID];
        cell.imageView.image = image;
        
        //draw line on Cell
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 84, self.view.bounds.size.width, 1)];
        lineView.backgroundColor = mDelegate_.textViewBoardColor;
        [cell addSubview:lineView];
 
        if (indexPath.row == tableData_.count - 1) {
            currentRequestID_ = [NSString stringWithFormat:@"%@",[requestObject valueForKey:@"RequestID"]];
        }
        return cell;
        
    }else{
        //add load more indicate on this cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        if(cell==nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"Cell"];
        }

        [cell addSubview:loadMore_];
        
        if ([tableData_ count] > lastLoadingTableDataCount_) {
            [loadMore_ setText:@"Loading..."];
            
            direction_ = @"0";

            [self prepareRequestList:searchType_];//version 1.1
            lastLoadingTableDataCount_ = [tableData_ count];
        }else{

            if (tableData_.count == 0 && noProjectCheck_) {

                [self.tableView addSubview:noProjectView_];
                [loadMore_ removeFromSuperview];
            }else{
                [loadMore_ setText:@"All Loaded."];
                [noProjectView_ removeFromSuperview];
            }
        }
    }

    return cell;
}


#pragma mark - TableView Delegate
//Delete Request [Client][Active]


// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if ([mDelegate_.searchType isEqualToString:@"Active"] && [mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        return YES;
    }
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"Delete this row.....");
        
        
        HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD_.labelText = @"Processing...";
        
        [self cancelActiveRequest:indexPath];
    }
}

-(void)cancelActiveRequest:(NSIndexPath *)indexPath
{
    
    NSLog(@"Deleting request...");
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    
    NSString *clientID = mDelegate_.clientID;
    
    NSDictionary *requestObj = [tableData_ objectAtIndex:indexPath.row];
    NSString *requestID = [NSString stringWithFormat:@"%@", [requestObj valueForKey:@"RequestID"]];
    
    NSString *URLString = @"/ITSupportService/API/Request/ClientDelete";
    NSDictionary *parameters = @{@"ClientID" : clientID,
                                @"RequestID" : requestID
                                };

    
    //URL:   /ITSupportService/API/Request/Client

    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:mDelegate_.userEmail password:mDelegate_.userToken];
    
    //clientID 放在parameters中
    [manager POST:URLString parameters:parameters  success:^(NSURLSessionDataTask *task, id responseObject) {

        self.menuBarButtonItem.enabled = YES;
        
        NSLog(@"%@",responseObject);
        //convert to NSDictionary
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];
        
        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"0"]) {
            
            [HUD_ hide:YES];
            
            
            NSDictionary *errorDic = [responseDictionary valueForKey:@"Error"];
            
            NSString *errorMessage =[NSString stringWithFormat:@"%@",[errorDic valueForKey:@"Message"]];
                    NSLog(@"%@",errorMessage);
               NSString *errorCode =[NSString stringWithFormat:@"%@",[errorDic valueForKey:@"Code"]];
            
            
            if ([errorCode isEqualToString:@"1002"]) {
                //log out
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Process Error"
                                                                    message:invalidTokenMessage
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
                //[appHelper_ initialViewController:@"LoginViewStoryboardID"];
            }else{
                
       
                UIAlertController *alert =
                [UIAlertController alertControllerWithTitle:@"Delete Request Error!!"
                                                    message:@"An error has been occured"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction =
                [UIAlertAction actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                       
                                        //refresh this view controller
                                        [self initialSettingForView];
                                       
                                       }];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        }else if ([responseStatus isEqualToString:@"1"]) {
            
            [tableData_ removeObjectAtIndex:indexPath.row];
            
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //update user info
            HUD_.labelText = @"Update User Info...";
            [self retrieveUserInfo];
            NSLog(@"----Cancel Successed, Request List Data Updated------");
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [HUD_ hide:YES];
        self.menuBarButtonItem.enabled = YES;
        
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Server Error"
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

-(void)retrieveUserInfo{
    
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    NSString *URLString;
    NSDictionary *parameters;
    
    //User Mode
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        NSString *clientID = mDelegate_.clientID;
        URLString =[NSString stringWithFormat:@"/ITSupportService/API/Client"];
        parameters = @{@"clientID" : clientID
                       };
        
    }else{
        NSString *supportID = mDelegate_.supportID;
        URLString =[NSString stringWithFormat:@"/ITSupportService/API/Support"];
        parameters = @{@"supportID" : supportID
                       };
    }
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:mDelegate_.userEmail password:mDelegate_.userToken];
    
    [manager GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [HUD_ hide:YES];
        
        NSLog(@"%@",responseObject);
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];
        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"1"]) {
            
            mDelegate_.userDictionary = [responseDictionary valueForKey:@"Result"];
            
        }else if ([responseStatus isEqualToString:@"0"]) {
          
            NSDictionary *errorDic = [responseDictionary valueForKey:@"Error"];
            
            NSString *errorMessage =[NSString stringWithFormat:@"%@",[errorDic valueForKey:@"Message"]];
               NSString *errorCode =[NSString stringWithFormat:@"%@",[errorDic valueForKey:@"Code"]];
            
            
            if ([errorCode isEqualToString:@"1002"]) {
                //log out
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Process Error"
                                                                    message:invalidTokenMessage
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
                //[appHelper_ initialViewController:@"LoginViewStoryboardID"];
            }else{
            
            UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"User Info Updated Error!!"
                                                message:errorMessage
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction =
            [UIAlertAction actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {

                                   }];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [HUD_ hide:YES];
        
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Error Creating Request"
                                            message:[error localizedDescription]
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {

                               }];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

#pragma mark - Select Row
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != tableData_.count) {
        [self performSegueWithIdentifier:@"To RequestDetail TableView" sender:self];
    }

}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"To RequestDetail TableView"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        RequestDetailTableViewController *rdtvc = [segue destinationViewController];
        rdtvc.requestObject = [tableData_ objectAtIndex:indexPath.row];

    }
//    else if([[segue identifier] isEqualToString:@"To Search TableView"]){
    
//        SearchTableViewController *stvc = [segue destinationViewController];
//        stvc.searchCategoryID = searchCategoryID_;
//        stvc.searchDueDate = searchDueDate_;
//        stvc.searchTitle = searchTitle_;
        
//    }

}

#pragma mark - unwind segue
-(IBAction)unwindToRequestListTableView:(UIStoryboardSegue *)segue {
    
    UIViewController* sourceViewController = segue.sourceViewController;
    
    if ([sourceViewController isKindOfClass:[RequestReviewTableViewController class]]||[segue.identifier isEqualToString:@"Unwind From Login View"]||[segue.identifier isEqualToString:@"Unwind From RequestDetail TableView"])
    {
        NSLog(@"unwind segue processed...");
        [self initialSettingForView];

    }

    
    if ([segue.identifier isEqualToString:@"Unwind From SearchTableView"]) {
        SearchTableViewController *stvc = (SearchTableViewController *)segue.sourceViewController;
        
        searchCategoryID_ = stvc.searchCategoryID?:nil;
        searchDueDate_ = stvc.searchDueDate?:nil;
        searchTitle_ = stvc.searchTitle.length>0?stvc.searchTitle:nil;
        
        [self initialSettingForView];
    }

}


@end
