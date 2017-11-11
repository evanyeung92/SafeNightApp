//
//  SafetyDetailViewController.m
//  SafeNightOut
//
//  Created by Evan Yeung on 18/04/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import "SafetyDetailViewController.h"

@interface SafetyDetailViewController ()

@end

@implementation SafetyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"http://safenightout.azurewebsites.net/TypeInfo.php"];
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    _typeInfo= [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    
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
