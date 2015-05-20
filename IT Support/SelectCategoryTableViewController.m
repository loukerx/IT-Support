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

@interface SelectCategoryTableViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    AppDelegate *mDelegate_;
    NSArray *titles_;
    NSInteger catNum_;
}



@end

@implementation SelectCategoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = [[UIApplication sharedApplication] delegate];
    self.title = @"Select Category";
    //setting
      titles_ = @[@"Website",@"Server",@"Hardware",@"Software",@"Others"];
    
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
    return titles_.count;//4;
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
    
    cell.textLabel.text = titles_[indexPath.row];

    return cell;
    
    
}

#pragma mark tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    catNum_ = indexPath.row;
    mDelegate_.requestCategory = cell.textLabel.text;
    [self performSegueWithIdentifier:@"To SubCategory View" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    SelectSubCategoryTableViewController *ssctvc = [segue destinationViewController];
    ssctvc.catNum = (int)catNum_;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
