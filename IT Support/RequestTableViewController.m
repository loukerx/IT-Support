//
//  RequestTableViewController.m
//  IT Support
//
//  Created by Yin Hua on 13/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "RequestTableViewController.h"
#import "AppDelegate.h"
#import "RequestReviewTableViewController.h"

@interface RequestTableViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UITextFieldDelegate>
{
        AppDelegate *mDelegate_;
        CGFloat scrollViewHeight_;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *pageLabel;
@property (strong, nonatomic) UITextField *priceTextField;
@property (strong, nonatomic) UITextField *subjectTextField;
@property (strong, nonatomic) UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reviewBarButtonItem;


@end

#define categorySection 0
#define priceSection 1
#define titleSection 2
#define tableRowHeight 44.0f
#define textfieldHeight tableRowHeight - 6

@implementation RequestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    //setting
    scrollViewHeight_ = self.view.frame.size.width * cellHeightRatio;
    [self initialCustomView];
    self.navigationController.navigationBar.tintColor = mDelegate_.appThemeColor;
    self.reviewBarButtonItem.tintColor = mDelegate_.appThemeColor;
//    [self preparePhotosForScrollView];
    
    [self prepareImageView];
    [self populateTableViewHeader];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //dismissKeyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.tableView addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if (mDelegate_.mRequestImages.count>0) {
        self.imageView.image = mDelegate_.mRequestImages[0];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
    }
}
#pragma mark - prepare ImageView
-(void)prepareImageView{
    
    //test
//        [mDelegate_.mRequestImages removeAllObjects];
//    for (int num=1;num<3; num++) {
//        [mDelegate_.mRequestImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"image%d.jpg",num]]];
//        
//        [mDelegate_.mRequestImageDescriptions addObject:@"For additional question, please leave your message."];
//    }
//    NSString *UUIDString = [[[NSUUID alloc] init] UUIDString];
//    mDelegate_.requestDescription =[NSString stringWithFormat:@"test description, %@", UUIDString];
//    mDelegate_.requestSubject = [NSString stringWithFormat:@"Subject,%@", UUIDString];
//;
//    
    

    self.imageView = [[UIImageView alloc] initWithImage:nil];
    self.imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, scrollViewHeight_);
    if (mDelegate_.mRequestImages.count>0) {
        self.imageView.image = mDelegate_.mRequestImages[0];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;

    }
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView addGestureRecognizer:singleTapGestureRecognizer];
    
}



-(void)initialCustomView{
    
    //Title TextField
    CGRect subjectTextFieldFrame = CGRectMake(10, 10, self.view.frame.size.width - 20, textfieldHeight);
    self.subjectTextField = [[UITextField alloc] initWithFrame:subjectTextFieldFrame];
    self.subjectTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Subject" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], }];
    self.subjectTextField.backgroundColor = mDelegate_.textFieldColor;
    self.subjectTextField.textColor = [UIColor blackColor];
    self.subjectTextField.font = [UIFont systemFontOfSize:16.0f];
    self.subjectTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.subjectTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.subjectTextField.returnKeyType = UIReturnKeyDone;
    self.subjectTextField.textAlignment = NSTextAlignmentLeft;
    self.subjectTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

//    self.subjectTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.subjectTextField];
    self.subjectTextField.tag = 101;
    self.subjectTextField.delegate = self;
    
    //Description TextView
    CGRect textViewFrame = CGRectMake(10.0f, 10.0f, self.view.frame.size.width - 20, 160.0f);
    self.descriptionTextView = [[UITextView alloc] initWithFrame:textViewFrame];
    self.descriptionTextView.returnKeyType = UIReturnKeyDone;
    self.descriptionTextView.backgroundColor = mDelegate_.textFieldColor;
    self.descriptionTextView.font = [UIFont systemFontOfSize:17.0f];
    self.descriptionTextView.layer.cornerRadius = 5.0f;
    self.descriptionTextView.layer.borderColor = [mDelegate_.textViewBoardColor CGColor];
    self.descriptionTextView.layer.borderWidth = 0.6f;
    self.descriptionTextView.text = @"For additional question, please leave your message.";
    self.descriptionTextView.textColor = [UIColor lightGrayColor];
    self.descriptionTextView.tag = 102;
    self.descriptionTextView.delegate = self;

    //price textField
    CGRect priceTextFieldFrame = CGRectMake(0, 0, 80, textfieldHeight);
    self.priceTextField = [[UITextField alloc] initWithFrame:priceTextFieldFrame];
    self.priceTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"$1xx" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], }];
    self.priceTextField.backgroundColor = mDelegate_.textFieldColor;
    self.priceTextField.textColor = [UIColor blackColor];
    self.priceTextField.font = [UIFont systemFontOfSize:16.0f];
    self.priceTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.priceTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.priceTextField.returnKeyType = UIReturnKeyDone;
    self.priceTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.priceTextField.textAlignment = NSTextAlignmentCenter;
    self.priceTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

    //    self.subjectTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.priceTextField];
    self.subjectTextField.tag = 103;
    self.priceTextField.delegate = self;
}

