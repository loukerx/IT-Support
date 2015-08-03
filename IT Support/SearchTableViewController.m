//
//  SearchTableViewController.m
//  IT Support
//
//  Created by Yin Hua on 27/07/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "SearchTableViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "AppHelper.h"


@interface SearchTableViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    AppDelegate *mDelegate_;
    AppHelper *appHelper_;
    MBProgressHUD *HUD_;
    
    NSDate *dealine_;
    
    //data
    NSArray *categoryArray_;
    NSArray *levelOneCategoryArray_;
//    NSMutableDictionary *levelTowCategoryDictionary_;
    NSMutableArray *levelTwoCategoryArray_;
//    NSArray *subcategoryArray_;
//    NSMutableArray *tableData_;
    
    //picker
    NSString *categoryID_;
}

@property (strong, nonatomic) UITextField *titleTextField;

//datepicker
@property (strong, nonatomic) UIDatePicker *deadlinePickerView;
@property (strong, nonatomic) UITextField *deadlineTextField;
@property (strong, nonatomic) UIPickerView *categoryPickerView;
@property (strong, nonatomic) UITextField *categoryTextField;




@property (weak, nonatomic) IBOutlet UIBarButtonItem *resetBarButtonItem;


@end



//height
#define tableRowHeight 44.0f
#define textfieldHeight tableRowHeight - 6

// Configure the cell...
//-------------section titleSection 0
//- By Title
//-------------section deadlineSection 1
//- By Deadline
//-------------section categorySection 2

#define titleSection 0
#define titleRow 0

#define deadlineSection 1
#define deadlineRow 0

#define categorySection 2
#define categoryRow 0

//picker
#define categoryPickerViewTag 1001
#define levelOneComponent 0
#define levelTowComponent 1

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = [[UIApplication sharedApplication] delegate];
    appHelper_ = [[AppHelper alloc]init];
    
    //setting color
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //initial
    [self initialCustomView];
    [self initialDatePicker];
    [self initialPickerArrays];
    [self initialCategoryPicker];

    categoryID_=nil;
    
    //dismissKeyboard
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(dismissKeyboard)];
//
//    [self.tableView addGestureRecognizer:tap];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
}

#pragma mark initial custom methods
-(void)initialPickerArrays{
    
    //判断是否已经下载过最新categoryList
    if (mDelegate_.categoryListArray.count>0) {

        levelOneCategoryArray_ = mDelegate_.categoryListArray;
        NSString *dicKeyForSubcategory = @"categoryID[1]";
        levelTwoCategoryArray_ =[[NSMutableArray alloc] initWithArray:[mDelegate_.subcategoryListDictionary objectForKey:dicKeyForSubcategory]];
        
    }else{
        
        [self prepareCategoryList];
    }
}

-(void)initialCustomView{
    //Title TextField
    CGRect titleTextFieldFrame = CGRectMake(0, 0, 150, textfieldHeight);
    self.titleTextField = [[UITextField alloc] initWithFrame:titleTextFieldFrame];
    self.titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Any" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], }];
//    self.titleTextField.backgroundColor = mDelegate_.textFieldColor;
    self.titleTextField.textColor = [UIColor blackColor];
    self.titleTextField.font = [UIFont systemFontOfSize:16.0f];
//    self.titleTextField.borderStyle = UITextBorderStyleRoundedRect;
//    self.titleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.titleTextField.returnKeyType = UIReturnKeyDone;
    self.titleTextField.textAlignment = NSTextAlignmentRight;
    self.titleTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.titleTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    
    self.titleTextField.text = self.searchTitle.length>0?self.searchTitle:@"";
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.subjectTextField];
//    self.titleTextField.tag = 101;
//    self.titleTextField.delegate = self;
}

-(void)dismissKeyboard{
    
    [self.view endEditing:YES];
}

#pragma mark - action
- (IBAction)resetAction:(id)sender {
    
    NSLog(@"categoryID:%@",categoryID_);
    NSLog(@"title:%@",self.titleTextField.text);
    NSLog(@"deadline:%@",dealine_);
    
    self.searchTitle = self.titleTextField.text;
    self.searchDueDate = dealine_;
    self.searchCategoryID = categoryID_;
    
    [self performSegueWithIdentifier:@"Unwind From SearchTableView" sender:self];
    
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
// Get the new view controller using [segue destinationViewController].
// Pass the selected object to the new view controller.
}


