//
//  EventBoardTableViewController.m
//  IT Support
//
//  Created by Yin Hua on 22/07/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "EventBoardTableViewController.h"
#import "AppDelegate.h"
#import "AppHelper.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "EventBoardTableViewCell.h"
#import "NewEventViewController.h"

@interface EventBoardTableViewController ()
{
    AppDelegate *mDelegate_;
    AppHelper *appHelper_;
    MBProgressHUD *HUD_;
    
    //data
    NSMutableArray *tableData_;
    

}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *createNewBarButtonItem;

@end

#define cellHeight 106.0f//105+1


@implementation EventBoardTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = [[UIApplication sharedApplication] delegate];
    appHelper_ = [[AppHelper alloc]init];
    
    //tableview delegate
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self initialSettingForView];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self prepareEventList];
    
}


-(void)initialSettingForView
{
    
    //setting color
    //仅processing 状态下 可以添加新Event
    [self.navigationController.navigationBar setBarTintColor:mDelegate_.appThemeColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    if (![mDelegate_.searchType isEqualToString:@"Processing"]) {
        
        self.createNewBarButtonItem.tintColor = [UIColor clearColor];
        self.createNewBarButtonItem.enabled = NO;
    }else{

        self.createNewBarButtonItem.tintColor = [UIColor whiteColor];
        self.createNewBarButtonItem.enabled = YES;
    }
    
    tableData_ = [[NSMutableArray alloc]init];

}

#pragma mark - retrieving data
-(void)prepareEventList
{
    NSLog(@"retrieving events data...");
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    NSString *requestID = [NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"RequestID"]];

    NSDictionary *parameters = @{@"requestID" : requestID
                                 };
    
    //URL:    /ITSupportService/API/RequestEventRecord
    NSString *getMethod = @"/ITSupportService/API/RequestEventRecord";

    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:mDelegate_.userEmail password:mDelegate_.userToken];
    
    
    //clientID 放在parameters中
    [manager GET:getMethod parameters:parameters  success:^(NSURLSessionDataTask *task, id responseObject) {
        [HUD_ hide:YES];

        
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
                [appHelper_ initialViewController:@"LoginViewStoryboardID"];
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
            
            tableData_ = [responseDictionary valueForKey:@"Result"];
//            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
//            tempArray = [responseDictionary valueForKey:@"Result"];
//            //0 is load earlier data
//            if ([direction_ isEqualToString:@"0"]) {
//                
//                for (NSDictionary *dic in tempArray) {
//                    [tableData_ addObject:dic];
//                }
//                
//            }else if ([direction_ isEqualToString:@"1"]){
//                //1 is load next data
//                for (NSDictionary *dic in tempArray) {
//                    [tableData_ insertObject:dic atIndex:0];
//                }
//            }
            
            [self.tableView reloadData];
            
//            [loadMore_ setText:@"All Loaded."];
//            NSLog(@"Retrieved Request List Data");
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [HUD_ hide:YES];
//        self.menuBarButtonItem.enabled = YES;
        
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


#pragma mark - Table view data source

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return cellHeight;//105+1
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [tableData_ count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    
    NSString *cellidentify = @"EventBoardCell";
    
    EventBoardTableViewCell *cell = (EventBoardTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellidentify];
    if(cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EventBoardTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
 
    
    NSDictionary *dataObject = [tableData_ objectAtIndex:indexPath.row];
    
    //--userColorView ----------
    //--dueDayLabel ----------
    //--descriptionTextView ---
    NSString *userType = [NSString stringWithFormat:@"%@", [dataObject valueForKey:@"UserType"]];
    
    NSString *description = [NSString stringWithFormat:@"%@",[dataObject valueForKey:@"Description"]];
    
    
    //due day
    //添加.111 为了正常转换时区
    NSString *dateStr = [NSString stringWithFormat:@"%@.111",[dataObject valueForKey:@"EventDueDate"]];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.'zzz"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSString * dueDayText =[NSString stringWithFormat:@"Due: %@", [dateFormatter stringFromDate:date]];
    

    
    
    //populate a cell
    if ([userType isEqualToString:@"0"]) {
        cell.userColorView.backgroundColor = mDelegate_.clientThemeColor;
    }else{
        cell.userColorView.backgroundColor = mDelegate_.supportThemeColor;
    }

    cell.dueDayLabel.text = dueDayText;
    cell.descriptionTextView.text = description;

    
    //draw line on Cell
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight-1, self.view.bounds.size.width, 1)];
    lineView.backgroundColor = mDelegate_.textViewBoardColor;
    [cell addSubview:lineView];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"To New Event View"]) {

        UINavigationController *navController = [segue destinationViewController];
        NewEventViewController *nevc = (NewEventViewController *)([navController viewControllers][0]);
        nevc.requestObject = self.requestObject; //requestID
    }
}



#pragma mark - other
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
