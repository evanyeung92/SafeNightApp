//
//  PTVTableViewController.m
//  SafeNight
//
//  Created by Evan Yeung on 3/04/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import "PTVTableViewController.h"
#import "TimerViewController.h"

@interface PTVTableViewController () <UITableViewDelegate,UITableViewDataSource>
@end

@implementation PTVTableViewController
@synthesize stopTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 25)];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    NSString *string = [NSString stringWithFormat:@"%1$@   Station",stopTitle];
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    
    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_busInfo count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ptvCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ptvCell"];
    }
   // UIImage *thumbnailImageView = (UIImage *)[cell viewWithTag:100];
    UILabel *routeLabel = (UILabel *)[cell viewWithTag:103];
    UILabel *destinationLabel = (UILabel *)[cell viewWithTag:101];
    UITextView *stopsLabel = (UITextView *)[cell viewWithTag:102];
                              
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:104];

    
    NSString *dest = [[_busInfo objectAtIndex:indexPath.row] valueForKey:@"destination"];
    destinationLabel.text = dest;
    NSString *stops = [[_busInfo objectAtIndex:indexPath.row] valueForKey:@"line_name"];
    stopsLabel.text = stops;
    
    NSString *route = [[_busInfo objectAtIndex:indexPath.row] valueForKey:@"bus_route"];
    routeLabel.text = route;
    NSString *type = [[_busInfo objectAtIndex:indexPath.row] valueForKey:@"type"];
    NSString *time = [[_busInfo objectAtIndex:indexPath.row] valueForKey:@"time"];
    NSDate *localdate = [PTVTableViewController apiDateStringToLocalDate:time];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateFormat:@"hh:mm a"];

    timeLabel.text = [formatter stringFromDate:localdate];
    
    if([type isEqualToString:@"train"])
    {
    cell.imageView.image = [UIImage imageNamed:@"iconTrain"];
    }else if([type isEqualToString:@"tram"])
    {
     cell.imageView.image = [UIImage imageNamed:@"iconTram"];
    }else if([type isEqualToString:@"bus"])
    {
        cell.imageView.image = [UIImage imageNamed:@"iconBus"];
    }else if([type isEqualToString:@"vline"])
    {
        cell.imageView.image = [UIImage imageNamed:@"iconBus"];
    }else if([type isEqualToString:@"nightrider"])
    {
        cell.imageView.image = [UIImage imageNamed:@"NightBus_logo"];
    }
    
        UILabel *timeLabelForPass = (UILabel *)[cell viewWithTag:105];
    timeLabelForPass.text = [[_busInfo objectAtIndex:indexPath.row] valueForKey:@"time"];
    cell.accessoryView = [[ UIImageView alloc ]
                          initWithImage:[UIImage imageNamed:@"alarm_clock" ]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}

+(NSDate*) apiDateStringToLocalDate:(NSString*)dateString
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSDate * utcDate = [dateFormatter dateFromString:dateString];
    
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: utcDate];
    NSDate * localDate = [NSDate dateWithTimeInterval: seconds sinceDate: utcDate];
    
    return localDate;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TimerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"timer"];
    [self.navigationController pushViewController:vc animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *timeLabelForPass = (UILabel *)[cell viewWithTag:105];
    NSString *busTimeString = timeLabelForPass.text;

     NSDate *busTime = [PTVTableViewController apiDateStringToLocalDate:busTimeString];
    NSLog(@"%@",busTime);
    NSDate *current = [NSDate date];
    NSLog(@"%@",current);
    NSTimeInterval secondDifference = [busTime timeIntervalSinceDate:current];
    int difference = secondDifference;
    vc.remainingCounts = difference;
    NSLog(@"%d",difference);
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
