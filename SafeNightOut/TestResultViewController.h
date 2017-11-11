//
//  TestResultViewController.h
//  SafeNightOut
//
//  Created by Evan Yeung on 8/05/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestResultViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *bacLabel;

@property (weak, nonatomic) IBOutlet UITextView *effectText;
@property (weak, nonatomic) IBOutlet UITextView *suggestionText;

@property double bacLevel;
@end
