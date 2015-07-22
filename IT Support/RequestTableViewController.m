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

@interface RequestTableViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UITextFieldDelegate, UIActionSheetDelegate, UIPickerViewDataSource,UIPickerViewDelegate>
{
    AppDelegate *mDelegate_;
    CGFloat scrollViewHeight_;
    NSDate *requestDeadline_;
    //0 = fixed; 1 = negotiable;
    BOOL negotiable_;
    NSArray *priceTypeArray_;
    //0 = By Email; 1 = By Phone;
    BOOL preferPhone_;
    NSArray *preferredContactArray_;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *pageLabel;
@property (strong, nonatomic) UITextField *priceTextField;
@property (strong, nonatomic) UITextField *subjectTextField;
@property (strong, nonatomic) UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reviewBarButtonItem;

//datepicker
@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (strong, nonatomic) UITextField *dateTextField;
@property (strong, nonatomic) UIPickerView *priceTypePickerView;
@property (strong, nonatomic) UITextField *priceTypeTextField;
@property (strong, nonatomic) UIPickerView *preferredContactPickerView;
@property (strong, nonatomic) UITextField *preferredContactTextField;


@end

//section & row
#define categorySection 0

#define availableFundsSection 1


//-------------section 2 priceSection
//- Your Price
//- Price Type
//-------------section 3 preferContactMethodSection
//- PreferredContactMethod
//- Deadline
#define priceSection 2
#define priceRow 0
#define priceTypeRow 1

#define preferContactMethodSection 3
#define preferContactMethodRow 0
#define deadlineRow 1


#define titleSection 4

//height
#define tableRowHeight 44.0f
#define textfieldHeight tableRowHeight - 6

//tag
#define priceTypePickerViewTag 1001
#define preferredContactPickerViewTag 1002





@implementation RequestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //setting
    scrollViewHeight_ = self.view.frame.size.width * cellHeightRatio;
    [self initialCustomView];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"More Details";
//    [self preparePhotosForScrollView];
    
    [self prepareImageView];
    [self populateTableViewHeader];
   
    
    
    //set Picker View
    [self initialDatePicker];
    //0 = fixed; 1 = negotiable;
    negotiable_ = NO;//fixed
    [self initialPriceTypePicker];
    //0 = By Email; 1 = By Phone;
    preferPhone_ = NO;//By Email
    [self initialPreferredContactPicker];
    
    
    //dismissKeyboard
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(dismissKeyboard)];
//    
//    [self.tableView addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if (mDelegate_.mRequestImages.count>0) {
        
        self.imageView.image =  mDelegate_.mRequestImages[0];
        self.imageView.backgroundColor = mDelegate_.scrollViewBackgroundColor;

    }
}


#pragma mark - prepare ImageView
-(void)prepareImageView{

    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_grey"]];
    self.imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, scrollViewHeight_);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;

    if (mDelegate_.mRequestImages.count>0) {
        
        self.imageView.image =  mDelegate_.mRequestImages[0];
    }
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView addGestureRecognizer:singleTapGestureRecognizer];
    
}


-(void)initialCustomView{
    
    //Title TextField
    CGRect subjectTextFieldFrame = CGRectMake(10, 10, self.view.frame.size.width - 20, textfieldHeight);
    self.subjectTextField = [[UITextField alloc] initWithFrame:subjectTextFieldFrame];
    self.subjectTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title：［35 characters］" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], }];
    self.subjectTextField.backgroundColor = mDelegate_.textFieldColor;
    self.subjectTextField.textColor = [UIColor blackColor];
    self.subjectTextField.font = [UIFont systemFontOfSize:16.0f];
    self.subjectTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.subjectTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.subjectTextField.returnKeyType = UIReturnKeyDone;
    self.subjectTextField.textAlignment = NSTextAlignmentLeft;
    self.subjectTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.subjectTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.subjectTextField];
    self.subjectTextField.tag = 101;
    self.subjectTextField.delegate = self;
    
    //Description TextView
    CGRect textViewFrame = CGRectMake(10.0f, 10.0f, self.view.frame.size.width - 20, 160.0f);
    self.descriptionTextView = [[UITextView alloc] initWithFrame:textViewFrame];
    self.descriptionTextView.returnKeyType = UIReturnKeyDone;
    self.descriptionTextView.backgroundColor = mDelegate_.textFieldColor;
    self.descriptionTextView.font = [UIFont systemFontOfSize:16.0f];
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
    self.priceTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"$$$" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], }];
//    self.priceTextField.backgroundColor = mDelegate_.textFieldColor;
    self.priceTextField.textColor = [UIColor grayColor];
    self.priceTextField.font = [UIFont systemFontOfSize:16.0f];
    self.priceTextField.borderStyle = UITextBorderStyleNone;//UITextBorderStyleRoundedRect;