#pragma mark - Table view data source
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row == [tableData_ count]) {
//        return 44;
//    }
    return tableRowHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    //-------------section titleSection 0
    //- By Title
    //-------------section deadlineSection 1
    //- By Deadline
    //-------------section categorySection 2
    //- By Category
    
    NSString *cellidentity = @"SearchTableViewCell";
    UITableViewCell *cell=nil;
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                  reuseIdentifier:cellidentity];
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    
    if(indexPath.section == titleSection){
        
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
//                                      reuseIdentifier:cellidentity];
        
        
        
        
        cell.textLabel.text = @"Title Contains:";
        cell.accessoryView = self.titleTextField;
        
    }else if(indexPath.section == deadlineSection){
        
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
//                                      reuseIdentifier:cellidentity];
        
        cell.textLabel.text = @"Before Deadline:";
        cell.detailTextLabel.text = @"Any";
        [cell addSubview:self.deadlineTextField];
        
        
    }else if(indexPath.section == categorySection){
        

        
        cell.textLabel.text = @"By Category:";
        cell.detailTextLabel.text = @"Any";
        [cell addSubview:self.categoryTextField];
    }
    
    return cell;
}

#pragma mark - TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.view endEditing:YES];
    
    if (indexPath.section == deadlineSection) {
        [self.deadlineTextField becomeFirstResponder];
    }else if (indexPath.section == categorySection){
        [self.categoryTextField becomeFirstResponder];
        
        //display first name
        NSDictionary *dic = levelTwoCategoryArray_[0];
        categoryID_ = [NSString stringWithFormat:@"%@",[dic valueForKey:@"RequestCategoryID"]];
        
        //display on cell
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[dic valueForKey:@"Name"]];
    }
}


#pragma mark - DatePicker
-(void)initialDatePicker
{
    CGRect dateTextFieldFrame = CGRectMake(0, 0, 0, textfieldHeight);
    self.deadlineTextField = [[UITextField alloc] initWithFrame:dateTextFieldFrame];
    self.deadlineTextField.borderStyle = UITextBorderStyleNone;//UITextBorderStyleRoundedRect;
    self.deadlineTextField.text = @"Select a Date";
    
    self.deadlinePickerView = [[UIDatePicker alloc] init];
    self.deadlinePickerView.datePickerMode = UIDatePickerModeDate;
    [self.deadlineTextField setInputView:self.deadlinePickerView];
    
    //uitoolbar
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)]; //初始化
    [toolBar setTintColor:[UIColor blackColor]]; //设置颜色
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(ShowSelectedDate)];
    
    [toolBar setItems:[NSArray arrayWithObjects:doneBtn, nil]];
    [self.deadlineTextField setInputAccessoryView:toolBar];
}

-(void)ShowSelectedDate
{
    dealine_ = self.deadlinePickerView.date;
    
//    if ([dealine_ compare:[NSDate date]] != NSOrderedAscending) {
    
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text = [dateFormatter stringFromDate:dealine_];
        self.deadlineTextField.text = [dateFormatter stringFromDate:dealine_];
        [self.deadlineTextField resignFirstResponder];
        
//    }else{
//        UIAlertController *alert =
//        [UIAlertController alertControllerWithTitle:@"Date Error!"
//                                            message:@"Please select a date after today."
//                                     preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction *okAction =
//        [UIAlertAction actionWithTitle:@"OK"
//                                 style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction *action) {
//                               }];
//        
//        [alert addAction:okAction];
//        [self presentViewController:alert animated:YES completion:nil];
//        
//        //clear requestDeadline_
//        dealine_ = nil;
//    }
}
#pragma mark - UIPickerView
-(void)initialCategoryPicker
{
    // Initialize Data
//    categoryArray_ = @[@"Fixed", @"Negotiable"];
    
    // Connect data
    self.categoryPickerView = [[UIPickerView alloc] init];
    self.categoryPickerView.dataSource = self;
    self.categoryPickerView.delegate = self;
    self.categoryPickerView.tag = categoryPickerViewTag;
    
    
    CGRect priceTypeTextFieldFrame = CGRectMake(0, 0, 0, textfieldHeight);
    self.categoryTextField = [[UITextField alloc] initWithFrame:priceTypeTextFieldFrame];
    self.categoryTextField.borderStyle = UITextBorderStyleNone;
    self.categoryTextField.text = @"Fixed";
    
    //add picker view to InputView
    [self.categoryTextField setInputView:self.categoryPickerView];
    
    //uitoolbar
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)]; //初始化
    [toolBar setTintColor:[UIColor blackColor]]; //设置颜色
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    
    [toolBar setItems:[NSArray arrayWithObjects:doneBtn, nil]];
    [self.categoryTextField setInputAccessoryView:toolBar];
    
}