#pragma mark - TextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.descriptionTextView.text isEqualToString:@"For additional question, please leave your message."]) {
        self.descriptionTextView.text = @"";
        self.descriptionTextView.textColor = [UIColor blackColor]; //optional
    }
    [self.descriptionTextView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.descriptionTextView.text isEqualToString:@""]) {
        self.descriptionTextView.text = @"For additional question, please leave your message.";
        self.descriptionTextView.textColor = [UIColor lightGrayColor]; //optional
    }
    [self.descriptionTextView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView{
    
//    mDelegate_.requestDescription = self.descriptionTextView.text;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
//    NSString *price = self.priceTextField.text;
//    self.priceTextField.text = [NSString stringWithFormat:@"$%@",price];
    
}
- (void)textFieldDidChange:(NSNotification *)notification {
    
    if(self.priceTextField.text.length >5){
        self.priceTextField.text = [self.priceTextField.text substringWithRange:NSMakeRange(0,5)];
    }else if (self.priceTextField.text.length >1) {
        NSArray *array = [self.priceTextField.text componentsSeparatedByString:@"$"];
        if([self checkAvailableFunds:array[1]])
        {
            self.priceTextField.text = [NSString stringWithFormat:@"$%@",array[1]];
        }
    }else if(self.priceTextField.text.length==1){
        NSArray *array = [self.priceTextField.text componentsSeparatedByString:@"$"];
        if (![array[0]isEqualToString:@""]&&![array[0] isEqualToString:@"0"]&&[self checkAvailableFunds:array[0]]) {
            self.priceTextField.text = [NSString stringWithFormat:@"$%@",array[0]];
        }else{
             self.priceTextField.text = @"";
        }
    }
}

-(BOOL)checkAvailableFunds:(NSString *)requestPrice
{
    int availableFunds = [[NSString stringWithFormat:@"%@",[mDelegate_.userDictionary valueForKey:@"AvailableFunds"]] intValue];
    int price = [requestPrice intValue];
    if (price <= availableFunds && availableFunds > 0) {
        return true;
    }else{
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Ops, Sorry"
                                            message:@"You DO NOT have enough funds."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   self.priceTextField.text = [self.priceTextField.text substringWithRange:NSMakeRange(0,self.priceTextField.text.length-1)];
                               }];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    return false;
}

#pragma mark - textFiled Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 30;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return NO;
}


#pragma mark - gesture

-(void)dismissKeyboard{
    
    [self.view endEditing:YES];
}

-(void)handleSingleTapGesture:(UITapGestureRecognizer *)recognizer {
    
    NSLog(@"Push To RequestPhoto View");
    [self performSegueWithIdentifier:@"To RequestPhoto View" sender:self];
}

#pragma mark - scrollview & tableHeaderView

-(void)preparePhotosForScrollView
{
    //////////////////
    //////////////////
    ////NOT USING/////
    //////////////////
    //////////////////
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, scrollViewHeight_)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    [self.scrollView addGestureRecognizer:singleTapGestureRecognizer];
    
    NSMutableArray *photos = [[NSMutableArray alloc]init];
    
    //test