//    self.priceTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.priceTextField.returnKeyType = UIReturnKeyDone;
    self.priceTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.priceTextField.textAlignment = NSTextAlignmentRight;
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
    
    if(self.priceTextField.text.length >6){
        self.priceTextField.text = [self.priceTextField.text substringWithRange:NSMakeRange(0,6)];
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
                                   if ([self.priceTextField.text integerValue]>9) {
                                       self.priceTextField.text = [self.priceTextField.text substringWithRange:NSMakeRange(0,self.priceTextField.text.length-1)];
                                   }
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
    return newLength <= 35;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //dismissKeyboard
    [self.view endEditing:YES];
    return NO;
}


#pragma mark - gesture

-(void)dismissKeyboard{
    
    [self.view endEditing:YES];
}

-(void)handleSingleTapGesture:(UITapGestureRecognizer *)recognizer {
    
    NSLog(@"Push To RequestPhoto View");
    [self.view endEditing:YES];
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
//        [view addSubview:self.scrollView];
        
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0,self.imageView.bounds.size.height)];
        [view addSubview:self.imageView];
        
        view.backgroundColor = [UIColor blackColor];
        
        
        //lower right corner page number
//        self.pageLabel = [[UILabel alloc]initWithFrame:CGRectZero];
//        if (mDelegate_.mRequestImages.count>0) {
//            [self.pageLabel setText:[NSString stringWithFormat:@"1/%lu",(unsigned long)[mDelegate_.mRequestImages count]]];
//        }else{
//            [self.pageLabel setText:[NSString stringWithFormat:@"N/A"]];
//        }
//
//        [self.pageLabel setTextColor:[UIColor whiteColor]];
//        [self.pageLabel setBackgroundColor:[UIColor clearColor]];
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
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
//    if (section == priceSection) {
//        return 3;
//    }else if (section == preferContactMethodSection){
//        return 1;
//    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    //-------------section 0 categorySection
    //- Category
    //- Subcategory
    //-------------section 1 availableFundsSection
    //- Available Funds
    //- Account Balance
    //-------------section 2 priceSection
    //- Your Price
    //- PriceType
    //-------------section 3 preferContactMethodSection
    //- PreferredContactMethod
    //- Deadline
    //-------------section 4 titleSection
    //- Subject
    //- Description
    
    UITableViewCell *cell=nil;

    if(indexPath.section == categorySection){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:@"RequestTableViewCell"];
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
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
    }else if (indexPath.section == availableFundsSection){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:@"RequestTableViewCell"];
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        
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
            default:
                break;
        }
    }else if (indexPath.section == priceSection){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:@"RequestTableViewCell"];

        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        
        NSString *priceType = self.priceTypeTextField.text;
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Your Price:";
                cell.accessoryView = self.priceTextField;
                break;
            case 1:
                cell.textLabel.text = @"Price Type:";
                cell.detailTextLabel.text = priceType;
                [cell addSubview:self.priceTypeTextField];
                break;
            default:
                break;
        }
    }else if(indexPath.section == preferContactMethodSection){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:@"RequestTableViewCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *preferredContactMethod = self.preferredContactTextField.text;
        NSString *dateString = self.dateTextField.text;
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Prefer Contact:";
                cell.detailTextLabel.text = preferredContactMethod;
                [cell addSubview:self.preferredContactTextField];
                break;
            case 1:
                cell.textLabel.text = @"Deadline:";
                cell.detailTextLabel.text = dateString;//@"Select a Date";
                [cell addSubview:self.dateTextField];
                break;
            default:
                break;
        }

    }else{

        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"RequestTableViewCell"];

        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        
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


#pragma mark - Select Row
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.view endEditing:YES];
    
    if (indexPath.section == priceSection) {
        if (indexPath.row == priceRow) {
            [self.priceTextField becomeFirstResponder];
        }else if(indexPath.row == priceTypeRow){
            
            [self.priceTypeTextField becomeFirstResponder];

        }
    }else if (indexPath.section == preferContactMethodSection){
        if (indexPath.row == preferContactMethodRow) {
            
            [self.preferredContactTextField becomeFirstResponder];
        }else if (indexPath.row == deadlineRow) {
            
            [self.dateTextField becomeFirstResponder];
            
        }
        

    }
}
#pragma mark - UIPickerView
-(void)initialPriceTypePicker
{
    // Initialize Data
    priceTypeArray_ = @[@"Fixed", @"Negotiable"];
    
    // Connect data
    self.priceTypePickerView = [[UIPickerView alloc] init];
    self.priceTypePickerView.dataSource = self;
    self.priceTypePickerView.delegate = self;
    self.priceTypePickerView.tag = priceTypePickerViewTag;
    
    
    CGRect priceTypeTextFieldFrame = CGRectMake(0, 0, 0, textfieldHeight);
    self.priceTypeTextField = [[UITextField alloc] initWithFrame:priceTypeTextFieldFrame];
    self.priceTypeTextField.borderStyle = UITextBorderStyleNone;
    self.priceTypeTextField.text = @"Fixed";
    
    //add picker view to InputView
    [self.priceTypeTextField setInputView:self.priceTypePickerView];
    
    //uitoolbar
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)]; //初始化
    [toolBar setTintColor:[UIColor blackColor]]; //设置颜色
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    
    [toolBar setItems:[NSArray arrayWithObjects:doneBtn, nil]];
    [self.priceTypeTextField setInputAccessoryView:toolBar];
    
}

