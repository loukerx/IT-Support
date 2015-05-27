//
//  RequestPhotoDescriptionTableViewController.h
//  IT Support
//
//  Created by Yin Hua on 18/05/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestPhotoDescriptionTableViewController : UITableViewController

@property (nonatomic) BOOL enableEditMode;
@property (nonatomic) NSInteger displayPhotoIndex;


- (IBAction)deletePhotoAction:(id)sender;



@end
