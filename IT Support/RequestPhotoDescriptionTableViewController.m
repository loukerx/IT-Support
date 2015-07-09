//
//  RequestPhotoDescriptionTableViewController.m
//  IT Support
//
//  Created by Yin Hua on 18/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "RequestPhotoDescriptionTableViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"


@interface RequestPhotoDescriptionTableViewController ()<UIActionSheetDelegate,UIScrollViewDelegate,UITextViewDelegate,UIGestureRecognizerDelegate>
{
    AppDelegate *mDelegate_;
    CGFloat scrollViewHeight_;
    NSInteger displayPhotoIndex_;
    BOOL firstDisplay_;
    MBProgressHUD *HUD_;
}


@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITextView *descriptionTextView;
@property (strong, nonatomic) UILabel *pageLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;


@end

@implementation RequestPhotoDescriptionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //setting
    displayPhotoIndex_ = self.displayPhotoIndex;
    scrollViewHeight_ = self.view.frame.size.width * cellHeightRatio;
    firstDisplay_ = YES;
    //setting color
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.deleteBarButtonItem.tintColor = self.enableEditMode?[UIColor whiteColor]:[UIColor clearColor];
    self.deleteBarButtonItem.enabled = self.enableEditMode;

    
    [self preparePhotosForScrollView];
    [self populateTableViewHeader];
    [self initialCustomView];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.scrollView addGestureRecognizer:tap];

}

-(void)initialCustomView{
    
    //textview
    CGRect textViewFrame = CGRectMake(0, 0, self.view.frame.size.width, 150.0f);
    
    self.descriptionTextView = [[UITextView alloc] initWithFrame:textViewFrame];
    [self.view addSubview:self.descriptionTextView];
    [self.descriptionTextView layoutIfNeeded];
    self.descriptionTextView.backgroundColor = [UIColor whiteColor];// mDelegate_.textFieldColor;
    self.descriptionTextView.font = [UIFont systemFontOfSize:17.0f];
//    self.descriptionTextView.layer.cornerRadius = 5.0f;
//    self.descriptionTextView.layer.borderColor = [mDelegate_.textViewBoardColor CGColor];
//    self.descriptionTextView.layer.borderWidth = 0.6f;
//    self.descriptionTextView.text = @"For additional question, please leave your message.";
    self.descriptionTextView.textColor = [UIColor blackColor];
    self.descriptionTextView.delegate = self;
   
    //depends on different push
    self.descriptionTextView.editable = self.enableEditMode;
    
}

#pragma mark - TextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.descriptionTextView.text isEqualToString:@"For additional description, please leave your message."]) {
        self.descriptionTextView.text = @"";
        self.descriptionTextView.textColor = [UIColor blackColor]; //optional
    }
    [self.descriptionTextView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.descriptionTextView.text isEqualToString:@""]) {
        self.descriptionTextView.text = @"For additional description, please leave your message.";
        self.descriptionTextView.textColor = [UIColor lightGrayColor]; //optional
    }
    [self.descriptionTextView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView{
    
    NSString *imageDescription;
    imageDescription = textView.text;
    [mDelegate_.mRequestImageDescriptions replaceObjectAtIndex:displayPhotoIndex_ withObject:imageDescription];
}

#pragma mark - gesture

-(void)dismissKeyboard{
    if (self.enableEditMode) {
        [self.view endEditing:YES];
    }else{
       [self performSegueWithIdentifier:@"To Image View" sender:self];
    }
 
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


//Define scrollview but populating values is not necessary
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
//进入这个界面时必然执行这个方法
-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    if (firstDisplay_) {
        
        //第一次显示需要指定显示内容，图片位置，说明信息
        [self.scrollView setContentOffset:CGPointMake(self.view.bounds.size.width *displayPhotoIndex_, 0) animated:YES];
        [self.pageLabel setText:[NSString stringWithFormat:@"%ld/%lu",(long)displayPhotoIndex_+1,(unsigned long)[mDelegate_.mRequestImages count]]];
        
        //correct description position
        self.descriptionTextView.text = mDelegate_.mRequestImageDescriptions[displayPhotoIndex_];
        if (self.enableEditMode) {
            if ([self.descriptionTextView.text isEqualToString:@"N/A"]) {
                self.descriptionTextView.text = @"For additional description, please leave your message.";
                self.descriptionTextView.textColor = [UIColor grayColor];
            }else{
                self.descriptionTextView.textColor = [UIColor blackColor]; //optional
            }
        }
    }
    firstDisplay_ = NO;
}


-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    //display scrollview page number
    CGFloat x =  scrollView.contentOffset.x;
    CGFloat width = scrollView.frame.size.width;
    int page = roundf(x/width) + 1;

    if (mDelegate_.mRequestImages.count>0) {
        self.pageLabel.text = [NSString stringWithFormat:@"%d/%lu",page,(unsigned long)[mDelegate_.mRequestImages count]];

        //populate description from appDelegate
        displayPhotoIndex_ = page - 1;
        self.descriptionTextView.text = mDelegate_.mRequestImageDescriptions[displayPhotoIndex_];
        
        if (self.enableEditMode) {
            //value description with correct words
            //set textview responder by descriptions
            //set textview text color by descriptions
            if ([self.descriptionTextView.text isEqualToString:@"N/A"]) {
                self.descriptionTextView.text = @"For additional description, please leave your message.";
                self.descriptionTextView.textColor = [UIColor lightGrayColor];
            }else{
                self.descriptionTextView.textColor = [UIColor blackColor]; //optional
            }
            [self.descriptionTextView resignFirstResponder];
        }
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
    
    return 150;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
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
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                  reuseIdentifier:@"PhotoDescriptionTableViewCell"];
    
    [cell addSubview:self.descriptionTextView];
    //description textview
    return cell;
}
#pragma mark - Button Action
- (IBAction)deletePhotoAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete"
                                                    otherButtonTitles:nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
    
}

#pragma mark - actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            HUD_ = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD_.labelText = @"Processing...";
            
            //delete photo & description from their arrays
            [mDelegate_.mRequestImageDescriptions removeObjectAtIndex:displayPhotoIndex_];
            [mDelegate_.mRequestImages removeObjectAtIndex:displayPhotoIndex_];
            
            //if next photo exists, display it
            if (mDelegate_.mRequestImages.count > displayPhotoIndex_) {
                [self reloadPhotoAndDescriptionData];
                
            }else if (mDelegate_.mRequestImages.count != 0 && mDelegate_.mRequestImages.count == displayPhotoIndex_) {
                //if there is no next photo, display previous one.
                displayPhotoIndex_ --;
            
                [self reloadPhotoAndDescriptionData];

            
            }else{
                //if array is empty, back to uicollectionView
                [self.navigationController popViewControllerAnimated:YES];
                
            }
            break;
        default:
            break;
    }
    
}


-(void)reloadPhotoAndDescriptionData
{
    
    [self.scrollView removeFromSuperview];
    [self preparePhotosForScrollView];
    [self populateTableViewHeader];//add scrollview
    
    //指定显示内容，图片位置，说明信息
    [self.scrollView setContentOffset:CGPointMake(self.view.bounds.size.width *displayPhotoIndex_, 0) animated:YES];
    [self.pageLabel setText:[NSString stringWithFormat:@"%ld/%lu",(long)displayPhotoIndex_+1,(unsigned long)[mDelegate_.mRequestImages count]]];
    
    //correct description position
    self.descriptionTextView.text = mDelegate_.mRequestImageDescriptions[displayPhotoIndex_];
    
    [HUD_ hide:YES];
}




@end

