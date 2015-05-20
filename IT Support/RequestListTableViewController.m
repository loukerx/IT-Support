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
#import "MainTableViewCell.h"

@interface RequestListTableViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    AppDelegate *mDelegate_;
    MBProgressHUD *HUD_;
    
    //data
    NSMutableArray *tableData_;
    
    //menu
    UIView *menu_;
    MenuListViewController *menuListView_;
}



@end


#define THE_ITEM_TO_SELECT 0
#define THE_SECTION 0

@implementation RequestListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = [[UIApplication sharedApplication] delegate];
    
    //refreshControl
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //loading HUD
    HUD_ =  [[MBProgressHUD alloc] init];
    HUD_.labelText = @"Progressing...";
    [HUD_ hide:YES];
    [self.view addSubview:HUD_];
    
//    [self prepareRequestList];
    
    //menu_ list
    menu_ = [[UIView alloc]init];
    menuListView_ = [[MenuListViewController alloc]init];
    menuListView_.superController = self;
    
}
#pragma mark - refreshControl
- (void)refresh:(UIRefreshControl *)refreshControl {
    [self prepareRequestList];
    [refreshControl endRefreshing];
}

#pragma mark - retrieving data
-(void) prepareRequestList
{
    
    NSLog(@"retrieving request list data");
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    NSDictionary *parameters = @{};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //http://ec2-52-64-98-132.ap-southeast-2.compute.amazonaws.com/NewsManagement/API/newsinfo
    //request 10 records
    
    [manager GET:@"/NewsManagement/API/newsinfo" parameters:parameters  success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        tableData_ = [[NSMutableArray alloc]init];
        tableData_ = responseObject;
        [self.tableView reloadData];
        
        [HUD_ hide:YES];
        
        
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
    if ([displayMode isEqualToString:@"Shortlist"]) {
        
        tableData_ = [[NSMutableArray alloc] init];
//        [tableData_ addObjectsFromArray:mDelegate_.propertyShortlist];
        
        [self.tableView reloadData];
        if ([tableData_ count]>0) {
            NSIndexPath *selection = [NSIndexPath indexPathForItem:THE_ITEM_TO_SELECT
                                                         inSection:THE_SECTION];
            [self.tableView scrollToRowAtIndexPath:selection atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }else if ([displayMode isEqualToString:@"Active"]) {
        [self prepareRequestList];
    }else if ([displayMode isEqualToString:@"Log Out"]){
        [self performSegueWithIdentifier:@"To Login View" sender:self];
    }
}

#pragma mark - Table view data source

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size.width * cellHeightRatio + 60;
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
    
    MainTableViewCell *cell = (MainTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"RequestListCell" ];
    
    if (tableData_.count>0) {
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MainTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        //populate a cell
        NSDictionary *requestObject = [tableData_ objectAtIndex:indexPath.row];
        cell.subjectLabel.text = [NSString stringWithFormat:@"Subject: %@",[requestObject valueForKey:@"Subject"]];
        cell.statusLabel.text = [NSString stringWithFormat:@"Status: %@",[requestObject valueForKey:@"Status"]];
        
        //populate image
        NSString *myURL =[NSString stringWithFormat:@"%@%@",AWSLinkURL,[requestObject valueForKey:@"PictureURL"]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            
            UIImage *image = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:myURL]]];
            
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                
                [cell.imageView setImage:image];
            });
        });
    }

    return cell;
}

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
