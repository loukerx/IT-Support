//
//  UserSettingTableViewController.m
//  IT Support
//
//  Created by Yin Hua on 11/06/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "UserSettingTableViewController.h"
#import "AppDelegate.h"
#import "AppHelper.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface UserSettingTableViewController ()<UIActionSheetDelegate>
{
    AppDelegate *mDelegate_;
    AppHelper *appHelper_;
    UILabel *logoutLabel_;
    MBProgressHUD *HUD_;
}

@property (strong, nonatomic) UILabel *logoutLabel;

@end

#define ChangePasswordSection 1
#define AboutSection 2
#define LogOutSection 3
#define contactNumberRow 0
#define changePasswordRow 1

@implementation UserSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = [[UIApplication sharedApplication] delegate];
    appHelper_ = [[AppHelper alloc]init];
    
    self.title = @"Settings";
    self.navigationController.navigationBar.tintColor = mDelegate_.appThemeColor;
    
    [self initialCustomView];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)initialCustomView{
    
    //logout label
    logoutLabel_ =[[UILabel alloc]initWithFrame: CGRectMake(0,0,self.tableView.frame.size.width,44)];
    logoutLabel_.textColor = [UIColor whiteColor];
    logoutLabel_.highlightedTextColor = [UIColor darkGrayColor];
    logoutLabel_.backgroundColor = mDelegate_.appThemeColor;
    logoutLabel_.font=[UIFont fontWithName:@"Verdana" size:18];
    logoutLabel_.textAlignment=NSTextAlignmentCenter;
    logoutLabel_.text= @"Log Out";
}


#pragma mark - Table view data source

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 3;
    }else if (section == 2 || section == 1){
        return 2;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    NSString *cellidentify = @"UserSettingTableViewCell";
    
    // Configure the cell...
    //-------------section 0
    //- contact name
    //- available funds
    //- Account Balance
    //-------------section 1
    //- contact number
    //- change password
    //-------------section 2
    //- share on Facebook
    //- about
    //-------------section 3
    //- logout
    //---------footer-------------
    //- copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
    UITableViewCell *cell=nil;
    
    if(indexPath.section == 0){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellidentify];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *contactName = [NSString stringWithFormat:@"%@",[mDelegate_.userDictionary valueForKey:@"ContactName"]];
        NSString *availableFunds = [NSString stringWithFormat:@"$%@",[mDelegate_.userDictionary valueForKey:@"AvailableFunds"]];
        NSString *accountBalance = [NSString stringWithFormat:@"$%@",[mDelegate_.userDictionary valueForKey:@"AccountBalance"]];
        
        switch (indexPath.row) {
            case 0:
                //other info
                cell.textLabel.text = @"Contact Name:";
                cell.detailTextLabel.text = contactName;
                break;
            case 1:
                cell.textLabel.text = @"Available Funds:";
                cell.detailTextLabel.text = availableFunds;
                break;
            case 2:
                cell.textLabel.text = @"Account Balance:";
                cell.detailTextLabel.text = accountBalance;
                break;
            default:
                break;
        }
    }else if(indexPath.section == ChangePasswordSection){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellidentify];
        
        NSString *contactNumber = [NSString stringWithFormat:@"%@",[mDelegate_.userDictionary valueForKey:@"ContactNumber"]];
        
        
        //Client Mode
        if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.userInteractionEnabled = YES;
            cell.selectionStyle =UITableViewCellSelectionStyleDefault;
            
        }else{//Support Mode
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.userInteractionEnabled = NO;
            cell.selectionStyle =UITableViewCellSelectionStyleNone;
        }
        
        
        switch (indexPath.row) {
            case 0:
                //change contact number
                cell.textLabel.text = @"Contact Number:";
                cell.detailTextLabel.text = contactNumber;
                break;
            case 1:
                //change password
                cell.textLabel.text = @"Change Password";
                break;
            default:
                break;
        }



    }else if(indexPath.section == AboutSection){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellidentify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //facebook share button
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:@"http://www.itexpresspro.com.au/#home"];
        
        FBSDKShareButton *shareButton = [[FBSDKShareButton alloc] init];
        shareButton.center = self.view.center;
        shareButton.shareContent = content;
        
        switch (indexPath.row) {
            case 0:
                //Share on Facebook
                cell.textLabel.text = @"Share on Facebook";
                cell.accessoryView = shareButton;
                break;
            case 1:
                cell.textLabel.text = @"About";
                cell.detailTextLabel.text = mDelegate_.appVersion;
                break;
            default:
                break;
        }
    }else{
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellidentify];
        
        [cell addSubview:logoutLabel_];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    if (section == 3) {

        /* Create custom view to display section header... */
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
        [label setFont:[UIFont systemFontOfSize:10]];
        [label setTextColor:mDelegate_.footerTextColor];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:@"Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved."];
        [view addSubview:label];
        return view;
    }
    return view;
}

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == ChangePasswordSection) {
        if (indexPath.row == contactNumberRow) {
            [self performSegueWithIdentifier:@"To Update ContactNumber View" sender:self]; 
        }else if(indexPath.row == changePasswordRow) {
            
            [self performSegueWithIdentifier:@"To UpdatePassword View" sender:self];
        }

        
    }else if (indexPath.section == LogOutSection) {

//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                                 delegate:self
//                                                        cancelButtonTitle:@"Cancel"
//                                                   destructiveButtonTitle:@"Log Out"
//                                                        otherButtonTitles:nil];
//        actionSheet.tag = 1;
//        [actionSheet showInView:self.view];

        
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {}];
        UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive
                                                              handler:^(UIAlertAction * action) {
                                                                  
//                                                                  [self logoutAction];
                                                                  [self userLogout];
                                                              }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:confirmAction];
        
        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
        if (popover)
        {
            popover.sourceView = logoutLabel_;
            popover.sourceRect = logoutLabel_.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - Button Action
- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)logoutAction
{
    //CLEAR NSUserDefaults local variables
    [[NSUserDefaults standardUserDefaults] setObject:@""
                                              forKey:@"userEmail"];
    [[NSUserDefaults standardUserDefaults] setObject:@""
                                              forKey:@"userPassword"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"appThemeColor"];

    mDelegate_.loginIsRoot = NO;
    [self performSegueWithIdentifier:@"To Login View" sender:self];
    
}

