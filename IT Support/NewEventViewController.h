//
//  NewEventViewController.h
//  IT Support
//
//  Created by Yin Hua on 22/07/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewEventViewController : UIViewController


@property (strong, nonatomic) NSDictionary *requestObject;


- (IBAction)cancelAction:(id)sender;

- (IBAction)postAction:(UIBarButtonItem *)sender;


@end
