//
//  TimerViewController.m
//  SafeNightOut
//
//  Created by Evan Yeung on 6/04/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import "TimerViewController.h"

@interface TimerViewController ()

@end

@implementation TimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    countTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(countDownFunc)
                                           userInfo:nil
                                            repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)countDownFunc {
    self.remainingCounts = self.remainingCounts - 1;
    int hour = self.remainingCounts/3600;
    int min = self.remainingCounts/60 - (hour*60);
    int sec = self.remainingCounts - (hour*3600) - (min*60);
    
    NSString *output = [NSString stringWithFormat:@"%2d:%2d:%2d",hour,min,sec];
    _countDown.text = output;
    
    if(self.remainingCounts == 0){
        [countTimer invalidate];
        countTimer = nil;
    }else if(self.remainingCounts < 0)
        
    {
    self.countDown.text = @"Unfortunately you already missed..";
        self.countDown.font = [UIFont fontWithName:@"Chalkduster" size:15];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

*/

//- (IBAction)cancelBtn:(UIButton *)sender {
//     _countDown.text = @"00:00";
//    [countTimer invalidate];
//     countTimer = nil;
//}
@end