//    [mDelegate_.mRequestImages removeAllObjects];
//    for (int num=1;num<6; num++) {
//        [mDelegate_.mRequestImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"image%d.jpg",num]]];
//        
//        [mDelegate_.mRequestImageDescriptions addObject:@"For additional question, please leave your message."];
//    }
    
    
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
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0,self.scrollView.bounds.size.height)];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0,self.imageView.bounds.size.height)];
        view.backgroundColor = [UIColor blackColor];
//        [view addSubview:self.scrollView];
        [view addSubview:self.imageView];
        
        //lower right corner page number
//        self.pageLabel = [[UILabel alloc]initWithFrame:CGRectZero];
//        if (mDelegate_.mRequestImages.count>0) {
//            [self.pageLabel setText:[NSString stringWithFormat:@"1/%lu",(unsigned long)[mDelegate_.mRequestImages count]]];
//        }else{
//            [self.pageLabel setText:[NSString stringWithFormat:@"N/A"]];
//        }
//
//        [self.pageLabel setTextColor:[UIColor whiteColor]];
//        [self.pageLabel setBackgroundColor:[UIColor blackColor]];
//        [self.pageLabel setTextAlignment:NSTextAlignmentCenter];
//        [self.pageLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
//        CGSize textSize = [[self.pageLabel text] sizeWithAttributes:@{NSFontAttributeName:[self.pageLabel font]}];
//        CGFloat width = textSize.width + 10;
//        CGFloat height = textSize.height + 4;
//        [self.pageLabel setFrame:CGRectMake(self.view.frame.size.width -width -10, scrollViewHeight_ - height -10, width, height)];
//        [view addSubview:self.pageLabel];
        
        
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

#pragma mark - Table view data source

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == titleSection && indexPath.row == 1)
        return 170;
    
    return tableRowHeight;
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
    if (section == 1) {
        return 3;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    //-------------section 0
    //- Category
    //- Subcategory
    //-------------section 1
    //- Available Funds
    //- Account Balance
    //-------------section 2
    //- Subject
    //- Description
    UITableViewCell *cell=nil;
    
    if(indexPath.section == categorySection){
        
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
    }else if (indexPath.section == priceSection){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:@"RequestTableViewCell"];
        
        NSString *availableFunds = [NSString stringWithFormat:@"$%@",[mDelegate_.userDictionary valueForKey:@"AvailableFunds"]];
        NSString *accountBalance = [NSString stringWithFormat:@"$%@",[mDelegate_.userDictionary valueForKey:@"AccountBalance"]];
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Available Funds:";
                cell.detailTextLabel.text = availableFunds;
                break;
            case 1:
                cell.textLabel.text = @"Account Balance:";
                cell.detailTextLabel.text = accountBalance;
                break;
            case 2:
                cell.textLabel.text = @"Your Price:";
                cell.accessoryView = self.priceTextField;
                break;
                
            default:
                break;
        }
    }else{

         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"RequestTableViewCell"];
         switch (indexPath.row) {
             case 0:
                 //subject textfield
                 [cell addSubview:self.subjectTextField];
                 break;
             case 1:
                 
                 //description textview
                 [cell addSubview:self.descriptionTextView];
                 break;
                 
             default:
                 break;
         }
     }
    
    return cell;
}

#pragma mark tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    mDelegate_.requestSubCategory = cell.textLabel.text;
//    [self performSegueWithIdentifier:@"To Request View" sender:self];
}


#pragma mark - Navigation
- (IBAction)reviewAction:(id)sender {
    [self dismissKeyboard];
    NSString *priceCheck = self.priceTextField.text;
    if ([priceCheck isEqualToString:@""]) {
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Error"
                                            message:@"Please input a price"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                               }];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self performSegueWithIdentifier:@"To RequestReview TableView" sender:self];
    }

}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"To RequestReview TableView"]) {
        
        RequestReviewTableViewController *rrtvc = segue.destinationViewController;
        rrtvc.requestTitle = self.subjectTextField.text.length>0?self.subjectTextField.text:@"N/A";
        
        if ([self.descriptionTextView.text isEqualToString:@"For additional question, please leave your message."]) {
            rrtvc.requestDescription = @"N/A";
        }else{
            rrtvc.requestDescription = self.descriptionTextView.text;
        }

        rrtvc.requestPrice = self.priceTextField.text;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
