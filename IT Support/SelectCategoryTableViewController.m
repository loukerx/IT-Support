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
    
    
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    //判断是否已经下载过最新categoryList
    if (mDelegate_.categoryListArray.count>0) {
        tableData_ = [[NSMutableArray alloc]init];
        tableData_ = mDelegate_.categoryListArray;

    }else{

        [self prepareCategoryList];
    }
    
    
    //setting color
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"Select Category";


    //clear image & image description
    //because this is the start point to create a new request
    [mDelegate_.mRequestImagesURL removeAllObjects];
    [mDelegate_.mRequestImageDescriptions removeAllObjects];
    [mDelegate_.mRequestImages removeAllObjects];
    
}

#pragma mark - retrieving data
-(void) prepareCategoryList
{
    
    //loading HUD
    HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD_.labelText = @"Progressing...";
    
    NSLog(@"retrieving category list data");
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    NSDictionary *parameters = @{};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:mDelegate_.userEmail password:mDelegate_.userToken];
    
    //clientID 放在parameters中
    [manager GET:@"/ITSupportService/API/Requestcategory" parameters:parameters  success:^(NSURLSessionDataTask *task, id responseObject) {

        
        NSLog(@"%@",responseObject);
        
        //convert to NSDictionary
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];
        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"1"]) {
            
            categoryArray_ =[[NSArray alloc]initWithArray:[responseDictionary valueForKey:@"Result"]];
            
            tableData_ = [[NSMutableArray alloc]init];
            tableData_ = [appHelper_ convertCategoryArray:categoryArray_];
            
            [self.tableView reloadData];
            [HUD_ hide:YES];
            NSLog(@"Retreved category List Data");
            
            
        }else if ([responseStatus isEqualToString:@"0"]) {
            if ([[responseDictionary valueForKey:@"ErrorCode"] isEqualToString:@"1001"]) {
                //log out
                [appHelper_ initialViewController:@"LoginViewStoryboardID"];
            }else{
            NSString *errorMessage =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Message"]];
            
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
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [HUD_ hide:YES];
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Error Retrieving Categories"
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
    
    //image
    NSString *categoryIDString = [NSString stringWithFormat:@"%@",[dic valueForKey:@"RequestCategoryID"]];
    UIImage *image = [appHelper_ imageFromCategoryID:categoryIDString];
    cell.imageView.image = image;
    
    
    
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