#pragma mark - user logout
-(void)userLogout{
    
    //loading view
    HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD_.labelText = @"Logging In...";
    
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    //URL: /ITSupportService/API/Logout
    
    
    NSString *email = [mDelegate_.userDictionary valueForKey:@"Email"];
    NSString *tokenString = mDelegate_.userToken;
    
    
    NSString *URLString =[NSString stringWithFormat:@"/ITSupportService/API/Logout"];
    NSDictionary *parameters = @{@"email" : email,
                                 @"tokenString" : tokenString
                                };
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [HUD_ hide:YES];
        NSLog(@"%@",responseObject);
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];
        
        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"1"]) {
            
            UIAlertController* alert =
            [UIAlertController alertControllerWithTitle:@"Success"
                                                message:@"Contact Number Updated."
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction =
            [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
             {
                 NSLog(@"User log out success");
                 //CLEAR NSUserDefaults local variables
                 [[NSUserDefaults standardUserDefaults] setObject:@""
                                                           forKey:@"userEmail"];
                 [[NSUserDefaults standardUserDefaults] setObject:@""
                                                           forKey:@"userPassword"];
                 [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"appThemeColor"];

                 //unregister remote notification
                 [[UIApplication sharedApplication] unregisterForRemoteNotifications];
                 
                 
                 mDelegate_.loginIsRoot = NO;

                 [self performSegueWithIdentifier:@"To Login View" sender:self];
             }];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }else if ([responseStatus isEqualToString:@"0"]) {
            

            NSString *errorMessage =[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"Message"]];
            
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
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [HUD_ hide:YES];
        
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
