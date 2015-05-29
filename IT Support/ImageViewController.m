//
//  ImageViewController.m
//  IT Support
//
//  Created by Yin Hua on 29/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "ImageViewController.h"
#import "AppDelegate.h"

@interface ImageViewController ()<UIScrollViewDelegate>
{
    AppDelegate *mDelegate_;
    UIImageView *imageView_;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //guesture
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [self prepareScrollViewContent];
}

#pragma mark - Guesture
-(void)doSingleTap:(UITapGestureRecognizer *)tapGestureRecognizer{
    if (tapGestureRecognizer.numberOfTouches == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)doDoubleTap:(UITapGestureRecognizer *)tapGestureRecognizer{
    
    int page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    UIScrollView *pageScrollView =[[UIScrollView alloc]init];
    pageScrollView = [[self.scrollView subviews] objectAtIndex:page];
    
    //    pageScrollView.center = CGPointMake(self.view.bounds.size.width*0.5, self.view.bounds.size.height*0.5);
    if(pageScrollView.zoomScale > pageScrollView.minimumZoomScale){
        [pageScrollView setZoomScale:pageScrollView.minimumZoomScale animated:YES];
        
    }
    else{
        [pageScrollView setZoomScale:pageScrollView.maximumZoomScale animated:YES];
    }
}

#pragma mark - scrollView delegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return [[scrollView subviews] objectAtIndex:0];
}

#pragma mark - scrollView content

- (void)prepareScrollViewContent
{
    
    NSArray *photos = [NSArray arrayWithArray: mDelegate_.mRequestImages];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    self.scrollView.contentSize =  CGSizeMake(width * photos.count,0);
    
    int count = 0;
    
    for(UIImage *image in photos)
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
        pageScrollView.decelerationRate = 1.0f;
        pageScrollView.delegate = self;
        [pageScrollView addSubview:imageview];
        
        [self.scrollView addSubview:pageScrollView];
        count++;
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

@end
