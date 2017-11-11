//
//  BACViewController.m
//  SafeNight
//
//  Created by Evan Yeung on 20/03/2016.
//  Copyright (c) 2016 Evan Yeung. All rights reserved.
//

#import "BACViewController.h"
#import "ParallaxHeaderView.h"
#import "ExpandingCell.h"
#import "ProfileViewController.h"
#import "TestResultViewController.h"

@interface BACViewController () <UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource>{
    int selectedIndex;
    NSMutableArray *drinkClassArray;
    NSArray *classImageArray;
    NSArray *hourArray;
    double drinkHours;
}
@property (nonatomic, strong) UIImageView *headerImageView;
@property double standardDrink;


@end

@implementation BACViewController
@synthesize hourPicker,add1,add2,add3;

- (void)viewDidLoad {
    [super viewDidLoad];
    



    [self layoutHeaderImageView];
    
    selectedIndex = -1;
    
    drinkClassArray = [[NSMutableArray alloc]initWithObjects:@"Beer",@"Spirit",@"Wine",@"Champagne", nil];
    
    classImageArray = [[NSArray alloc]initWithObjects:@"beerImg",@"spiritImg",@"wineImg",@"champagneImg", nil];
    
    hourArray = [[NSArray alloc]initWithObjects:@"0.5 Hour",@"1 Hour",@"1.5 Hours",@"2 Hours",@"2.5 Hours",@"3 Hours",@"3.5 Hours",@"4 Hours",@"4.5 Hours",@"5 Hours", nil];
    

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//picker view datasource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return hourArray.count;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* label = (UILabel*)view;
    if (view == nil){
        label= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.hourPicker.frame.size.width, 44)];
        
        label.textAlignment = UITextAlignmentRight;
    }
    label.text = [hourArray objectAtIndex:row];
    return label;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (row) {
        case 0:
            drinkHours = 0.5;
            break;
        case 1:
            drinkHours = 1.0;
            break;
        case 2:
            drinkHours = 1.5;
            break;
        case 3:
            drinkHours = 2.0;
            break;
        case 4:
            drinkHours = 2.5;
            break;
        case 5:
            drinkHours = 3.0;
            break;
        case 6:
            drinkHours = 3.5;
            break;
        case 7:
            drinkHours = 4.0;
            break;
        case 8:
            drinkHours = 4.5;
            break;
        case 9:
            drinkHours = 5.0;
            break;
        default:
            break;
    }
    NSLog(@"%.1f",drinkHours);
}


- (void)viewDidAppear:(BOOL)animated
{
    [(ParallaxHeaderView *)self.drinkTable.tableHeaderView refreshBlurViewForNewImage];
    [super viewDidAppear:animated];
}

