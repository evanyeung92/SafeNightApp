//
//  BarchartViewController.h
//  SafeNightOut
//
//  Created by Evan Yeung on 20/04/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNChartDelegate.h"
#import "PNChart.h"

@interface BarchartViewController : UIViewController<PNChartDelegate>

@property (nonatomic, copy) NSString *placeAddress;
@property (nonatomic, copy) NSString *suburbName;

@property (nonatomic, copy) NSString *safetyRank;
@property (nonatomic, copy) NSString *crimeRate;
@property (nonatomic, copy) NSString *council;
@property (nonatomic, copy) NSString *A_Type_percent;
@property (nonatomic, copy) NSString *B_Type_percent;
@property (nonatomic, copy) NSString *C_Type_percent;
@property (nonatomic, copy) NSString *D_Type_percent;
@property (nonatomic, copy) NSString *E_Type_percent;
@property (nonatomic, copy) NSString *F_Type_percent;

@property (nonatomic, copy) NSString *A_Count;
@property (nonatomic, copy) NSString *B_Count;
@property (nonatomic, copy) NSString *C_Count;
@property (nonatomic, copy) NSString *D_Count;
@property (nonatomic, copy) NSString *E_Count;
@property (nonatomic, copy) NSString *F_Count;

@property (weak, nonatomic) IBOutlet UILabel *councilLabel;
@property (weak, nonatomic) IBOutlet UILabel *suburbLabel;
@property (weak, nonatomic) IBOutlet UILabel *adressLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;

@property (weak, nonatomic) IBOutlet UILabel *barTitle;
@property (weak, nonatomic) IBOutlet UILabel *pieTitle;


@property (nonatomic) PNPieChart * pieChart;
@property (nonatomic) PNBarChart * barChart;


@end
