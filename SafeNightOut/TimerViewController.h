//
//  TimerViewController.h
//  SafeNightOut
//
//  Created by Evan Yeung on 6/04/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerViewController : UIViewController


{
    NSTimer *countTimer;
}

@property (weak, nonatomic) IBOutlet UIButton *cancel;

@property (weak, nonatomic) IBOutlet UILabel *countDown;
@property(nonatomic, assign) int remainingCounts;
//- (IBAction)cancelBtn:(UIButton *)sender;

@end
