//
//  MenuListViewController.m
//  ez4rent
//
//  Created by Yin Hua on 13/04/2015.
//  Copyright (c) 2015 Yin Hua. All rights reserved.
//

#import "MenuListViewController.h"
#import "RequestListTableViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
//test
//#import "RentTypeTableViewController.h"

@interface MenuListViewController ()
{
    AppDelegate *mDelegate_;
    NSArray *titles_;
    NSArray *iconName_;
}

//table view data
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *tableViewData;

//button
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
//layout
@property (weak, nonatomic) IBOutlet UIView *TopView;

@end

#define THE_ITEM_TO_SELECT 0
#define THE_SECTION 0

@implementation MenuListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = [[UIApplication sharedApplication] delegate];
    
    //setting
    //DF0021
    self.logInButton.backgroundColor = [mDelegate_.clientThemeColor colorWithAlphaComponent:1.0f];
    self.TopView.backgroundColor = mDelegate_.clientThemeColor;

    titles_ = @[@"Active",@"Processing",@"Processed",@"Finished"];
//    iconName_ = @[@"Rent-25",@"Buy-25",@"Sold-25",@"Shortlist-25"];
    iconName_ = @[@"Rent-50",@"Buy-50",@"Sold-50",@"Shortlist-50"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;

    //select first tableViewCell
    NSIndexPath *selection = [NSIndexPath indexPathForItem:THE_ITEM_TO_SELECT
                                                 inSection:THE_SECTION];
    [self.tableView selectRowAtIndexPath:selection
                           animated:NO
                     scrollPosition:UITableViewScrollPositionNone];
    
    //check user status
//    if (mDelegate_.mMobileNumber.length>0) {
//        [self.logInButton setTitle:@"Log Out" forState:UIControlStateNormal];
//    }
}

-(void)viewWillAppear:(BOOL)animated{
//    if (mDelegate_.mMobileNumber.length>0) {
//        [self.logInButton setTitle:@"Log Out" forState:UIControlStateNormal];
//    }
    
}

-(void)createTableViewHeader
{
    self.tableView.tableHeaderView =({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 64.0f)];
        view.backgroundColor = [mDelegate_.clientThemeColor colorWithAlphaComponent:1.0f];;
        view;
        
    });
}



#pragma mark Table View DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
//    return [self.tableViewData count];
    return titles_.count;//4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellidentify = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentify];
    
    if(cell == nil)
    {
        // Create a cell to display an ingredient.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellidentify];
    }
    
    
    //setting color
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:23];

    //populate values
    cell.textLabel.text = titles_[indexPath.row];
    if (indexPath.row == 0) {
        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:[UIColor whiteColor]];
        [cell setSelectedBackgroundView:bgColorView];
        
        [cell.textLabel setTextColor:mDelegate_.clientThemeColor];
    }
    cell.imageView.image = [UIImage imageNamed:iconName_[indexPath.row]];
    return cell;

}



#pragma mark tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor whiteColor]];
    [cell setSelectedBackgroundView:bgColorView];
    
    [cell.textLabel setTextColor:mDelegate_.clientThemeColor];
    
    //get navigation controller
    
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    
////    [self performSegueWithIdentifier:@"Test Push" sender:self];
//    MainNavigationViewController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"contentController"];
////    DEMONavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
////    
//    // add view controller on navigation controller
//    RentTypeTableViewController *rentTypeTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"rentType"];
//    navigationController.viewControllers = @[rentTypeTableViewController];
//    
//    
////testing
//    [((MainViewController *)self.superController) addChildViewController:navigationController];
//    mDelegate_.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
//    mDelegate_.window.rootViewController = navigationController;
    
    
    [((RequestListTableViewController*)self.superController)hideMenuListViewController:cell.textLabel.text];
}

- (void)tableView:(UITableView *)tableView
didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor clearColor]];
    [cell setSelectedBackgroundView:bgColorView];
    
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)hideMuneButtonClick:(id)sender {
    [((RequestListTableViewController *)self.superController)hideMenuListViewController:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logInAction:(id)sender {
        [((RequestListTableViewController *)self.superController)hideMenuListViewController:@"Log Out"];
//    [self dismissViewControllerAnimated:YES completion:nil];
    
//    if ([self.logInButton.titleLabel.text isEqualToString:@"Log In"]) {
//       
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewStoryboardID"];
//  
//        [self.view.window.rootViewController presentViewController:loginViewController animated:YES completion:nil];
//    }else
//    {
//        [self.logInButton setTitle:@"Log In" forState:UIControlStateNormal];
    
        //clear
//        [mDelegate_ setMMobileNumber:@""];
//        [mDelegate_ setMPassword:@""];
//        [mDelegate_ setMDisplayName:@""];
//        
//        
//        [[NSUserDefaults standardUserDefaults] setObject:[mDelegate_ mMobileNumber] forKey:@"mMobileNumber"];
//        [[NSUserDefaults standardUserDefaults] setObject:[mDelegate_ mPassword] forKey:@"mPassword"];
//        [[NSUserDefaults standardUserDefaults] setObject:[mDelegate_ mDisplayName] forKey:@"mDisplayName"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
}
@end
