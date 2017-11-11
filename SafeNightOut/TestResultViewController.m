//
//  TestResultViewController.m
//  SafeNightOut
//
//  Created by Evan Yeung on 8/05/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import "TestResultViewController.h"

@interface TestResultViewController ()
@property (nonatomic, copy) NSArray *effectInfo;
@property (nonatomic, copy) NSArray *suggestionInfo;
@end

@implementation TestResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [(UIScrollView *)self.view setContentSize:CGSizeMake(320, 700)];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setTranslucent:NO];
    
    if(self.bacLevel < 0){
        self.bacLabel.text = @"Your body appears normal.";
    }else{
        NSString *bacString = [NSString stringWithFormat:@"%.2f", self.bacLevel];
        self.bacLabel.text = bacString;
    }
    [self displayEffectText];
    [self displaySuggestionText];
    
    [self.effectText setBackgroundColor:[UIColor colorWithWhite:0.10 alpha:0.05]];
    [self.suggestionText setBackgroundColor:[UIColor colorWithWhite:0.15 alpha:0.05]];
    
    UIImage* image3 = [UIImage imageNamed:@"InfoBtn"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width, image3.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(showInfo)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.rightBarButtonItem = btnSave;
    
    
}

-(void)displayEffectText{
    NSString *string1 = @"1. Reduced ability to see or locate moving lights correctly\n2. Reduced ability to judge distances\n3. Increased tendency to take risks\n4. Decreased ability to respond to several stimuli";
    
    NSString *string2 = @"1. Twice as likely to have a crash as before they started drinking\n2. Further reduction in your ability to judge distances\n3. Impaired sensitivity to red lights\n4. Slower reactions\n5. Shorter concentration span";
    NSString *string3 = @"Five times more likely to have a crash than before you started drinking";
    NSString *string4 = @"1. Ten times more likely to have a crash\n2. Reckless driving\n3. Impaired peripheral vision\n4. Impaired perception of obstacles\n5. Overestimate abilities";
    
    
    self.effectInfo = [[NSArray alloc]initWithObjects:string1,string2,string3,string4, nil];
    if(self.bacLevel < 0.02 && self.bacLevel > 0)
        self.effectText.text = @"Your body appears normal";
    if(0.02 < self.bacLevel && self.bacLevel < 0.05)
        self.effectText.text = [self.effectInfo objectAtIndex:0];
    if(0.05 <= self.bacLevel && self.bacLevel < 0.08)
        self.effectText.text = [self.effectInfo objectAtIndex:1];
    if(self.bacLevel ==0.08)
        self.effectText.text = [self.effectInfo objectAtIndex:2];
    if(0.08 < self.bacLevel && self.bacLevel < 0.12)
        self.effectText.text = [self.effectInfo objectAtIndex:3];
    if( self.bacLevel >= 0.12)
        self.effectText.text = @"You are too drunk to drive";

}

-(void)displaySuggestionText{
    NSString *string1 = @"Australia's legal limit set at 0.05 BAC level. Learners and probationary license-holders must have 0.00 BAC.\n\nYour test result seems fine, if you decide to drive, remember to drive slow and be careful.";
    
    NSString *string2 = @"Australia's legal limit set at 0.05 BAC level. Learners and probationary license-holders must have 0.00 BAC.\n\nWe suggest you not to drive, take some rest, your body needs more time!";
    NSString *string3 = @"Australia's legal limit set at 0.05 BAC level. Learners and probationary license-holders must have 0.00 BAC.\n\nYour BAC level is too high, we suggest you to stop drinking now, and do not drive! ";
    self.suggestionInfo = [[NSArray alloc]initWithObjects:string1,string2,string3, nil];
    if(self.bacLevel < 0.05 &&self.bacLevel > 0)
        self.suggestionText.text = [self.suggestionInfo objectAtIndex:0];
    if(self.bacLevel < 0.08 && self.bacLevel >= 0.05)
        self.suggestionText.text = [self.suggestionInfo objectAtIndex:1];
    if(self.bacLevel >= 0.08)
        self.suggestionText.text = [self.suggestionInfo objectAtIndex:2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showInfo {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Declaration" message:@"This function is only provided for BAC estimation, the reuslt may be inaccurate due to many factors of influence. The test results should not be considered as your legal evidence to drive after drinking but only advices." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Agree" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    UIView *subView1 = alert.view.subviews[0];
    UIView *subView2 = subView1.subviews[0];
    UIView *subView3 = subView2.subviews[0];
    UIView *subView4 = subView3.subviews[0];
    UIView *subView5 = subView4.subviews[0];
    
    UILabel *title = subView5.subviews[0];
    UILabel *message = subView5.subviews[1];
    
    title.textAlignment = NSTextAlignmentCenter;
    message.textAlignment = NSTextAlignmentJustified;
    message.lineBreakMode = UILineBreakModeCharacterWrap;
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
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
