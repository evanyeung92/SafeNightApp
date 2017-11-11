//
//  SafetyViewController.m
//  SafeNight
//
//  Created by Evan Yeung on 20/03/2016.
//  Copyright (c) 2016 Evan Yeung. All rights reserved.
//

#import "SafetyViewController.h"

@interface SafetyViewController () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation SafetyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"http://safenightout.azurewebsites.net/SafetyRankInfo.php"];
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
   _safetyInfo= [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];


}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 25)];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    NSString *string = [NSString stringWithFormat:@"Council"];
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    
    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_safetyInfo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"safetyCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"safetyCell"];
    }
    
//    for(NSDictionary *item in _safetyInfo){
//        NSString *suburb =
//    }
    cell.textLabel.text = [[self.safetyInfo objectAtIndex:indexPath.row] valueForKey:@"Suburb_name"];
    cell.detailTextLabel.text = [[self.safetyInfo objectAtIndex:indexPath.row] valueForKey:@"Average_crime_rate"];
    return cell;
}



@end
