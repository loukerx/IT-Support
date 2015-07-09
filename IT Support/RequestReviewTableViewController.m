//
//  RequestReviewTableViewController.m
//  IT Support
//
//  Created by Yin Hua on 19/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "RequestReviewTableViewController.h"
#import "AppDelegate.h"
#import "AppHelper.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

@interface RequestReviewTableViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UIActionSheetDelegate>
{
    AppDelegate *mDelegate_;
    AppHelper *appHelper_;
    CGFloat scrollViewHeight_;
    NSString *requestID_;
    NSMutableArray *imageDescriptionArray_;
    MBProgressHUD *HUD_;
}
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *pageLabel;

@property (strong, nonatomic) UITextField *subjectTextField;
@property (strong, nonatomic) UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendBarButtonItem;

@end

@implementation RequestReviewTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    //setting
    scrollViewHeight_ = self.view.frame.size.width * cellHeightRatio;
    [self initialCustomView];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"Review";
    
    //populate values
    [self preparePhotosForScrollView];
    [self populateTableViewHeader];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}


-(void)initialCustomView{
    
    //textfield
    CGRect subjectTextFieldFrame = CGRectMake(10, 10, self.view.frame.size.width - 20, 45);
    self.subjectTextField = [[UITextField alloc] initWithFrame:subjectTextFieldFrame];
//    self.subjectTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Subject" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], }];
    self.subjectTextField.backgroundColor = mDelegate_.textFieldColor;
    self.subjectTextField.textColor = [UIColor blackColor];
    self.subjectTextField.font = [UIFont systemFontOfSize:16.0f];
    self.subjectTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.subjectTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    self.subjectTextField.returnKeyType = UIReturnKeyDone;
    self.subjectTextField.textAlignment = NSTextAlignmentLeft;
    self.subjectTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.subjectTextField.text=self.requestTitle;//[NSString stringWithFormat:@"%@",mDelegate_.requestSubject];
    self.subjectTextField.enabled = NO;

    
    //textview
    CGRect textViewFrame = CGRectMake(10.0f, 60.0f, self.view.frame.size.width - 20, 160.0f);
    self.descriptionTextView = [[UITextView alloc] initWithFrame:textViewFrame];
    //    self.descriptionTextView.returnKeyType = UIReturnKeyDone;
    self.descriptionTextView.backgroundColor = mDelegate_.textFieldColor;
    self.descriptionTextView.font = [UIFont systemFontOfSize:17.0f];
    self.descriptionTextView.layer.cornerRadius = 5.0f;
    self.descriptionTextView.layer.borderColor = [mDelegate_.textViewBoardColor CGColor];
    self.descriptionTextView.layer.borderWidth = 0.6f;
    self.descriptionTextView.text = self.requestDescription;//[NSString stringWithFormat:@"Description:\n\n%@",mDelegate_.requestDescription];
    self.descriptionTextView.editable = NO;
    self.descriptionTextView.textColor = [UIColor blackColor];
    self.descriptionTextView.delegate = self;
    

}

#pragma mark - scrollview & tableHeaderView

-(void)preparePhotosForScrollView
{
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, scrollViewHeight_)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor blackColor];
    
    NSMutableArray *photos = [[NSMutableArray alloc]init];
    
    for (int i = 0; i<[mDelegate_.mRequestImages count]; i++) {
        
        id myObject = mDelegate_.mRequestImages[i];
        if ([myObject isKindOfClass:[UIImage class]]) {
            
            //check if it is working
            [photos addObject:mDelegate_.mRequestImages[i]];
        }
    }
    
    if (photos.count>0) {
        //setting frame
        CGRect tmpFrame = self.view.bounds;
        CGFloat width = tmpFrame.size.width;
        CGFloat height = scrollViewHeight_;//self.scrollView.bounds.size.height;
        
        self.scrollView.contentSize =  CGSizeMake( width * photos.count,0);
        
        int count = 0;
        
        for(UIImage *image in photos)
        {
            
            UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
            imageview.contentMode = UIViewContentModeScaleAspectFit;
            imageview.frame = CGRectMake(width * count, 0, width, height);
            [self.scrollView addSubview:imageview];
            count++;
            
        }
    }
}


