
//
//  RequestDetailTableViewController.m
//  IT Support
//
//  Created by Yin Hua on 19/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "RequestDetailTableViewController.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "AppHelper.h"
#import "RequestPhotoDescriptionTableViewController.h"
#import "MBProgressHUD.h"
#import "RequestListTableViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface RequestDetailTableViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UIActionSheetDelegate>
{
    AppDelegate *mDelegate_;
    AppHelper *appHelper_;
    CGFloat scrollViewHeight_;
    MBProgressHUD *HUD_;
    NSMutableArray *photosArray_;
}
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *pageLabel;

@property (strong, nonatomic) UITextField *subjectTextField;
@property (strong, nonatomic) UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *switchStatusBarButtonItem;

//custome button
@property (strong, nonatomic) UIButton *emailButton;
@property (strong, nonatomic) UIButton *phoneButton;


@end

#define requestSection 0
#define contactSection 1
#define titleSection 2


@implementation RequestDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appHelper_ = [[AppHelper alloc]init];
    
    //clear arrays
    [mDelegate_.mRequestImagesURL removeAllObjects];
    [mDelegate_.mRequestImageDescriptions removeAllObjects];
    [mDelegate_.mRequestImages removeAllObjects];
    photosArray_ = [[NSMutableArray alloc]init];
    
    
    //tableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //setting
    scrollViewHeight_ = self.view.frame.size.width * cellHeightRatio;
    //setting color
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"Details";
    
    
    [self initialCustomView];
    [self initialCustomerButton];
    [self preparePhotosForScrollView];
    [self populateTableViewHeader];
    [self downloadPhotoData];

    //user mode & requestStatus switch button
    NSString *requestStatus =[NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"RequestStatus"]];

    //Client Mode
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        //ONLY Status Processed(2) ON
        if(![requestStatus isEqualToString:@"2"]){
            self.switchStatusBarButtonItem.tintColor = [UIColor clearColor];
            self.switchStatusBarButtonItem.enabled = NO;
        }
    }else{//Support Mode
        //ONLY
        //status Active(0) ON
        //status Processing(1) ON
        if (![requestStatus isEqualToString:@"0"]&&![requestStatus isEqualToString:@"1"]) {
            self.switchStatusBarButtonItem.tintColor = [UIColor clearColor];
            self.switchStatusBarButtonItem.enabled = NO;
        }
    }
    
}

#pragma mark - Retriving Photo Data
-(void)downloadPhotoData
{
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    //http://ec2-54-79-39-165.ap-southeast-2.compute.amazonaws.com/ITSupportService/API/Image
    
    NSString *requestID = [NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"RequestID"]];
    
    NSDictionary *parameters = @{@"RequestID" : requestID};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:mDelegate_.userEmail password:mDelegate_.userToken];
    
    //clientID 放在parameters中
    [manager GET:@"/ITSupportService/API/Image" parameters:parameters  success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //convert to NSDictionary
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];
        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"1"]) {
            
            NSMutableArray *dicArray = [[NSMutableArray alloc]init];
            dicArray = [responseDictionary valueForKey:@"Result"];
            
            for (NSDictionary *dic in dicArray) {
                
                NSString *imageURL = [NSString stringWithFormat:@"%@", [dic valueForKey:@"FileURL"]];
                NSString *imageDescription = [NSString stringWithFormat:@"%@", [dic valueForKey:@"Description"]];
                
                [mDelegate_.mRequestImagesURL addObject:imageURL];
                [mDelegate_.mRequestImageDescriptions addObject:imageDescription];
            }
            
            //reload data for scrollview
            [self.scrollView removeFromSuperview];
            [self preparePhotosForScrollView];
            [self populateTableViewHeader];
            
            NSLog(@"Retrieved Request Photos");
            
        }else if ([responseStatus isEqualToString:@"0"]) {
          
            NSDictionary *errorDic = [responseDictionary valueForKey:@"Error"];
            
            NSString *errorMessage =[NSString stringWithFormat:@"%@",[errorDic valueForKey:@"Message"]];
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
        
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Error Retriving Photos"
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
    self.subjectTextField.text=[NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"Title"]];
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
    self.descriptionTextView.text =[NSString stringWithFormat:@"Description:\n\n%@",[self.requestObject valueForKey:@"Description"]];
    self.descriptionTextView.editable = NO;
    self.descriptionTextView.textColor = [UIColor blackColor];
    self.descriptionTextView.delegate = self;
    
}

