//
//  UpdatePagesViewController.m
//  IT Support
//
//  Created by Yin Hua on 16/07/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "UpdatePagesViewController.h"
#import "AppDelegate.h"
#import "AppHelper.h"

@interface UpdatePagesViewController ()<UIScrollViewDelegate>
{
    AppDelegate *mDelegate_;
    AppHelper *appHelper_;
    NSMutableArray *updateImages_;

}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation UpdatePagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appHelper_ = [[AppHelper alloc]init];
    
    //ready update images
    updateImages_ = [[NSMutableArray alloc]init];
    for (int num=1; num < 5; num++) {
        [updateImages_ addObject:[UIImage imageNamed:[NSString stringWithFormat:@"page%d",num]]];
    }
    
    //gesture
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollviewSingleTapGesture:)];
    [self.scrollView addGestureRecognizer:singleTapGestureRecognizer];
    
    
    self.scrollView.delegate = self;

    [self preparePageControl];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self prepareScrollViewContent];
}

-(void)preparePageControl
{
    NSInteger pageCount = updateImages_.count;
    
    self.pageControl.currentPageIndicatorTintColor = mDelegate_.clientThemeColor;
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = pageCount;
    
}


#pragma mark - guesture
-(void)scrollviewSingleTapGesture:(UIGestureRecognizer *)tapGestureRecognizer{
    
//    if (updateImages_.count == self.pageControl.currentPage) {
//        
       [appHelper_ initialViewController:@"LoginViewStoryboardID"];
//
//    }
}


#pragma mark - scrollView content

- (void)prepareScrollViewContent
{
    //updateImages exist
    if ([updateImages_ count]>0) {
       
        CGFloat width = self.view.frame.size.width;
        CGFloat height = self.view.frame.size.height;
        self.scrollView.contentSize =  CGSizeMake(width * updateImages_.count,0);
        
        int count = 0;
        
        for(UIImage *image in updateImages_)
        {
            UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
            imageview.contentMode = UIViewContentModeScaleAspectFit;
            imageview.frame = CGRectMake(0, 0, width, height);
            
            UIScrollView *pageScrollView = [[UIScrollView alloc]
                                            initWithFrame:CGRectMake(width * count, 0, width, height)];
            pageScrollView.minimumZoomScale = 1.0f;
            pageScrollView.maximumZoomScale = 2.5f;
            //scrollView.contentSize = CGSizeMake(scrollView.contentSize.width,scrollView.frame.size.height);
            //        pageScrollView.contentSize = CGSizeMake(imageview.frame.size.width, pageScrollView.frame.size.height);
            pageScrollView.contentSize = CGSizeMake(width,height);
            //        pageScrollView.scrollEnabled = NO;
            //        pageScrollView.decelerationRate = 1.0f;
            //        pageScrollView.delegate = self;
            [pageScrollView addSubview:imageview];
            
            [self.scrollView addSubview:pageScrollView];
            count++;
        }
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // First, determine which page is currently visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    // Update the page control
    self.pageControl.currentPage = page;

}

#pragma mark - others

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

@end
