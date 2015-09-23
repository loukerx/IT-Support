//
//  TestLoginViewController.m
//  IT Support
//
//  Created by Yin Hua on 23/09/2015.
//  Copyright © 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "TestLoginViewController.h"
#import "AppDelegate.h"

@interface TestLoginViewController ()<UITextFieldDelegate>
{
    AppDelegate *mDelegate_;
    
    //keyboard animation
    BOOL keyboardISVisible_;
    CGFloat inputViewOriginalY_;
    CGFloat logoImageOriginalY_;
}


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoCenterY;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIView *loginInputView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewCenterY;

@end

@implementation TestLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    mDelegate_ = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    
    
    //add observer for keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    inputViewOriginalY_ = self.loginInputView.frame.origin.y;
}

#pragma mark - guesture
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - textfield animation
-(void)keyboardFrameDidChange:(NSNotification *)notification
{
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardEndFrame.size.height;
    
    //keyboard displays 10 poins below login button
    const int distance = 10;
    CGFloat bottomMargin = self.view.frame.size.height - self.loginInputView.frame.origin.y - self.loginInputView.frame.size.height - distance;
    
    //do or do not to move the view
    CGFloat animationDistance = keyboardHeight - bottomMargin;
    
    //new frame & constrant
    CGRect newFrame = self.loginInputView.frame;
    
    CGFloat newConstant = self.inputViewCenterY.constant;
    
    //move loginInputView
    if (newFrame.origin.y == inputViewOriginalY_ && animationDistance > 0) {
        newFrame.origin.y -= animationDistance;
        newConstant -= animationDistance;
    }
    
    //move loginInputView back to Original Position
    if (newFrame.origin.y != inputViewOriginalY_ && self.view.frame.size.height == keyboardEndFrame.origin.y) {
        newFrame.origin.y = inputViewOriginalY_;
        newConstant = 0;
    }
    
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] integerValue];
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:
//     UIViewAnimationOptionCurveLinear
     UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         //have to update both frame and constraint
                         [self.inputViewCenterY setConstant: newConstant];
                         self.loginInputView.frame = newFrame;
                         
                     } completion:nil];
    
    
    
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