//table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// tableView header UI
- (void)layoutHeaderImageView {
    
    ParallaxHeaderView *headerView = [ParallaxHeaderView parallaxHeaderViewWithImage:[UIImage imageNamed:@"drink"] forSize:CGSizeMake(self.drinkTable.frame.size.width, 150)];
    headerView.headerTitleLabel.text = @"Enjoy Drinking With Safety";
    
    self.drinkTable.tableHeaderView = headerView;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.drinkTable)
    {
        // pass the current offset of the UITableView so that the ParallaxHeaderView layouts the subViews.
        [(ParallaxHeaderView *)self.drinkTable.tableHeaderView layoutHeaderViewForScrollViewOffset:scrollView.contentOffset];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of time zones in the region for the specified section.
    return drinkClassArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"expandingCell";
    ExpandingCell *cell = (ExpandingCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    static NSString *MyIdentifier2 = @"expandingCell2";
    ExpandingCell *cell2 = (ExpandingCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier2];
    
    static NSString *MyIdentifier3 = @"expandingCell3";
    ExpandingCell *cell3 = (ExpandingCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier3];
    
    static NSString *MyIdentifier4 = @"expandingCell4";
    ExpandingCell *cell4 = (ExpandingCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier4];
    
    
    switch (indexPath.row) {
        case 0:
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ExpandindCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            if(selectedIndex == indexPath.row){
                cell.contentView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.25];
            }
            else{
                cell.contentView.backgroundColor = [UIColor whiteColor];
            }
            
            cell.className.text = [drinkClassArray objectAtIndex:0];
            cell.classImage.image = [UIImage imageNamed:[classImageArray objectAtIndex:0]];
            
            cell.sizeImg1.image = [UIImage imageNamed:@"beer"];
            cell.sizeText1.text = @"3.5% Alc Vol 285ml";
            cell.sizeImg2.image = [UIImage imageNamed:@"beer"];
            cell.sizeText2.text = @"3.5% Alc Vol 375ml";
            cell.sizeImg3.image = [UIImage imageNamed:@"beer"];
            cell.sizeText3.text = @"3.5% Alc Vol 425ml";
            add1 = cell.size1AddBtn;
            add2 = cell.size2AddBtn;
            add3 = cell.size3AddBtn;
            return cell;
            break;
            
        case 1:
            if (cell2 == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ExpandindCell2" owner:self options:nil];
                cell2 = [nib objectAtIndex:0];
            }
            
            if(selectedIndex == indexPath.row){
                cell2.contentView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.25];
            }
            else{
                cell2.contentView.backgroundColor = [UIColor whiteColor];
            }
            
            cell2.className.text = [drinkClassArray objectAtIndex:1];
            cell2.classImage.image = [UIImage imageNamed:[classImageArray objectAtIndex:1]];
            
            cell2.sizeImg1.image = [UIImage imageNamed:@"Whiskyglas-frei"];
            cell2.sizeText1.text = @"40% Alc Vol 30ml";
            cell2.sizeImg2.image = [UIImage imageNamed:@"Whiskyglas-frei"];
            cell2.sizeText2.text = @"40% Alc Vol 60ml";
            cell2.sizeImg3.image = [UIImage imageNamed:@"Whiskyglas-frei"];
            cell2.sizeText3.text = @"40% Alc Vol 90ml";
            add1 = cell2.size1AddBtn;
            add2 = cell2.size2AddBtn;
            add3 = cell2.size3AddBtn;
            return cell2;
            break;
            
        case 2:
            if (cell3 == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ExpandindCell3" owner:self options:nil];
                cell3 = [nib objectAtIndex:0];
            }
            
            if(selectedIndex == indexPath.row){
                cell3.contentView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.25];
            }
            else{
                cell3.contentView.backgroundColor = [UIColor whiteColor];
            }
            
            cell3.className.text = [drinkClassArray objectAtIndex:2];
            cell3.classImage.image = [UIImage imageNamed:[classImageArray objectAtIndex:2]];
            
            cell3.sizeImg1.image = [UIImage imageNamed:@"wine"];
            cell3.sizeText1.text = @"13% Alc Vol 100ml";
            cell3.sizeImg2.image = [UIImage imageNamed:@"wine"];
            cell3.sizeText2.text = @"13% Alc Vol 150ml";
            cell3.sizeImg3.image = [UIImage imageNamed:@"wine"];
            cell3.sizeText3.text = @"13% Alc Vol 200ml";
            add1 = cell3.size1AddBtn;
            add2 = cell3.size2AddBtn;
            add3 = cell3.size3AddBtn;
            return cell3;
            break;
        case 3:
            if (cell4 == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ExpandindCell4" owner:self options:nil];
                cell4 = [nib objectAtIndex:0];
            }
            
            if(selectedIndex == indexPath.row){
                cell4.contentView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.25];
            }
            else{
                cell4.contentView.backgroundColor = [UIColor whiteColor];
            }
            
            cell4.className.text = [drinkClassArray objectAtIndex:3];
            cell4.classImage.image = [UIImage imageNamed:[classImageArray objectAtIndex:3]];
            
            cell4.sizeImg1.image = [UIImage imageNamed:@"champagne"];
            cell4.sizeText1.text = @"11.5% Alc Vol 110ml";
            cell4.sizeImg2.image = [UIImage imageNamed:@"champagne"];
            cell4.sizeText2.text = @"11.5% Alc Vol 170ml";
            cell4.sizeImg3.image = [UIImage imageNamed:@"champagne"];
            cell4.sizeText3.text = @"11.5% Alc Vol 225ml";
            add1 = cell4.size1AddBtn;
            add2 = cell4.size2AddBtn;
            add3 = cell4.size3AddBtn;
            return cell4;
            break;
        default:
            break;
    }
    return nil;
}

