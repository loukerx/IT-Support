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

@interface RequestListTableViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    AppDelegate *mDelegate_;
    AppHelper *appHelper_;
    MBProgressHUD *HUD_;
    
    //data
    NSMutableArray *tableData_;
    
    //menu
    UIView *menu_;
    MenuListViewController *menuListView_;
    NSString *searchType_;

}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarButtonItem;


@end


#define THE_ITEM_TO_SELECT 0
#define THE_SECTION 0

@implementation RequestListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = [[UIApplication sharedApplication] delegate];
    appHelper_ = [[AppHelper alloc]init];
    
    
    //refreshControl
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    searchType_ = @"Active";
    [self prepareRequestList:searchType_];
    
    //menu_ list
    menu_ = [[UIView alloc]init];
    menuListView_ = [[MenuListViewController alloc]init];
    menuListView_.superController = self;
    
    //setting color
    self.menuBarButtonItem.tintColor = mDelegate_.appThemeColor;
    self.addBarButtonItem.tintColor = mDelegate_.appThemeColor;
    
    //User Mode
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {

        self.addBarButtonItem.enabled = YES;
    }else{

        self.addBarButtonItem.enabled = NO;
        self.addBarButtonItem.tintColor = [UIColor whiteColor];
    }
    
}

#pragma mark - refreshControl
- (void)refresh:(UIRefreshControl *)refreshControl {
    [self prepareRequestList:searchType_];
    [refreshControl endRefreshing];
}

#pragma mark - retrieving data
-(void) prepareRequestList:(NSString *)searchType
{
    //loading HUD
    HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD_.labelText = @"Progressing...";
    
    NSLog(@"retrieving request list data");
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    //URL:Client http://ec2-54-79-39-165.ap-southeast-2.compute.amazonaws.com/ITSupportService/API/Request/Client?ClientID=ClientID&curID=CurID&direction=Direction&searchCondition=SearchCondition
    
    //URL:Support http://ec2-54-79-39-165.ap-southeast-2.compute.amazonaws.com/ITSupportService/API/Request/Support?curID=CurID&direction=Direction&searchCondition=SearchCondition
    
    NSString *empty =@"";
    
    
    //default "curID" is "requestID" = 0
    NSString *curID = @"0";
    NSString *direction = @"1";
    NSString *searchCondition = [appHelper_ convertDictionaryArrayToJsonString:searchType];
    

    NSString *getMethod = @"";
    NSDictionary *parameters;
    //user mode
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        
        NSString *clientID = mDelegate_.clientID;
        parameters = @{@"clientID" : clientID,
                       @"CurID" : curID,
                       @"Direction": direction,
                       @"SearchCondition" : searchCondition
                       };
        getMethod = @"/ITSupportService/API/Request/Client";
    }else{
        parameters = @{@"CurID" : curID,
                       @"Direction": direction,
                       @"SearchCondition" : searchCondition
                       };
        getMethod = @"/ITSupportService/API/Request/Support";
    }

    

    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //clientID 放在parameters中
    [manager GET:getMethod parameters:parameters  success:^(NSURLSessionDataTask *task, id responseObject) {
    
        tableData_ = [[NSMutableArray alloc]init];
        tableData_ = responseObject;
        [self.tableView reloadData];
        
        [HUD_ hide:YES];
        NSLog(@"Retreved Request List Data");
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [HUD_ hide:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Request"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
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
                     }
                     completion:nil];
}

- (void)hideMenuListViewController:(NSString *)displayMode
{
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
    
    
    //sell
    if ([displayMode isEqualToString:@"Log Out"]){
        
        [self performSegueWithIdentifier:@"To Login View" sender:self];
    }else if (displayMode != nil) {
        searchType_ = displayMode;
        [self prepareRequestList:searchType_];
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

#pragma mark - TableView Datasource

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return self.view.frame.size.width * cellHeightRatio + 60;
    return 100;
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
    
    NSString *cellidentify = @"RequestListCell";
    
    RequestListTableViewCell *cell = (RequestListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellidentify ];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RequestListTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }


    //populate a cell
    NSDictionary *requestObject = [tableData_ objectAtIndex:indexPath.row];
    //title
    NSString *title = [NSString stringWithFormat:@"Subject: %@",[requestObject valueForKey:@"Title"]];
    cell.subjectLabel.text = title;
    
    //枚举request状态
//    NSString *statusString;
//    RequestStatus rs = [[requestObject valueForKey:@"RequestStatus"]integerValue];
//    switch (rs) {
//        case Active:
//            statusString = @"Active";
//            break;
//        case Processing:
//            statusString = @"Processing";
//            break;
//        case Processed:
//            statusString = @"Processed";
//            break;
//        case Finished:
//            statusString = @"Finished";
//            break;
//            
//        default:
//            break;
//    }
//    
//    cell.statusLabel.text = [NSString stringWithFormat:@"Status: %@",statusString];

    RequestStatus rs = [[requestObject valueForKey:@"RequestStatus"]integerValue];
    NSString *statusString = [appHelper_ convertRequestStatusStringWithInt:rs];
    cell.statusLabel.text = [NSString stringWithFormat:@"Status: %@",statusString];
    
        //populate image
//        NSString *myURL =[NSString stringWithFormat:@"%@%@",AWSLinkURL,[requestObject valueForKey:@"PictureURL"]];
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
//            
//            UIImage *image = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:myURL]]];
//            
//            dispatch_sync(dispatch_get_main_queue(), ^(void) {
//                
//                [cell.imageView setImage:image];
//            });
//        });

    return cell;
}



#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    roomObject_ = [tableData_ objectAtIndex:indexPath.row];
    
    //    [self performSegueWithIdentifier:@"To Room Details" sender:self];
    [self performSegueWithIdentifier:@"To RequestDetail TableView" sender:self];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"To RequestDetail TableView"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        RequestDetailTableViewController *rdtvc = [segue destinationViewController];
        rdtvc.requestObject = [tableData_ objectAtIndex:indexPath.row];

    }

}


@end