-(void)initialCustomerButton
{
    
    //email button
    self.emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emailButton addTarget:self
               action:@selector(emailButtonAction:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.emailButton setImage:[UIImage imageNamed:@"Email"] forState:UIControlStateNormal];
    [self.emailButton sizeToFit];
    self.emailButton.center = CGPointMake(self.view.bounds.size.width*0.33, 22);
    
    //phone button
    self.phoneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.phoneButton addTarget:self
                         action:@selector(phoneButtonAction:)
               forControlEvents:UIControlEventTouchUpInside];
    [self.phoneButton setImage:[UIImage imageNamed:@"Phone"] forState:UIControlStateNormal];
    [self.phoneButton sizeToFit];
    self.phoneButton.center = CGPointMake(self.view.bounds.size.width*0.64, 22);
}

#pragma mark - Custom Button Action

-(void)emailButtonAction:(UIButton*)sender
{
    //createdDate
    NSString *dateStr =[NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"CreateDate"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.'zzz"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSTimeZone *pdt = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [dateFormatter setTimeZone:pdt];
    NSString * createDate = [dateFormatter stringFromDate:date];
    
    //Title
    NSString *title = [NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"Title"]];
    
    NSString *to = sender.titleLabel.text;
    NSString *cc = @"";
    NSString *subject = [NSString stringWithFormat:@"Request[%@]",title];
    NSString *body =[NSString stringWithFormat:@"Request Title: %@\nCreated Date: %@\n",title,createDate];
    
    NSString* emailStr = [NSString stringWithFormat:@"mailto:%@?cc=%@&subject=%@&body=%@",
                     to, cc, subject, body];
    
    emailStr = [emailStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailStr]];
    
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat: @"mailto:%@",sender.titleLabel.text]]];
    
    
    
}

-(void)phoneButtonAction:(UIButton*)sender
{
    UIAlertController* alertController =
    [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Phone: %@",sender.titleLabel.text]
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* cancelAction =
    [UIAlertAction actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                           handler:^(UIAlertAction * action) {}];
    UIAlertAction* confirmAction =
    [UIAlertAction actionWithTitle:@"Dail"
                             style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction * action)
     {
    
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat: @"tel:%@",sender.titleLabel.text]]];
         
     }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIBarButtonItem *confirmBarButton = (UIBarButtonItem *)sender;
        popover.barButtonItem = confirmBarButton;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    
    [self presentViewController:alertController animated:YES completion:nil];

}


#pragma mark - guesture
-(void)scrollviewSingleTapGesture:(UIGestureRecognizer *)tapGestureRecognizer{
    
    if (photosArray_.count == mDelegate_.mRequestImagesURL.count && photosArray_.count>0) {
        
        [mDelegate_.mRequestImages removeAllObjects];
        for (UIImage *image in photosArray_) {
            if ([image isKindOfClass:[UIImage class]]){
                [mDelegate_.mRequestImages addObject:image];
            }
        }
        [self performSegueWithIdentifier:@"To RequestPhotoDescription TableView" sender:self];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
 if ([segue.identifier isEqualToString:@"To RequestPhotoDescription TableView"])
 {
     //calculate start position on scrollview
     CGFloat x =  self.scrollView.contentOffset.x;
     CGFloat width = self.scrollView.frame.size.width;
     
     RequestPhotoDescriptionTableViewController *rpdtvc = [segue destinationViewController];
     rpdtvc.displayPhotoIndex = roundf(x/width);
     rpdtvc.enableEditMode = NO;
 }

}

#pragma mark - scrollview & tableHeaderView

-(void)preparePhotosForScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, scrollViewHeight_)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor blackColor];
    
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollviewSingleTapGesture:)];
    [self.scrollView addGestureRecognizer:singleTapGestureRecognizer];
 
    
    //test image data
