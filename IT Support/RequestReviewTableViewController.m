//
//  RequestReviewTableViewController.m
//  IT Support
//
//  Created by Yin Hua on 19/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "RequestReviewTableViewController.h"
#import "AppDelegate.h"
#import "AFNetworking.h"

@interface RequestReviewTableViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
{
    AppDelegate *mDelegate_;
    CGFloat scrollViewHeight_;
    NSString *requestID_;
    NSMutableArray *imageDescriptionArray_;
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
    self.navigationController.navigationBar.tintColor = mDelegate_.appThemeColor;
    self.sendBarButtonItem.tintColor = mDelegate_.appThemeColor;
    
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
    self.subjectTextField.text=[NSString stringWithFormat:@"Subject:  %@",mDelegate_.requestSubject];
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
    self.descriptionTextView.text =[NSString stringWithFormat:@"Description:\n\n%@",mDelegate_.requestDescription];
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
        [self.pageLabel setBackgroundColor:[UIColor blackColor]];
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
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    //-------------section 0
    //- Category
    //- Subcategory
    //-------------section 1
    //- Subject
    //- Description
    UITableViewCell *cell=nil;
    
    if(indexPath.section == 0){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:@"RequestTableViewCell"];
        
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
                
            default:
                break;
        }
    }else{
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"RequestTableViewCell"];
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

#pragma mark - Send Request
- (IBAction)sendAction:(UIBarButtonItem *)sender {
    
    [self createRequest];
}

-(void)createRequest{
    
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    //URL： http://ec2-54-79-39-165.ap-southeast-2.compute.amazonaws.com/ITSupportService/API/Request/Client
    NSString *clientID = mDelegate_.clientID;
    NSString *categoryID = mDelegate_.requestCategoryID;
    NSString *title = mDelegate_.requestSubject;
    NSString *description = mDelegate_.requestDescription;
    NSString *priority = @"1";
    
    NSDictionary *parameters = @{@"clientID" : clientID,
                                 @"categoryID" : categoryID,
                                 @"title": title,
                                 @"description" : description,
                                 @"priority" : priority
                                 };
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    [manager POST:@"/ITSupportService/API/Request/Client" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
       
        NSLog(@"%@",responseObject);
        //convert to NSDictionary
        NSDictionary *responseDictionary = responseObject;
        NSString *requestResultStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"RequestResultStatus"]];
        // 1 == success, 0 == fail
        if ([requestResultStatus isEqualToString:@"1"]) {

            NSDictionary *newRequest = [responseDictionary valueForKey:@"ResultRequest"];
            
            //需要requestID值
            requestID_ = [NSString stringWithFormat:@"%@",[newRequest valueForKey:@"RequestID"]];
            [self uploadingRequestPhotos];

            
        }else if ([requestResultStatus isEqualToString:@"0"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!!"
                                                                message:[responseObject valueForKey:@"Message"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }


//        [self performSegueWithIdentifier:@"To RequestList TableView" sender:self];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Creating Request"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
 
}


//waiting for test
-(void)uploadingRequestPhotos
{
    NSLog(@"uploading photos");
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    //http://ec2-54-79-39-165.ap-southeast-2.compute.amazonaws.com/ITSupportService/API/Image?RequestID=RequestID&picDescriptions=picDescriptions

    //clear array
    imageDescriptionArray_ = [[NSMutableArray alloc]init];
    NSMutableArray *nameArray = [[NSMutableArray alloc]init];
    
    for (int index =0; index < mDelegate_.mRequestImages.count;index++) {
        //add object in description array
        NSString *descriptionContent = [NSString stringWithFormat:@"%@",mDelegate_.mRequestImageDescriptions[index]];
        NSDictionary *descriptionDic = @{@"Name":[NSString stringWithFormat:@"photo%dDescription",index],//this name connects to photo
                                           @"Description":descriptionContent
                                           };
      
        //create array
        [nameArray addObject:[NSString stringWithFormat:@"photo%d",index]];
        [imageDescriptionArray_ addObject:descriptionDic];
    }
    
    //json to NSString
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:imageDescriptionArray_
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *descriptionJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *parameters = @{@"RequestID" : requestID_,
                                 @"picDescriptions" :descriptionJsonString
                                 };

    //upload images
    AFHTTPRequestOperationManager *manager =[[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];// [AFHTTPRequestOperationManager manager];
    [manager POST:@"/ITSupportService/API/Image" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
 
        int index =0;
        if (mDelegate_.mRequestImages.count>0) {
            for (UIImage *image in mDelegate_.mRequestImages) {
               
                NSString *UUIDString = [[[NSUUID alloc] init] UUIDString];
                NSString *UUIDStr = [UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
                NSString *tempPhotoFileName = [NSString stringWithFormat: @"%@.%@", UUIDStr,@"jpg"];
//                NSString *tempPhotoDescriptionName = [NSString stringWithFormat: @"%@%@", UUIDStr,@"Description"];
                NSData *bestImageData = UIImageJPEGRepresentation(image, 1.0);
                NSString *name = [NSString stringWithFormat:@"%@",nameArray[index]];
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
        NSString *requestResultStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"RequestResultStatus"]];
        
        // 1 == success, 0 == fail
        if ([requestResultStatus isEqualToString:@"1"]) {

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                message:@"Uploading Photos."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            [self performSegueWithIdentifier:@"To RequestList TableView" sender:self];
            
            
        }else if ([requestResultStatus isEqualToString:@"0"]) {
            NSLog(@"Error Message:%@",[responseObject valueForKey:@"Message"]);
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!!"
                                                                message:@"Please try later"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }

        

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Uploading Photos"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
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
