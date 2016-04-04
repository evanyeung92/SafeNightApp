//
//  PTVTableViewController.h
//  SafeNight
//
//  Created by Evan Yeung on 3/04/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTVTableViewController : UITableViewController{
   
    IBOutlet UITableView *ptvTableView;
    NSString *stopTitle;
    NSMutableData *data;
}
@property (nonatomic, copy) NSString *stopTitle;

@end
