//
//  ProfileViewController.m
//  SafeNightOut
//
//  Created by Evan Yeung on 8/05/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController (){
    NSIndexPath *viewLoadSelectedRow;
}
@property int selectedRow;
@property int weightInt;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.genderTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    self.weight.inputAccessoryView = numberToolbar;


}

-(void)viewWillAppear:(BOOL)animated {
    int theGenderInt = [[NSUserDefaults standardUserDefaults] integerForKey:@"gender"];
    int theWeightInt = [[NSUserDefaults standardUserDefaults] integerForKey:@"weight"];
    NSString *weightString = [NSString stringWithFormat:@"%d", theWeightInt];
    NSLog(@"%d",theGenderInt);
    
    self.selectedRow = theGenderInt;
    self.weight.text = weightString;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doneWithNumberPad{
    [self.weight resignFirstResponder];
}

//table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gender"];
    if(indexPath.row == 0){
    cell.textLabel.text = @"Male";
    cell.imageView.image = [UIImage imageNamed:@"Business-Businessman-icon"];
    }
    else{
    cell.textLabel.text = @"Female";
    cell.imageView.image = [UIImage imageNamed:@"student-girl-512"];
    }
    if(indexPath.row == self.selectedRow){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedRow = indexPath.row;
    [self.genderTable reloadData];
   // NSLog(@"%d",self.selectedRow);
}

- (IBAction)saveBtn:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Profile" message:@"Your profile has been saved" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"OK is called");
    }];
    
    [alert addAction:okButton];
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    self.weightInt = self.weight.text.integerValue;
    if(self.weight.text.integerValue > 300){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Validation" message:@"Please enter a validate weight" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"OK is called");
        }];
        
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
        
    [defaults setInteger:self.selectedRow forKey:@"gender"];
    [defaults setInteger:self.weightInt  forKey:@"weight"];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}
@end