-(void)initialPreferredContactPicker
{
    // Initialize Data
    preferredContactArray_ = @[@"By Email", @"By Phone"];
    
    // Connect data
    self.preferredContactPickerView = [[UIPickerView alloc] init];
    self.preferredContactPickerView.dataSource = self;
    self.preferredContactPickerView.delegate = self;
    self.preferredContactPickerView.tag = preferredContactPickerViewTag;

    
    CGRect preferedContactTextFieldFrame = CGRectMake(0, 0, 0, textfieldHeight);
    self.preferredContactTextField = [[UITextField alloc] initWithFrame:preferedContactTextFieldFrame];
    self.preferredContactTextField.borderStyle = UITextBorderStyleNone;
    self.preferredContactTextField.text = @"By Email";
    
    //add picker view to InputView
    [self.preferredContactTextField setInputView:self.preferredContactPickerView];
    
    
    //uitoolbar
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)]; //初始化
    [toolBar setTintColor:[UIColor blackColor]]; //设置颜色
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    
    [toolBar setItems:[NSArray arrayWithObjects:doneBtn, nil]];
    [self.preferredContactTextField setInputAccessoryView:toolBar];
}

#pragma mark - UIPicker DataSouce
// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == priceTypePickerViewTag) {
        return priceTypeArray_.count;
    }else{// if (pickerView.tag == preferredContactPickerViewTag){
        return preferredContactArray_.count;
    }
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == priceTypePickerViewTag) {
       return priceTypeArray_[row];
    }else{// if (pickerView.tag == preferredContactPickerViewTag){
        return preferredContactArray_[row];
    }

}

#pragma mark - UIPicker Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
  
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    if (pickerView.tag == priceTypePickerViewTag) {
        //0 = Fixed; 1 = Negotiable;
        NSString *priceTypeString = priceTypeArray_[row];
        cell.detailTextLabel.text = priceTypeString;
        self.priceTypeTextField.text = priceTypeString;
        if (row == 0) {
            negotiable_ = NO;
        }else{
            negotiable_ = YES;
        }
        
    }else if (pickerView.tag == preferredContactPickerViewTag){
        //0 = By Email; 1 = By Phone;
        NSString *preferredContactString = preferredContactArray_[row];
        cell.detailTextLabel.text = preferredContactString;
        self.preferredContactTextField.text = preferredContactString;
        if (row == 0) {
            preferPhone_ = NO;
        }else{
            preferPhone_ = YES;
        }
        
    }
}



#pragma mark - DatePicker
-(void)initialDatePicker
{
    CGRect dateTextFieldFrame = CGRectMake(0, 0, 0, textfieldHeight);
    self.dateTextField = [[UITextField alloc] initWithFrame:dateTextFieldFrame];
    self.dateTextField.borderStyle = UITextBorderStyleNone;//UITextBorderStyleRoundedRect;
    self.dateTextField.text = @"Select a Date";
    
    self.datePickerView = [[UIDatePicker alloc] init];
    self.datePickerView.datePickerMode = UIDatePickerModeDate;
    [self.dateTextField setInputView:self.datePickerView];
    
    //uitoolbar
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)]; //初始化
    [toolBar setTintColor:[UIColor blackColor]]; //设置颜色
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(ShowSelectedDate)];
    
    [toolBar setItems:[NSArray arrayWithObjects:doneBtn, nil]];
    [self.dateTextField setInputAccessoryView:toolBar];
}

-(void)ShowSelectedDate
{
    requestDeadline_ = self.datePickerView.date;
    
    if ([requestDeadline_ compare:[NSDate date]] != NSOrderedAscending) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text = [dateFormatter stringFromDate:requestDeadline_];
        self.dateTextField.text = [dateFormatter stringFromDate:requestDeadline_];
        [self.dateTextField resignFirstResponder];
        
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
        requestDeadline_ = nil;
    }

}

#pragma mark - Navigation
- (IBAction)reviewAction:(id)sender {
    [self dismissKeyboard];
    NSString *priceCheck = self.priceTextField.text;
    NSDate *deadlineCheck = requestDeadline_;
    if ([priceCheck isEqualToString:@""] || deadlineCheck == nil) {
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
      
        //2015.07.13
//        requestDeadline_ =[NSDate date];
        rrtvc.requestDeadline = requestDeadline_;
        rrtvc.negotiable = negotiable_;
        rrtvc.preferPhone = preferPhone_;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