//    for (int num=1;num<6; num++) {
//        [mDelegate_.mRequestImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"image%d.jpg",num]]];
//
//        [mDelegate_.mRequestImageDescriptions addObject:@"For additional question, please leave your message."];
//    }
    
    
    NSMutableArray *photosURL = [[NSMutableArray alloc]init];

    for (int i = 0; i<[mDelegate_.mRequestImagesURL count]; i++) {
        
        id myObject = mDelegate_.mRequestImagesURL[i];
        if ([myObject isKindOfClass:[NSString class]]) {
            
            //check if it is working
            [photosURL addObject:mDelegate_.mRequestImagesURL[i]];
        }
    }
    
    if (photosURL.count>0) {
        //setting frame
        CGRect tmpFrame = self.view.bounds;
        CGFloat width = tmpFrame.size.width;
        CGFloat height = scrollViewHeight_;//self.scrollView.bounds.size.height;
        
        self.scrollView.contentSize =  CGSizeMake( width * photosURL.count,0);
        
        int count = 0;
        
        for(NSString *url in photosURL)
        {
      
            //populate image
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
    
                NSString *imageFullsizeURL = [NSString stringWithFormat:@"%@%@",AWSLinkURL,url];
                UIImage *image = [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageFullsizeURL]]];
                
                //save image array
                if (image == nil) {
                    UIImage *defaultImage = [UIImage imageNamed:@"Default Image"];
                    image = defaultImage;
//                    [mDelegate_.mRequestImages addObject:defaultImage];
                    [photosArray_ addObject:defaultImage];
                }else{
                
//                    [mDelegate_.mRequestImages addObject:image];
                    [photosArray_ addObject:image];
                }
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
    
                    UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
                    imageview.contentMode = UIViewContentModeScaleAspectFit;
                    imageview.frame = CGRectMake(width * count, 0, width, height);
                    [self.scrollView addSubview:imageview];
                    
                    //fresh page label
                    [self displayPageLabel];
          
                });
            });
            
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
//        if (mDelegate_.mRequestImages.count>0) {
//            [self.pageLabel setText:[NSString stringWithFormat:@"1/%lu",(unsigned long)[mDelegate_.mRequestImages count]]];
//        }else{
//            [self.pageLabel setText:[NSString stringWithFormat:@"N/A"]];
//        }

        if (photosArray_.count>0) {
            [self.pageLabel setText:[NSString stringWithFormat:@"1/%lu",(unsigned long)[photosArray_ count]]];
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
    
    [self displayPageLabel];
}

