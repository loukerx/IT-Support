//
//  RequestPhotoDescriptionViewController.m
//  IT Support
//
//  Created by Yin Hua on 15/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "RequestPhotoDescriptionViewController.h"
#import "AppDelegate.h"

@interface RequestPhotoDescriptionViewController ()<UIScrollViewDelegate, UITextViewDelegate>
{
    AppDelegate *mDelegate_;
    CGFloat scrollViewHeight_;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITextView *descriptionTextView;



@end

@implementation RequestPhotoDescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //setting

    scrollViewHeight_ = self.view.frame.size.width * cellHeightRatio;
    
//    [self preparePhotosForScrollView];
//    [self initialCustomView];
    
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(dismissKeyboard)];
//    
//    [self.view addGestureRecognizer:tap];
    
}




-(void)initialCustomView{
    
    //textview
    CGRect textViewFrame = CGRectMake(10.0f, scrollViewHeight_, self.view.frame.size.width - 20, 160.0f);

    self.descriptionTextView = [[UITextView alloc] initWithFrame:textViewFrame];
    [self.view addSubview:self.descriptionTextView];
    [self.descriptionTextView layoutIfNeeded];
    self.descriptionTextView.backgroundColor = mDelegate_.textFieldColor;
    self.descriptionTextView.font = [UIFont systemFontOfSize:17.0f];
    self.descriptionTextView.layer.cornerRadius = 5.0f;
    self.descriptionTextView.layer.borderColor = [mDelegate_.textViewBoardColor CGColor];
//    self.descriptionTextView.layer.borderWidth = 0.6f;
    self.descriptionTextView.text = @"For additional question, please leave your message.";
    self.descriptionTextView.textColor = [UIColor lightGrayColor];
    self.descriptionTextView.delegate = self;


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

#pragma mark - gesture

-(void)handleSingleTapGesture:(UIGestureRecognizer *)tapGestureRecognizer{
    //go back to RequestPhotoCollectionViewController
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dismissKeyboard{
    
    [self.view endEditing:YES];
}

#pragma mark - scrollview & tableHeaderView

-(void)preparePhotosForScrollView
{
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, scrollViewHeight_)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    
    [self.view addSubview:self.scrollView];
    [self.scrollView layoutIfNeeded];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    [self.scrollView addGestureRecognizer:singleTapGestureRecognizer];
    
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





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)showDetailAction:(id)sender {
       [self dismissViewControllerAnimated:YES completion:nil];
}
@end
