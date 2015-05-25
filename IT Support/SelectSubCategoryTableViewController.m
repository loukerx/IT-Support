//
//  SelectSubCategoryTableViewController.m
//  IT Support
//
//  Created by Yin Hua on 13/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "SelectSubCategoryTableViewController.h"
#import "AppDelegate.h"


@interface SelectSubCategoryTableViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    AppDelegate *mDelegate_;
    NSMutableArray *subCategoryTitles_;
//    NSArray *websiteSubtitles_;
//    NSArray *serverSubtitles_;
//    NSArray *hardwareSubtitles_;
//    NSArray *softwareSubtitles_;
//    NSArray *otherSubtitles_;
    
}



@end

@implementation SelectSubCategoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = [[UIApplication sharedApplication] delegate];
    self.title = @"Select Subcategory";
    //setting
    //@[@"Website: 0 ",@"Server: 1",@"Hardware: 2",@"Software: 3",@"Others: 4"];
//    websiteSubtitles_ =@[@"Website Development",@"Website Design", @"Website Error", @"Others"];
//    serverSubtitles_ =@[@"文件服务器",@"域控服务器",@"安全服务器",@"Others"];
//    hardwareSubtitles_ =@[@"软件问题",@"网络问题",@"打印机问题",@"硬件问题",@"数据丢失",@"Others"];
//    softwareSubtitles_ =@[@"iOS",@"Android",@"桌面软件",@"Others"];
//    otherSubtitles_ = @[@"Others"];
//    switch (self.catNum) {
//        case 0:
//            subCategoryTitles_ = [[NSMutableArray alloc] initWithArray:websiteSubtitles_];
//            break;
//        case 1:
//            subCategoryTitles_ = [[NSMutableArray alloc] initWithArray:serverSubtitles_];
//            break;
//        case 2:
//            subCategoryTitles_ = [[NSMutableArray alloc] initWithArray:hardwareSubtitles_];
//            break;
//        case 3:
//            subCategoryTitles_ = [[NSMutableArray alloc] initWithArray:softwareSubtitles_];
//            break;
//        case 4:
//            subCategoryTitles_ = [[NSMutableArray alloc] initWithArray:otherSubtitles_];
//            break;
//        default:
//            break;
//    }
    
//   NSArray *subcategoryArrayList = [mDelegate_.subcategoryListDictionary objectForKey:self.parentID];
//for(NSDictionary *dic in subcategoryArrayList)
//{
//        subCategoryTitles_ = self.pa
//}
    NSString *dicKeyForSubcategory = [NSString stringWithFormat:@"categoryID[%@]",self.parentID];
    subCategoryTitles_ =[[NSMutableArray alloc] initWithArray:[mDelegate_.subcategoryListDictionary objectForKey:dicKeyForSubcategory]];
    if (subCategoryTitles_.count==0) {
        NSDictionary *dic = @{@"Name" : @"Others",
                              @"RequestCategoryID" : @"5"
                              };
        [subCategoryTitles_ addObject:dic];
    }
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
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
    return subCategoryTitles_.count;//4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellidentify = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentify];
    
    if(cell == nil)
    {
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellidentify];
    }
    
//    cell.textLabel.text = subCategoryTitles_[indexPath.row];
    NSDictionary *dic = subCategoryTitles_[indexPath.row];
    
    cell.textLabel.text =[NSString stringWithFormat:@"%@",[dic objectForKey:@"Name"]];
    cell.detailTextLabel.text =[NSString stringWithFormat:@"%@",[dic objectForKey:@"RequestCategoryID"]];
    [cell.detailTextLabel setHidden:YES];
    
    return cell;
    
    
}

#pragma mark tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    mDelegate_.requestCategoryID = cell.detailTextLabel.text;
    mDelegate_.requestSubCategory = cell.textLabel.text;
    [self performSegueWithIdentifier:@"To Request View" sender:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