-(void)displayPageLabel
{
    //display scrollview page number
    CGFloat x =  self.scrollView.contentOffset.x;
    CGFloat width = self.scrollView.frame.size.width;
    int page = roundf(x/width) + 1;
    
    
    if (mDelegate_.mRequestImagesURL.count>0) {
        self.pageLabel.text = [NSString stringWithFormat:@"%d/%lu",page,(unsigned long)[mDelegate_.mRequestImagesURL count]];
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
    if (indexPath.section == 2)
        return 230;
    
    return self.tableView.rowHeight;//44
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == requestSection) {
        return 4;
    }else if(section == contactSection){
        return 3;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    //-------------section requestSection 0
    //- Created Date
    //- Subcategory
    //- status
    //- Price
    //-------------section contactSection 1
    //- Support Name
    //- Support company
    //- mobile
    //- Email
    //-------------section 2
    //- Subject
    //- Description
    UITableViewCell *cell=nil;
    
    if(indexPath.section == requestSection){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:@"RequestDetailTableViewCell"];
        //createdDate
        NSString *dateStr =[NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"CreateDate"]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.'zzz"];
        NSDate *date = [dateFormatter dateFromString:dateStr];
        
        [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        NSTimeZone *pdt = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        [dateFormatter setTimeZone:pdt];
        NSString * createDate = [dateFormatter stringFromDate:date];
        
        //category
        NSString *categoryName = [NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"RequestCategoryName"]];
//        NSString *parentID = [NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"RequestCategoryParentID"]];
//        UIImage *categoryImage = [appHelper_ imageFromCategoryID:parentID];
        
        //status
        NSString *statusString = [appHelper_ convertRequestStatusStringWithInt:[[self.requestObject valueForKey:@"RequestStatus"]integerValue]];
//        UIImage *statusImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",statusString]];
    
        
        //price
        NSString *price =[NSString stringWithFormat:@"$%@",[self.requestObject valueForKey:@"Price"]];
        switch (indexPath.row) {
                
            case 0:
                cell.textLabel.text = @"Created Date";
                cell.detailTextLabel.text = createDate;
                break;
            case 1:
//                cell.imageView.image = categoryImage;
                cell.textLabel.text = @"Category:";
                cell.detailTextLabel.text = categoryName;
                break;
            case 2:
//                cell.imageView.image = statusImage;
                cell.textLabel.text = @"Status:";
                cell.detailTextLabel.text =  statusString;
                break;
            case 3:
                cell.textLabel.text = @"Price";
                cell.detailTextLabel.text = price;
                break;
            default:
                break;
        }
    }else if(indexPath.section == contactSection){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                reuseIdentifier:@"RequestDetailTableViewCell"];
        //-------------section 1
        //- Support Name
        //- Support company
        //- mobile
        //- Email
        NSString *contactName =@"N/A",*companyName =@"N/A",*contactNumber =@"",*email=@"";
        BOOL buttonEnable = NO;
        UIColor *contactColor = [UIColor grayColor];
        
        if (![mDelegate_.searchType isEqualToString:@"Active"]) {
            
            //client 显示 support name,company
            //support 显示 client name,company
            if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
                buttonEnable = YES;
                contactColor = mDelegate_.supportThemeColor;
                contactName = [NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"SupportContactName"]?:@"N/A"];
                companyName = [NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"SupportCompanyName"]?:@"N/A"];
                contactNumber = [NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"SupportContactNumber"]?:@""];
                email = [NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"SupportEmail"]?:@""];
            }else{
                buttonEnable = YES;
                contactColor = mDelegate_.clientThemeColor;
                contactName = [NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"ClientContactName"]?:@"N/A"];
                companyName = [NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"ClientCompanyName"]?:@"N/A"];
                contactNumber = [NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"ClientContactNumber"]?:@""];
                email = [NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"ClientEmail"]?:@""];
            }
        }
        
        
        switch (indexPath.row) {
                
            case 0:
                cell.textLabel.text = @"Contact Name";
                cell.detailTextLabel.text = contactName;
                break;
            case 1:
                cell.textLabel.text = @"Company Name";
                cell.detailTextLabel.text = companyName;
                break;
//            case 2:
//                cell.textLabel.text = @"Contact Number";
//                cell.detailTextLabel.text = contactNumber;
//                break;
//            case 3:
//                cell.textLabel.text = @"Email";
//                cell.detailTextLabel.text = email;
//                break;
            case 2:
                [self.emailButton setTitle:email forState:UIControlStateNormal];
                [self.emailButton.titleLabel setHidden:YES];
                [self.emailButton.imageView setTintColor:contactColor];
                [self.emailButton setEnabled:buttonEnable];
                
                [self.phoneButton setTitle:contactNumber forState:UIControlStateNormal];
                [self.phoneButton.titleLabel setHidden:YES];
                [self.phoneButton setTintColor:contactColor];
                [self.phoneButton setEnabled:buttonEnable];
                
                [cell addSubview:self.emailButton];
                [cell addSubview:self.phoneButton];
                break;
            default:
                break;
        }
        
    }else{
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"RequestDetailTableViewCell"];
        //subject textfield
        [cell addSubview:self.subjectTextField];
        //        self.subjectTextField.text= mDelegate_.requestSubject;
        //        self.subjectTextField.enabled = NO;
        //description textview
        [cell addSubview:self.descriptionTextView];
        //        self.descriptionTextView.text = mDelegate_.requestDescription;
        //        self.descriptionTextView.editable = NO;
        
        
    }
    return cell;
}