#pragma mark - UIPicker DataSouce
// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{

    if (component == levelOneComponent) {
         return levelOneCategoryArray_.count;
    }else{
        
        return levelTwoCategoryArray_.count;

    }

}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSDictionary *dic;
    if (component == levelOneComponent) {
        
        dic = levelOneCategoryArray_[row];
        NSString *returnString = [NSString stringWithFormat:@"%@",[dic valueForKey:@"Name"]];
        return returnString;
    }else{
        
        dic = levelTwoCategoryArray_[row];
        NSString *returnString = [NSString stringWithFormat:@"%@",[dic valueForKey:@"Name"]];
        return returnString;
    }
    
}

#pragma mark - UIPicker Delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

//        Level = 1;
//        Name = Website;
//        ParentID = 0;
//        RequestCategoryID = 1;
    
    NSInteger selectedLevelTwoCategoryRow = 0;
    NSDictionary *dic;
    
    if (component == levelOneComponent) {
        
        dic = levelOneCategoryArray_[row];

        //change level two category
        NSString *dicKeyForSubcategory = [NSString stringWithFormat:@"categoryID[%@]",[dic valueForKey:@"RequestCategoryID"]];
        levelTwoCategoryArray_ =[[NSMutableArray alloc] initWithArray:[mDelegate_.subcategoryListDictionary objectForKey:dicKeyForSubcategory]];
        
        //others
        if (levelTwoCategoryArray_.count==0) {
            NSDictionary *dic = @{@"Name" : @"Others",
                                  @"RequestCategoryID" : @"5"
                                  };
            [levelTwoCategoryArray_ addObject:dic];
        }
        
        [self.categoryPickerView reloadComponent:levelTowComponent];
    
    }else{
        selectedLevelTwoCategoryRow = row;
    }
    
    //select level two category
    dic = levelTwoCategoryArray_[selectedLevelTwoCategoryRow];
    categoryID_ = [NSString stringWithFormat:@"%@",[dic valueForKey:@"RequestCategoryID"]];
    
    //display on cell
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[dic valueForKey:@"Name"]];

}


#pragma mark - retrieving data
-(void) prepareCategoryList
{
    
    //loading HUD
    HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD_.labelText = @"Progressing...";
    
    NSLog(@"retrieving category list data");
    NSURL *baseURL = [NSURL URLWithString:AWSLinkURL];
    
    NSDictionary *parameters = @{};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:mDelegate_.userEmail password:mDelegate_.userToken];
    
    //clientID 放在parameters中
    [manager GET:@"/ITSupportService/API/Requestcategory" parameters:parameters  success:^(NSURLSessionDataTask *task, id responseObject) {
 
        [HUD_ hide:YES];
        NSLog(@"%@",responseObject);
        
        //convert to NSDictionary
        NSDictionary *responseDictionary = responseObject;
        NSString *responseStatus =[NSString stringWithFormat:@"%@",[responseDictionary valueForKey:@"Status"]];
        // 1 == success, 0 == fail
        if ([responseStatus isEqualToString:@"1"]) {
            
            categoryArray_ =[[NSArray alloc]initWithArray:[responseDictionary valueForKey:@"Result"]];
            
            //initial array
            levelOneCategoryArray_ = [appHelper_ convertCategoryArray:categoryArray_];
            
            //select default level two category
            NSString *dicKeyForSubcategory = @"categoryID[1]";
            levelTwoCategoryArray_ =[[NSMutableArray alloc] initWithArray:[mDelegate_.subcategoryListDictionary objectForKey:dicKeyForSubcategory]];
            
            
            NSLog(@"%@",levelOneCategoryArray_);
            NSLog(@"%@",levelTwoCategoryArray_);
            [self.categoryPickerView reloadAllComponents];
//            NSLog(@"Retreved category List Data");

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
        
        [HUD_ hide:YES];
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Error Retrieving Categories"
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

#pragma mark - others
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