//standard drink add calculation
//beer
-(void)size1btnBeer{
    self.standardDrink = self.standardDrink+0.8;
    NSString *num = [NSString stringWithFormat:@"%.1f",self.standardDrink];
        
    [UIView beginAnimations:@"animateText" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    [self.stdDrinkNumber setAlpha:0];
    [self.stdDrinkNumber setText:num];
    [self.stdDrinkNumber setAlpha:1];
    [UIView commitAnimations];
    
}

-(void)size2btnBeer{

    self.standardDrink = self.standardDrink+1;
    NSString *num = [NSString stringWithFormat:@"%.1f",self.standardDrink];
    [UIView beginAnimations:@"animateText" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    [self.stdDrinkNumber setAlpha:0];
    [self.stdDrinkNumber setText:num];
    [self.stdDrinkNumber setAlpha:1];
    [UIView commitAnimations];
}

-(void)size3btnBeer{
    self.standardDrink = self.standardDrink+1.2;
    NSString *num = [NSString stringWithFormat:@"%.1f",self.standardDrink];
    [UIView beginAnimations:@"animateText" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    [self.stdDrinkNumber setAlpha:0];
    [self.stdDrinkNumber setText:num];
    [self.stdDrinkNumber setAlpha:1];
    [UIView commitAnimations];
}

//spirit
-(void)size1btnSpirit{
    self.standardDrink = self.standardDrink+1;
    NSString *num = [NSString stringWithFormat:@"%.1f",self.standardDrink];
    [UIView beginAnimations:@"animateText" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    [self.stdDrinkNumber setAlpha:0];
    [self.stdDrinkNumber setText:num];
    [self.stdDrinkNumber setAlpha:1];
    [UIView commitAnimations];
}

-(void)size2btnSpirit{
    self.standardDrink = self.standardDrink+2;
    NSString *num = [NSString stringWithFormat:@"%.1f",self.standardDrink];
    [UIView beginAnimations:@"animateText" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    [self.stdDrinkNumber setAlpha:0];
    [self.stdDrinkNumber setText:num];
    [self.stdDrinkNumber setAlpha:1];
    [UIView commitAnimations];
}

-(void)size3btnSpirit{
    self.standardDrink = self.standardDrink+3;
    NSString *num = [NSString stringWithFormat:@"%.1f",self.standardDrink];
    [UIView beginAnimations:@"animateText" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    [self.stdDrinkNumber setAlpha:0];
    [self.stdDrinkNumber setText:num];
    [self.stdDrinkNumber setAlpha:1];
    [UIView commitAnimations];
}

//wine
-(void)size1btnWine{
    self.standardDrink = self.standardDrink+1;
    NSString *num = [NSString stringWithFormat:@"%.1f",self.standardDrink];
    [UIView beginAnimations:@"animateText" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    [self.stdDrinkNumber setAlpha:0];
    [self.stdDrinkNumber setText:num];
    [self.stdDrinkNumber setAlpha:1];
    [UIView commitAnimations];
}

-(void)size2btnWine{
    self.standardDrink = self.standardDrink+1.5;
    NSString *num = [NSString stringWithFormat:@"%.1f",self.standardDrink];
    [UIView beginAnimations:@"animateText" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    [self.stdDrinkNumber setAlpha:0];
    [self.stdDrinkNumber setText:num];
    [self.stdDrinkNumber setAlpha:1];
    [UIView commitAnimations];
}

-(void)size3btnWine{
    self.standardDrink = self.standardDrink+2;
    NSString *num = [NSString stringWithFormat:@"%.1f",self.standardDrink];
    [UIView beginAnimations:@"animateText" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    [self.stdDrinkNumber setAlpha:0];
    [self.stdDrinkNumber setText:num];
    [self.stdDrinkNumber setAlpha:1];
    [UIView commitAnimations];
}

//Champagne
-(void)size1btnChampagne{
    self.standardDrink = self.standardDrink+1;
    NSString *num = [NSString stringWithFormat:@"%.1f",self.standardDrink];
    [UIView beginAnimations:@"animateText" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    [self.stdDrinkNumber setAlpha:0];
    [self.stdDrinkNumber setText:num];
    [self.stdDrinkNumber setAlpha:1];
    [UIView commitAnimations];
}

-(void)size2btnChampagne{
    self.standardDrink = self.standardDrink+1.5;
    NSString *num = [NSString stringWithFormat:@"%.1f",self.standardDrink];
    [UIView beginAnimations:@"animateText" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    [self.stdDrinkNumber setAlpha:0];
    [self.stdDrinkNumber setText:num];
    [self.stdDrinkNumber setAlpha:1];
    [UIView commitAnimations];
}

-(void)size3btnChampagne{
    self.standardDrink = self.standardDrink+2;
    NSString *num = [NSString stringWithFormat:@"%.1f",self.standardDrink];
    [UIView beginAnimations:@"animateText" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5f];
    [self.stdDrinkNumber setAlpha:0];
    [self.stdDrinkNumber setText:num];
    [self.stdDrinkNumber setAlpha:1];
    [UIView commitAnimations];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(selectedIndex == indexPath.row){
        return 265;
    }else{
        return 80;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //User taps expanded row
    if(selectedIndex == indexPath.row){
        selectedIndex = -1;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
        [(ParallaxHeaderView *)self.drinkTable.tableHeaderView layoutHeaderViewForScrollViewOffset:self.drinkTable.contentOffset];
        return;
    }
    
    //User taps different row
    if(selectedIndex != -1){
        NSIndexPath *prevpath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        selectedIndex = indexPath.row;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:prevpath, nil] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    //User taps new row with none expanded
    selectedIndex = indexPath.row;
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    
    switch (indexPath.row) {
        case 0:
            [add1 addTarget:self action:@selector(size1btnBeer) forControlEvents:UIControlEventTouchDown];
            [add2 addTarget:self action:@selector(size2btnBeer) forControlEvents:UIControlEventTouchDown];
            [add3 addTarget:self action:@selector(size3btnBeer) forControlEvents:UIControlEventTouchDown];
            break;
        case 1:
            [add1 addTarget:self action:@selector(size1btnSpirit) forControlEvents:UIControlEventTouchDown];
            [add2 addTarget:self action:@selector(size2btnSpirit) forControlEvents:UIControlEventTouchDown];
            [add3 addTarget:self action:@selector(size3btnSpirit) forControlEvents:UIControlEventTouchDown];
            break;
        case 2:
            [add1 addTarget:self action:@selector(size1btnWine) forControlEvents:UIControlEventTouchDown];
            [add2 addTarget:self action:@selector(size2btnWine) forControlEvents:UIControlEventTouchDown];
            [add3 addTarget:self action:@selector(size3btnWine) forControlEvents:UIControlEventTouchDown];
            break;
        case 3:
            [add1 addTarget:self action:@selector(size1btnChampagne) forControlEvents:UIControlEventTouchDown];
            [add2 addTarget:self action:@selector(size2btnChampagne) forControlEvents:UIControlEventTouchDown];
            [add3 addTarget:self action:@selector(size3btnChampagne) forControlEvents:UIControlEventTouchDown];
            break;
        default:
            break;
    }
    
}

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)profileBtn:(UIBarButtonItem *)sender {
    ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"profileStory"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)testBtn:(UIButton *)sender {
    
    double waterConstant;
    int theGenderInt = [[NSUserDefaults standardUserDefaults] integerForKey:@"gender"];
    int theWeightInt = [[NSUserDefaults standardUserDefaults] integerForKey:@"weight"];
    
    if(theWeightInt == 0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reminder" message:@"Please save your Weight information in the profile page" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alert addAction:okButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    if(self.standardDrink == 0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reminder" message:@"Please select drinks before test" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alert addAction:okButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    if(theGenderInt == 0){
        waterConstant = 0.58;
    }else if(theGenderInt == 1){
        waterConstant = 0.49;
    }
    
    double bac;
    bac = (0.806*self.standardDrink*1.2)/(waterConstant*theWeightInt) - (0.017*drinkHours);
    NSLog(@"Bac: %f",bac);
    TestResultViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"bacResult"];
    vc.bacLevel = bac;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)resetBtn:(UIButton *)sender {
    self.standardDrink = 0;
    self.stdDrinkNumber.text = @"0.0";
}
@end
