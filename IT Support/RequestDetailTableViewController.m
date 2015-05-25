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

@interface RequestDetailTableViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
{
    AppDelegate *mDelegate_;
    AppHelper *appHelper_;
    CGFloat scrollViewHeight_;
}
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UILabel *pageLabel;

@property (strong, nonatomic) UITextField *subjectTextField;
@property (strong, nonatomic) UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *switchStatusBarButtonItem;


@end

@implementation RequestDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appHelper_ = [[AppHelper alloc]init];
    
    //setting
    scrollViewHeight_ = self.view.frame.size.width * cellHeightRatio;
    self.switchStatusBarButtonItem.title = @"game";
    
    [self initialCustomView];
    
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
    self.subjectTextField.text=[NSString stringWithFormat:@"Subject: %@",[self.requestObject valueForKey:@"Title"]];
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

#pragma mark - guesture
-(void)scrollviewSingleTapGesture:(UIGestureRecognizer *)tapGestureRecognizer{
    
    if ([mDelegate_.mRequestImages count]>0) {
        [self performSegueWithIdentifier:@"To RequestPhotoDescription TableView" sender:self];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
 if ([segue.identifier isEqualToString:@"To RequestPhotoDescription TableView"])
 {
     CGFloat x =  self.scrollView.contentOffset.x;
     CGFloat width = self.scrollView.frame.size.width;
     int page = roundf(x/width);
     
     RequestPhotoDescriptionTableViewController *rpdtvc = [segue destinationViewController];
     rpdtvc.displayPhotoNum = page;
     rpdtvc.descriptionTextViewEditable = NO;
 }
    
}

#pragma mark - scrollview & tableHeaderView

-(void)preparePhotosForScrollView
{
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, scrollViewHeight_)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollviewSingleTapGesture:)];
    [self.scrollView addGestureRecognizer:singleTapGestureRecognizer];
 
    
    //test image data
    for (int num=1;num<6; num++) {
        [mDelegate_.mRequestImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"image%d.jpg",num]]];

        [mDelegate_.mRequestImageDescriptions addObject:@"For additional question, please leave your message."];
    }
    
    
    
    
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
            imageview.contentMode = UIViewContentModeScaleAspectFill;
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
    if (indexPath.section == 2)
        return 230;
    
    return self.tableView.rowHeight;
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
    if (section != 0) {
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
        NSString *str = [NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"RequestCategotyID"]];
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Category:";
                //                 [cell.textLabel setFont:[UIFont systemFontOfSize:20]];
                //                 [cell.textLabel adjustsFontSizeToFitWidth];
                cell.detailTextLabel.text = @"";
                break;
            case 1:
                cell.textLabel.text = @"Subcategory:";

                cell.detailTextLabel.text = str;
                break;
                
            default:
                break;
        }
    }else if(indexPath.section == 1){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:@"RequestTableViewCell"];
        cell.textLabel.text = @"Status:";
 
        NSString *statusString = [appHelper_ convertRequestStatusStringWithInt:[[self.requestObject valueForKey:@"RequestStatus"]integerValue]];
        cell.detailTextLabel.text =  [NSString stringWithFormat:@"%@",statusString];
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


#pragma mark - confirm action
- (IBAction)confirmAction:(id)sender {
    [self updateRequest];
}
//test测试阶段，更新状态功能完全开启
//之后再做功能禁用机制
-(void)updateRequest{
    
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    //URL：http://ec2-54-79-39-165.ap-southeast-2.compute.amazonaws.com/ITSupportService/API/Request/Client?clientID=1&requestID=2&status=1
    
    
    //Support http://ec2-54-79-39-165.ap-southeast-2.compute.amazonaws.com/ITSupportService/API/Request/ClientID?requestID=RequestID&status=Status
    NSString *clientID = mDelegate_.clientID;
    NSString *requestID = [NSString stringWithFormat:@"%@",[self.requestObject valueForKey:@"RequestID"]];
    NSString *status = [appHelper_ nextRequestStatusInt:[[self.requestObject valueForKey:@"RequestStatus"] integerValue]];

    
    NSDictionary *parameters = @{@"clientID" : clientID,
                                 @"requestID" : requestID,
                                 @"status": status
                                 };
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:@"/ITSupportService/API/Request/Support" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"%@",responseObject);
        
        [self performSegueWithIdentifier:@"To RequestList TableView" sender:self];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Creating Request"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
}

@end
