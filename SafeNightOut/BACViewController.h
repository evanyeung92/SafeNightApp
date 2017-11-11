//
//  BACViewController.h
//  SafeNight
//
//  Created by Evan Yeung on 20/03/2016.
//  Copyright (c) 2016 Evan Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BACViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *drinkTable;
@property (weak, nonatomic) IBOutlet UILabel *stdDrinkNumber;
@property (weak, nonatomic) IBOutlet UIPickerView *hourPicker;
- (IBAction)profileBtn:(UIBarButtonItem *)sender;

- (IBAction)testBtn:(UIButton *)sender;
- (IBAction)resetBtn:(UIButton *)sender;

@property (strong, nonatomic) UIButton *add1;
@property (strong, nonatomic) UIButton *add2;
@property (strong, nonatomic) UIButton *add3;

@end
