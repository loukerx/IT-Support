//
//  AboutTableViewController.m
//  IT Support
//
//  Created by Yin Hua on 17/07/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "AboutTableViewController.h"
#import "AppDelegate.h"
#import "AppHelper.h"
#import "TermsAndPolicyViewController.h"

@interface AboutTableViewController ()
{
    AppDelegate *mDelegate_;
    AppHelper *appHelper_;
}


@end

#define feedbackRow 0
#define tipsRow 1
#define privacyPolicyRow 2
#define TermsOFUseRow 3

//- Feedback
//- Tips
//- Privacy policy
//- Terms of use
//- About

@implementation AboutTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = [[UIApplication sharedApplication] delegate];
    appHelper_ = [[AppHelper alloc]init];
    
    self.title = @"About";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = mDelegate_.appThemeColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell= nil;
    
    // Configure the cell...
    //-------------section 0
    //- Feedback
    //- Tips
    //- Privacy policy
    //- Terms of use
    //- About
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                    reuseIdentifier:@"AboutTableViewCell"];
    
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    switch (indexPath.row) {
        case 0:
            //change contact number
            cell.textLabel.text = @"Feedback";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        case 1:
            //change password
            cell.textLabel.text = @"Tips";
            break;
        case 2:
            //change password
            cell.textLabel.text = @"Privacy Policy";
            break;
        case 3:
            //change password
            cell.textLabel.text = @"Terms of use";
            break;
        case 4:
            //change password
            cell.textLabel.text = @"About";
            cell.detailTextLabel.text = mDelegate_.appVersion;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        default:
            break;
    }
    
    return cell;
}
#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

//- Feedback
//- Tips
//- Privacy policy
//- Terms of use
//- About
//if (indexPath.section == ChangePasswordSection) {
    if (indexPath.row == feedbackRow) {
        [self emailButtonAction];
    }else if(indexPath.row == tipsRow){
        mDelegate_.tipsOn = YES;
        [self performSegueWithIdentifier:@"To Update Pages View" sender:self];
    }else if(indexPath.row == privacyPolicyRow) {
        [self performSegueWithIdentifier:@"To TermsAndPolicy View" sender:self];
    }else if (indexPath.row == TermsOFUseRow){
        [self performSegueWithIdentifier:@"To TermsAndPolicy View" sender:self];
    }
//    }
}

#pragma mark - Email
-(void)emailButtonAction
{
    //createdDate
//    NSString *dateStr =[NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"CreateDate"]];
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.'zzz"];
//    NSDate *date = [dateFormatter dateFromString:dateStr];
//    
//    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
//    NSTimeZone *pdt = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
//    [dateFormatter setTimeZone:pdt];
//    NSString * createDate = [dateFormatter stringFromDate:date];
    
    //Title

    NSString *to = @"feedback@itexpresspro.com.au";
    NSString *subject = [NSString stringWithFormat:@"IT Support Version:%@ iOS App Feedback",mDelegate_.appVersion];
    NSString *body =@"";//[NSString stringWithFormat:@"Request Title: %@\nCreated Date: %@\n",title,createDate];
    
    NSString* emailStr = [NSString stringWithFormat:@"mailto:%@?&subject=%@&body=%@",
                          to, subject, body];
    
    emailStr = [emailStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailStr]];
    
    
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat: @"mailto:%@",sender.titleLabel.text]]];
    
    
    
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


@end