#pragma mark - confirm action
- (IBAction)confirmAction:(id)sender {

    UIAlertController* alertController =
    [UIAlertController alertControllerWithTitle:nil
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* cancelAction =
    [UIAlertAction actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                           handler:^(UIAlertAction * action) {}];
    UIAlertAction* confirmAction =
    [UIAlertAction actionWithTitle:@"Confirm"
                             style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction * action)
    {
        HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD_.labelText = @"Processing...";
        [self updateRequest];//PUT 2.0
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        UIBarButtonItem *confirmBarButton = (UIBarButtonItem *)sender;
        popover.barButtonItem = confirmBarButton;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark version2.0 PUT
-(void)updateRequest{
    
    NSLog(@"Updating Request Status");
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];

    NSString *requestID = [NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"RequestID"]];
    NSString *status = [appHelper_ nextRequestStatusInt:[[self.requestObject valueForKey:@"RequestStatus"] integerValue]];
    
    NSString *URLString;
    NSDictionary *parameters;
    
    //Client Mode
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        NSString *clientID = mDelegate_.clientID;
        URLString =[NSString stringWithFormat:@"/ITSupportService/API/Request/ClientUpdate"];
        
        parameters = @{@"clientID" : clientID,
                       @"requestID" : requestID,
                       @"status": status
                       };
    }else{//Support Mode
        NSString *supportID = mDelegate_.supportID;
        URLString =[NSString stringWithFormat:@"/ITSupportService/API/Request/SupportUpdate"];
        parameters = @{@"supportID" : supportID,
                       @"requestID" : requestID,
                       @"status": status
                       };
    }
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:mDelegate_.userEmail password:mDelegate_.userToken];
    
    [manager POST:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [HUD_ hide:YES];
        NSLog(@"%@",responseObject);
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];
        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"1"]) {
            
            UIAlertController* alert =
            [UIAlertController alertControllerWithTitle:@"Success"
                                                message:@"Request Updated."
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction =
            [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
            {
                //support accept a request
                //client finish a request
                NSString *statusString = [appHelper_ convertRequestStatusStringWithInt:[[self.requestObject valueForKey:@"RequestStatus"]integerValue]];
                if ([statusString isEqualToString:@"Active"]||[statusString isEqualToString:@"Processed"]) {
                    [self retrieveUserInfo];
                }else{
                    [self performSegueWithIdentifier:@"Unwind From RequestDetail TableView" sender:self];
                }
            }];
            
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];

        }else if ([responseStatus isEqualToString:@"0"]) {

            NSDictionary *errorDic = [responseDictionary valueForKey:@"Error"];
            
            NSString *errorMessage =[NSString stringWithFormat:@"%@",[errorDic valueForKey:@"Message"]];
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
            [UIAlertController alertControllerWithTitle:@"Confirm Fail!!"
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


-(void)retrieveUserInfo{
    
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    NSString *URLString;
    NSDictionary *parameters;
    
    //User Mode
    if ([mDelegate_.appThemeColor isEqual:mDelegate_.clientThemeColor]) {
        NSString *clientID = mDelegate_.clientID;
        URLString =[NSString stringWithFormat:@"/ITSupportService/API/Client"];
        parameters = @{@"clientID" : clientID
                       };
        
    }else{
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
            [self performSegueWithIdentifier:@"Unwind From RequestDetail TableView" sender:self];

        }else if ([responseStatus isEqualToString:@"0"]) {
            NSDictionary *errorDic = [responseDictionary valueForKey:@"Error"];
            
            NSString *errorMessage =[NSString stringWithFormat:@"%@",[errorDic valueForKey:@"Message"]];
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
            [UIAlertController alertControllerWithTitle:@"Error!!"
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
        [UIAlertController alertControllerWithTitle:@"Error Creating Request"
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

@end
