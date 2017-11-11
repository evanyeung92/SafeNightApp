//
//  ProfileViewController.h
//  SafeNightOut
//
//  Created by Evan Yeung on 8/05/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *genderTable;
@property (weak, nonatomic) IBOutlet UITextField *weight;
- (IBAction)saveBtn:(UIButton *)sender;

@end
