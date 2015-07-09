//
//  RequestPhotoCollectionViewController.m
//  IT Support
//
//  Created by Yin Hua on 15/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "RequestPhotoCollectionViewController.h"
#import "AppDelegate.h"
#import "PhotoCollectionViewCell.h"
#import "RequestPhotoDescriptionTableViewController.h"


@interface RequestPhotoCollectionViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    AppDelegate *mDelegate_;
    CGFloat scrollViewHeight_;
    NSInteger displayPhotoIndex_;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *addPhotoButton;



@end

@implementation RequestPhotoCollectionViewController

static NSString * const reuseIdentifier = @"RequestPhotoCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //setting
    scrollViewHeight_ = self.view.frame.size.width * cellHeightRatio;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    [self addButtonOnView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    // Register cell classes
    UINib *cellNib = [UINib nibWithNibName:@"PhotoCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:reuseIdentifier];
    
    
    [self.collectionView reloadData];
}

#pragma mark - Add Photo Button
-(void)addButtonOnView{
    //add photo button
    self.addPhotoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.addPhotoButton addTarget:self
                            action:@selector(addPhotoButton:)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addPhotoButton];
    self.addPhotoButton.backgroundColor = mDelegate_.appThemeColor;
    self.addPhotoButton.alpha = 0.7;
    [self.addPhotoButton setTitle:@"Add Photo" forState:UIControlStateNormal];
    [self.addPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.addPhotoButton.frame = CGRectMake(0, 0, 130, 30);
    self.addPhotoButton.center = CGPointMake(self.view.bounds.size.width*0.5, self.view.bounds.size.height - 30);
}

#pragma mark - ButtonAction
 - (void)addPhotoButton:(UIButton *)sender{
     
     if (mDelegate_.mRequestImages.count>8) {
         UIAlertController *alert =
         [UIAlertController alertControllerWithTitle:@"Error!!"
                                             message:@"Only 9 Photos In One Request"
                                      preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *okAction =
         [UIAlertAction actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {}];
         [alert addAction:okAction];
         [self presentViewController:alert animated:YES completion:nil];
         
     }else{
         
         UIAlertController* alertController =
         [UIAlertController alertControllerWithTitle:nil
                                             message:nil
                                      preferredStyle:UIAlertControllerStyleActionSheet];
         
         UIAlertAction* cancelAction =
         [UIAlertAction actionWithTitle:@"Cancel"
                                  style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction * action) {}];
         UIAlertAction *takePhotoAction =
         [UIAlertAction actionWithTitle:@"Take Photo"
                                  style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
          {

              [self takePhoto];
              
          }];
         UIAlertAction *selectPhotoAction =
         [UIAlertAction actionWithTitle:@"Select Photo"
                                  style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
          {
              [self selectPhoto];
              
          }];
         
         [alertController addAction:cancelAction];
         [alertController addAction:takePhotoAction];
         [alertController addAction:selectPhotoAction];
         
         UIPopoverPresentationController *popover = alertController.popoverPresentationController;
         if (popover)
         {
             popover.sourceView = sender;
             popover.sourceRect = sender.bounds;
             popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
         }
         
         
         [self presentViewController:alertController animated:YES completion:nil];
     }
 }

-(void)takePhoto
{
    // check if the device has a built in camera
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Error!!"
                                            message:@"Device has no camera"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {}];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
//        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = NO;
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

-(void)selectPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:picker animated:YES completion:NULL];
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

     UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
//    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    NSData *worstImageData = UIImageJPEGRepresentation(originalImage, 0.1);
    NSLog(@"Size of Image(kb):%lu",(unsigned long)[worstImageData length]/1024);
//    NSData *bestImageData = UIImageJPEGRepresentation(originalImage, 1.0);
//    NSLog(@"Size of Image(kb):%lu",(unsigned long)[bestImageData length]/1024);
    UIImage *resizedImage = [UIImage imageWithData:worstImageData];

    [mDelegate_.mRequestImages addObject:resizedImage];
    [mDelegate_.mRequestImageDescriptions addObject:@"N/A"];

    [self.collectionView reloadData];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - scrollview & collectionView Header
//add scrollview in collectionview headerview
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    if (kind == UICollectionElementKindSectionHeader) {
//        
//        UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
//        
//        if (reusableview==nil) {
//            reusableview=[[UICollectionReusableView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, self.view.bounds.size.height*0.4)];
//        }
//        //
//        //        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//        //        label.text=[NSString stringWithFormat:@"Recipe Group #%li", indexPath.section + 1];
//        
//        [reusableview addSubview:self.scrollView];
//        return reusableview;
//    }
//    return nil;
//}
//
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
//    
//    CGSize headerSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height*0.6);
//    return headerSize;
//}



#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [mDelegate_.mRequestImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (mDelegate_.mRequestImages.count>0) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage: mDelegate_.mRequestImages[indexPath.row]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
//        imageView.image = mDelegate_.mRequestImages[indexPath.row];
//        [cell.contentView addSubview:imageView];
//        if (indexPath.row == 0) {
//            cell.imageView.image = [UIImage imageNamed:@"room1.jpg"];
//        }else{
            cell.imageView.image = imageView.image;
//        }

    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = self.view.bounds.size.width*0.332;
    return CGSizeMake(width, width);
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    displayPhotoIndex_ = indexPath.row;
    [self performSegueWithIdentifier:@"To RequestPhotoDescription TableView" sender:self];

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    RequestPhotoDescriptionTableViewController *rpdtvc = [segue destinationViewController];
    rpdtvc.displayPhotoIndex = displayPhotoIndex_;
    rpdtvc.enableEditMode = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