- (void)populateTableViewHeader
{
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0,self.scrollView.bounds.size.height)];
        view.backgroundColor = [UIColor blackColor];
        [view addSubview:self.scrollView];
        
        //lower right corner page number
        self.pageLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        if (mDelegate_.mRequestImages.count>0) {
            [self.pageLabel setText:[NSString stringWithFormat:@"1/%lu",(unsigned long)[mDelegate_.mRequestImages count]]];
        }else{
            [self.pageLabel setText:[NSString stringWithFormat:@"N/A"]];
        }

        [self.pageLabel setTextColor:[UIColor whiteColor]];
        [self.pageLabel setBackgroundColor:[UIColor clearColor]];
        [self.pageLabel setTextAlignment:NSTextAlignmentCenter];
        [self.pageLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
        CGSize textSize = [[self.pageLabel text] sizeWithAttributes:@{NSFontAttributeName:[self.pageLabel font]}];
        CGFloat width = textSize.width + 10;
        CGFloat height = textSize.height + 4;
        [self.pageLabel setFrame:CGRectMake(self.view.frame.size.width -width -10, scrollViewHeight_ - height -10, width, height)];
        [view addSubview:self.pageLabel];
        
        
        view;
    });
}

#pragma mark - ScrollView Delegate

-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //display scrollview page number
    CGFloat x =  scrollView.contentOffset.x;
    CGFloat width = scrollView.frame.size.width;
    int page = roundf(x/width) + 1;
    
    
    if (mDelegate_.mRequestImages.count>0) {
        self.pageLabel.text = [NSString stringWithFormat:@"%d/%lu",page,(unsigned long)[mDelegate_.mRequestImages count]];
    }else{
        [self.pageLabel setText:[NSString stringWithFormat:@"N/A"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1)
        return 230;
    
    return self.tableView.rowHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 1) {
        return 1;
    }
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    //-------------section 0
    //- Category
    //- Subcategory
    //- Price
    //-------------section 1
    //- Subject
    //- Description
    UITableViewCell *cell=nil;
    
    if(indexPath.section == 0){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:@"RequestReviewTableViewCell"];
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Category:";
                //                 [cell.textLabel setFont:[UIFont systemFontOfSize:20]];
                //                 [cell.textLabel adjustsFontSizeToFitWidth];
                cell.detailTextLabel.text = mDelegate_.requestCategory;
                break;
            case 1:
                cell.textLabel.text = @"Subcategory:";
                //                 [cell.textLabel setFont:[UIFont systemFontOfSize:20]];
                //                 [cell.textLabel adjustsFontSizeToFitWidth];
                cell.detailTextLabel.text = mDelegate_.requestSubCategory;
                break;
            case 2:
                cell.textLabel.text = @"Given Price:";
                cell.detailTextLabel.text = self.requestPrice;
                break;
                
            default:
                break;
        }
    }else{
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"RequestReviewTableViewCell"];
        //subject textfield
        [cell addSubview:self.subjectTextField];

        //description textview
        [cell addSubview:self.descriptionTextView];
     
    }
    
    return cell;
}

