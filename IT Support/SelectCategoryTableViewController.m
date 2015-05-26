//
//  SelectCategoryTableViewController.m
//  IT Support
//
//  Created by Yin Hua on 13/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "SelectCategoryTableViewController.h"
#import "AppDelegate.h"
#import "SelectSubCategoryTableViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "AppHelper.h"


@interface SelectCategoryTableViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    AppDelegate *mDelegate_;
    AppHelper *appHelper_;
    MBProgressHUD *HUD_;
    
    //data
    NSArray *categoryArray_;
    NSMutableArray *tableData_;

}



@end

@implementation SelectCategoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = [[UIApplication sharedApplication] delegate];
    appHelper_ = [[AppHelper alloc]init];
    
    //loading HUD
    HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD_.labelText = @"Progressing...";
    
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self prepareRequestList];
    
    //setting color
    self.navigationController.navigationBar.tintColor = mDelegate_.appThemeColor;
    self.title = @"Select Category";

    
}

#pragma mark - retrieving data
-(void) prepareRequestList
{
    
    NSLog(@"retrieving category list data");
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
//    NSString *clientID = mDelegate_.clientID;
//    //default requestID = 0
//    NSString *CurID = @"0";
//    NSString *Direction = @"1";
    
    NSDictionary *parameters = @{};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //URL: http://ec2-54-79-39-165.ap-southeast-2.compute.amazonaws.com/ITSupportService/api/requestcategory
    
    //clientID 放在parameters中
    [manager GET:@"/ITSupportService/API/Requestcategory" parameters:parameters  success:^(NSURLSessionDataTask *task, id responseObject) {
        

        categoryArray_ =[[NSArray alloc]initWithArray:responseObject];
        
        tableData_ = [[NSMutableArray alloc]init];
        tableData_ = [appHelper_ convertCategoryArray:categoryArray_];
        
        [self.tableView reloadData];
        [HUD_ hide:YES];
        NSLog(@"Retreved category List Data");
        
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

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableData_.count;//titles_.count;//4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellidentify = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentify];
    
    if(cell == nil)
    {
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellidentify];
    }

    
    NSDictionary *dic = tableData_[indexPath.row];
    cell.textLabel.text =[NSString stringWithFormat:@"%@",[dic objectForKey:@"Name"]];
    
    return cell;
    
    
}

#pragma mark tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    mDelegate_.requestCategory = cell.textLabel.text;
    [self performSegueWithIdentifier:@"To SubCategory View" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSDictionary *dic = tableData_[indexPath.row];
    SelectSubCategoryTableViewController *ssctvc = [segue destinationViewController];
    //RequestCategoryID is the parentID for next page.
    ssctvc.parentID = [NSString stringWithFormat:@"%@",[dic objectForKey:@"RequestCategoryID"]];;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
