//
//  TermsAndPolicyViewController.m
//  IT Support
//
//  Created by Yin Hua on 20/07/2015.
//  Copyright (c) 2015 IT Express Pro Pty Ltd. All rights reserved.
//

#import "TermsAndPolicyViewController.h"

@interface TermsAndPolicyViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

//from AboutTableViewController
#define privacyPolicyRow 2
#define TermsOFUseRow 3


@implementation TermsAndPolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Privacy Policy.txt
    //Terms of Use.txt
    if (self.rowNumber == privacyPolicyRow) {
        [self displayPolicyOnTextView:@"Privacy Policy"];
    }else if (self.rowNumber == TermsOFUseRow){
        [self displayPolicyOnTextView:@"Terms of Use"];
    }
    
    [self.textView scrollRangeToVisible:NSMakeRange(0, 0)];

}


-(void)displayPolicyOnTextView:(NSString *)fileName
{
 
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    if (filePath) {
        
        NSString *content = [[NSString alloc] initWithContentsOfFile:filePath
                                                        usedEncoding:nil
                                                               error:nil];
        
        self.textView.text = content;
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
