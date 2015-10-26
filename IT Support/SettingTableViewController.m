//
//  SettingTableViewController.m
//  IT Support
//
//  Created by Yin Hua on 22/09/2015.
//  Copyright © 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "SettingTableViewController.h"
#import "AppDelegate.h"
#import "AppHelper.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "TermsAndPolicyViewController.h"

@interface SettingTableViewController ()
{
    AppDelegate *mDelegate_;
    AppHelper *appHelper_;
    MBProgressHUD *HUD_;
}

@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;




@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = [[UIApplication sharedApplication] delegate];
    appHelper_ = [[AppHelper alloc]init];
    
    self.title = @"Settings";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = mDelegate_.appThemeColor;
    
    self.aboutLabel.text = mDelegate_.appVersion;
}

- (void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    if (mDelegate_.userEmail.length>0 && mDelegate_.userToken.length >0) {
        
        NSString *contactName = [NSString stringWithFormat:@"Welcome:    %@",[mDelegate_.userDictionary valueForKey:@"ContactName"]];
        self.contactNameLabel.text = contactName;
        
    }else{
        self.contactNameLabel.text = @"Log In";
    }
    
}


#define UserSection 0

#define SettingSection 1
#define ShareOnFacebookRow 0
#define FeedbackRow 1
#define TipsRow 2
#define PrivacyPolicyRow 3
#define TermsOFUseRow 4

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == UserSection) {
        if ([self.contactNameLabel.text isEqualToString:@"Log In"]) {
            
            mDelegate_.loginIsRoot = NO;
            [self performSegueWithIdentifier:@"To Login View" sender:self];
        }else{
            [self performSegueWithIdentifier:@"To UserSetting TableView" sender:self];
        }
    }
    
    //- Share On Facebook
    //- Feedback
    //- Tips
    //- Privacy policy
    //- Terms of use
    //- About
    if (indexPath.section == SettingSection) {
        if (indexPath.row == ShareOnFacebookRow) {
            //share on facebook
        }else if (indexPath.row == FeedbackRow) {
            [self emailButtonAction];
        }else if(indexPath.row == TipsRow){
            mDelegate_.tipsOn = YES;
            [self performSegueWithIdentifier:@"To Update Pages View" sender:self];
        }else if(indexPath.row == PrivacyPolicyRow) {
            [self performSegueWithIdentifier:@"To TermsAndPolicy View" sender:self];
        }else if (indexPath.row == TermsOFUseRow){
            [self performSegueWithIdentifier:@"To TermsAndPolicy View" sender:self];
        }
    }
}

#pragma mark - Email
-(void)emailButtonAction
{

    NSString *to = @"feedback@itexpresspro.com.au";
    NSString *subject = [NSString stringWithFormat:@"IT Support Version:%@ iOS App Feedback",mDelegate_.appVersion];
    NSString *body =@"";//[NSString stringWithFormat:@"Request Title: %@\nCreated Date: %@\n",title,createDate];
    
    NSString* emailStr = [NSString stringWithFormat:@"mailto:%@?&subject=%@&body=%@",
                          to, subject, body];
    
    emailStr = [emailStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailStr]];
    

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"To TermsAndPolicy View"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TermsAndPolicyViewController *tapvc = [segue destinationViewController];
        tapvc.rowNumber = indexPath.row;
        
    }
}


#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