#pragma mark - Send Request
- (IBAction)sendAction:(UIBarButtonItem *)sender {
    
    
    UIAlertController* alertController =
    [UIAlertController alertControllerWithTitle:nil
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];

    
    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                           handler:^(UIAlertAction *action) {}];
    
    UIAlertAction *confirmAction =
    [UIAlertAction actionWithTitle:@"Confirm"
                             style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction *action){
                               
                               HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                               HUD_.labelText = @"Uploading Photos...";
                               
                               
                               if (mDelegate_.mRequestImages.count > 0) {
                                    [self createImageFiles];//version 2.0<#statements#>
                               }else{
//                                   NSDictionary *returnDictionay;
                                   [self createRequest:nil];
                               }
                           
                           
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

#pragma mark version 2.0
-(void)createImageFiles
{
    NSLog(@"uploading photos");
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];

    NSDictionary *parameters = @{};
    
    //upload images
    AFHTTPRequestOperationManager *manager =[[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];// [AFHTTPRequestOperationManager manager];
    [manager POST:@"/ITSupportService/API/File" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        int index =0;
        if (mDelegate_.mRequestImages.count>0) {
            for (UIImage *image in mDelegate_.mRequestImages) {
                
                NSString *UUIDString = [[[NSUUID alloc] init] UUIDString];
                NSString *UUIDStr = [UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
                NSString *tempPhotoFileName = [NSString stringWithFormat: @"%@.%@", UUIDStr,@"jpg"];
                NSData *bestImageData = UIImageJPEGRepresentation(image, 1.0);
//                NSString *name = [NSString stringWithFormat:@"%@",nameArray[index]];
                NSString *name = [NSString stringWithFormat:@"%d", index];
                //send Photo Data
                [formData appendPartWithFileData:bestImageData
                                            name:name//description tag
                                        fileName:tempPhotoFileName
                                        mimeType:@"image/jpeg"];
                
                index++;
            }
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {

        
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];
        
        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"1"]) {
            
            UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"Success"
                                                message:@"Uploading Photos."
                                         preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okAction =
            [UIAlertAction actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
             {
                 NSDictionary *returnDictionay = [responseDictionary valueForKey:@"Result"];
                 [self createRequest:returnDictionay];
                 
             }];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];

        }else if ([responseStatus isEqualToString:@"0"]) {
            if ([[responseDictionary valueForKey:@"ErrorCode"] isEqualToString:@"1001"]) {
                //log out
                [appHelper_ initialViewController:@"LoginViewStoryboardID"];
            }else{
            [HUD_ hide:YES];
            
            UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"Upload Photos Error"
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HUD_ hide:YES];
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Error Uploading Photos"
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

-(void)createRequest:(NSDictionary *)returnDictionay
{
    HUD_.labelText = @"Creating Request...";
    
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    //URL： http://ec2-54-79-39-165.ap-southeast-2.compute.amazonaws.com/ITSupportService/API/Request/Client
    NSString *clientID = mDelegate_.clientID;
    NSString *categoryID = mDelegate_.requestCategoryID;
    NSString *price = [self.requestPrice substringFromIndex:1];
    NSString *title = self.requestTitle;
    NSString *description = self.requestDescription;
    NSString *priority = @"1";
    
    
    //create picDescritptions
    imageDescriptionArray_ = [[NSMutableArray alloc]init];
    
    //匹配 description 与image File 返回值
    for (NSDictionary *dic in returnDictionay) {
        
        //version 2.0
        NSString *fileKey = [NSString stringWithFormat:@"%@", [dic valueForKey:@"FileKey"]];
        int i = [fileKey intValue];
        NSString *fileRecordID = [NSString stringWithFormat:@"%@", [dic valueForKey:@"FileRecordID"]];
        NSString *descriptionContent = [NSString stringWithFormat:@"%@",mDelegate_.mRequestImageDescriptions[i]];
        NSDictionary *descriptionDic = @{@"FileRecordID":fileRecordID,//this name connects to photo
                                             @"Description":descriptionContent
                                             };
        [imageDescriptionArray_ addObject:descriptionDic];
        
    }
    
    //json to NSString
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:imageDescriptionArray_
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *descriptionJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *parameters = @{@"clientID" : clientID,
                                 @"categoryID" : categoryID,
                                 @"price" : price,
                                 @"title": title,
                                 @"description" : description,
                                 @"priority" : priority,
                                 @"picDescriptions" :descriptionJsonString
                                 };
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:mDelegate_.userEmail password:mDelegate_.userToken];
    
    [manager POST:@"/ITSupportService/API/Request/Client" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        NSLog(@"%@",responseObject);
        //convert to NSDictionary
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];
        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"1"]) {
            
            UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"Success"
                                                message:@"Created Request."
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction =
            [UIAlertAction actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
            {
                [self retrieveUserInfo];

            }];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }else if ([responseStatus isEqualToString:@"0"]) {
            
            if ([[responseDictionary valueForKey:@"ErrorCode"] isEqualToString:@"1001"]) {
                //log out
                [appHelper_ initialViewController:@"LoginViewStoryboardID"];
            }else{
            
            [HUD_ hide:YES];
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


-(void)retrieveUserInfo{
    HUD_.labelText = @"Retrieving User Info...";
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    NSString *URLString;
    NSDictionary *parameters;
    
    //Client Mode
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        NSString *clientID = mDelegate_.clientID;
        URLString =[NSString stringWithFormat:@"/ITSupportService/API/Client"];
        parameters = @{@"clientID" : clientID
                       };
        
    }else{//Support Mode
        NSString *supportID = mDelegate_.supportID;
        URLString =[NSString stringWithFormat:@"/ITSupportService/API/Support"];
        parameters = @{@"supportID" : supportID
                       };
    }
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:mDelegate_.userEmail password:mDelegate_.userToken];
    
    [manager GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [HUD_ hide:YES];
        
        NSLog(@"%@",responseObject);
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];
        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"1"]) {
            
            mDelegate_.userDictionary = [responseDictionary valueForKey:@"Result"];
            
            [self performSegueWithIdentifier:@"Unwind To RequestList TableView" sender:self];
            
        }else if ([responseStatus isEqualToString:@"0"]) {
            
            if ([[responseDictionary valueForKey:@"ErrorCode"] isEqualToString:@"1001"]) {
                //log out
                [appHelper_ initialViewController:@"LoginViewStoryboardID"];
            }else{
            
            NSString *errorMessage =[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"Message"]];
            
            UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"Update User Info Error!!"
                                                message:errorMessage
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction =
            [UIAlertAction actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                        [self performSegueWithIdentifier:@"Unwind From RequestDetail TableView" sender:self];
                                   }];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [HUD_ hide:YES];
        
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Update User Info Error!!"
                                            message:[error localizedDescription]
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   [self performSegueWithIdentifier:@"Unwind From RequestDetail TableView" sender:self];
                               }];
        
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


@end
