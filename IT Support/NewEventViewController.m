//
//  NewEventViewController.m
//  IT Support
//
//  Created by Yin Hua on 22/07/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "NewEventViewController.h"
#import "AppDelegate.h"
#import "AppHelper.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

@interface NewEventViewController ()<UITextViewDelegate>
{
    AppDelegate *mDelegate_;
    AppHelper *appHelper_;
    MBProgressHUD *HUD_;
    
    NSDate *dueDate_;
}


@property (weak, nonatomic) IBOutlet UITextField *dueDayTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

//date picker view
@property (strong, nonatomic) UIDatePicker *datePickerView;

@end

@implementation NewEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.navigationController.navigationBar setBarTintColor:mDelegate_.appThemeColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.descriptionTextView.delegate = self;
    self.descriptionTextView.text =@"Please leave your message.";
    self.descriptionTextView.textColor = [UIColor lightGrayColor];
    
    [self initialDatePicker];
    
}


#pragma mark - TextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.descriptionTextView.text isEqualToString:@"Please leave your message."]) {
        self.descriptionTextView.text = @"";
        self.descriptionTextView.textColor = [UIColor blackColor]; //optional
    }
    [self.descriptionTextView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.descriptionTextView.text isEqualToString:@""]) {
        self.descriptionTextView.text = @"Please leave your message.";
        self.descriptionTextView.textColor = [UIColor lightGrayColor]; //optional
    }
    [self.descriptionTextView resignFirstResponder];
}

#pragma mark - DatePicker
-(void)initialDatePicker
{
//    CGRect priceTextFieldFrame = CGRectMake(0, 0, 0, textfieldHeight);
//    self.dueDayTextField = [[UITextField alloc] initWithFrame:priceTextFieldFrame];
//    self.dueDayTextField.borderStyle = UITextBorderStyleNone;//UITextBorderStyleRoundedRect;
    
    
    self.datePickerView = [[UIDatePicker alloc] init];
    self.datePickerView.datePickerMode = UIDatePickerModeDate;
    [self.dueDayTextField setInputView:self.datePickerView];
    
    //uitoolbar
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)]; //初始化
    [toolBar setTintColor:[UIColor blackColor]]; //设置颜色
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(ShowSelectedDate)];
    
    [toolBar setItems:[NSArray arrayWithObjects:doneBtn, nil]];
    [self.dueDayTextField setInputAccessoryView:toolBar];
}

-(void)ShowSelectedDate
{
    dueDate_ = self.datePickerView.date;
    
    if ([dueDate_ compare:[NSDate date]] != NSOrderedAscending) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        
        self.dueDayTextField.text = [dateFormatter stringFromDate:dueDate_];
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        cell.detailTextLabel.text = [dateFormatter stringFromDate:dueDate_];
        [self.dueDayTextField resignFirstResponder];
        
    }else{
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Date Error!"
                                            message:@"Please select a date after today."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                               }];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        //clear requestDeadline_
        dueDate_ = nil;
    }
    
}

#pragma mark - Button Action
- (IBAction)cancelAction:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postAction:(UIBarButtonItem *)sender {
    
    [self.view endEditing:YES];
    NSString *dueDateText = self.dueDayTextField.text;
    NSDate *dueDate = dueDate_;
    NSString *descriptionText = self.descriptionTextView.text;
    if ([dueDateText isEqualToString:@""] || dueDate == nil || [descriptionText isEqualToString:@""] || [descriptionText isEqualToString:@"Please leave your message."]) {
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Error"
                                            message:@"Please Fill All Fields"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                               }];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self postTheEvent:sender];
    }
}

-(void)postTheEvent:(UIBarButtonItem *)sender
{
    UIAlertController* alertController =
    [UIAlertController alertControllerWithTitle:nil
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                           handler:^(UIAlertAction *action) {}];
    
    UIAlertAction *confirmAction =
    [UIAlertAction actionWithTitle:@"Post"
                             style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction *action){

                               [self createEvent];

                           }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIBarButtonItem *sendBarButton = (UIBarButtonItem *)sender;
        popover.barButtonItem = sendBarButton;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)createEvent
{
    HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD_.labelText = @"Creating Event...";
    
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];

    NSString *creatorID;
    //user mode
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
       
        creatorID = mDelegate_.clientID;
    }else{
        
        creatorID = mDelegate_.supportID;
    }

    NSString *requestID = [NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"RequestID"]];
    NSString *description = self.descriptionTextView.text;
    
    //requestDeadline & priceType
    NSDate *dueDate = dueDate_;

    
    NSDictionary *parameters = @{@"creatorID" : creatorID,
                                 @"requestID" : requestID,
                                 @"description" : description,
                                 @"dueDate" :dueDate
                                 };
    //URL: /ITSupportService/API/RequestEventRecord
    NSString *getMethod = @"/ITSupportService/API/RequestEventRecord";
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:mDelegate_.userEmail password:mDelegate_.userToken];
    
    [manager POST:getMethod parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [HUD_ hide:YES];
        
        NSLog(@"%@",responseObject);
        //convert to NSDictionary
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];
        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"1"]) {
            
            UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"Success"
                                                message:@"Created Event."
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction =
            [UIAlertAction actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
             {

                 [self dismissViewControllerAnimated:YES completion:nil];
                 
             }];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }else if ([responseStatus isEqualToString:@"0"]) {
    
            NSDictionary *errorDic = [responseDictionary valueForKey:@"Error"];
            
            NSString *errorMessage =[NSString stringWithFormat:@"%@",[errorDic valueForKey:@"Message"]];
            NSLog(@"%@",errorMessage);
            NSString *errorCode =[NSString stringWithFormat:@"%@",[errorDic valueForKey:@"Code"]];
            
            
            if ([errorCode isEqualToString:@"1002"]) {
                //log out
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Process Error"
                                                                    message:invalidTokenMessage
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [alertView show];
                [appHelper_ initialViewController:@"LoginViewStoryboardID"];
            }else{
                
                
                UIAlertController *alert =
                [UIAlertController alertControllerWithTitle:@"Create Request Error!!"
                                                    message:@"Please try later"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction =
                [UIAlertAction actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action) {
                                           
                                       }];
                
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [HUD_ hide:YES];
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Error Creating Request"
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
