//
//  BarchartViewController.m
//  SafeNightOut
//
//  Created by Evan Yeung on 20/04/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import "BarchartViewController.h"
#import "TypeInfoViewController.h"

@interface BarchartViewController ()

@end

@implementation BarchartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


    self.councilLabel.text = self.council;
    self.suburbLabel.text = self.suburbName;
    self.adressLabel.text = self.placeAddress;
    self.rankLabel.text = self.safetyRank;
    
    
    UIImage* image3 = [UIImage imageNamed:@"InfoBtn"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width, image3.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(showInfo)
         forControlEvents:UIControlEventTouchUpInside];
    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.rightBarButtonItem = btnSave;
    
    NSLog(@"%@",_safetyRank);
    NSLog(@"%@",_crimeRate);
    NSLog(@"%@",_A_Type_percent);
    
    self.barTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Rectangle 1"]];
    self.pieTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Rectangle 1"]];

    

}

- (void)viewDidAppear:(BOOL)animated {

        [(UIScrollView *)self.view setContentSize:CGSizeMake(320, 1000)];
        [super viewDidAppear:animated];
    
    
    CGFloat strFloatA = (CGFloat)[_A_Count floatValue];
    NSLog(@"%f",strFloatA);
    CGFloat strFloatB = (CGFloat)[_B_Count floatValue];
    NSLog(@"%f",strFloatB);
    CGFloat strFloatC = (CGFloat)[_C_Count floatValue];
    NSLog(@"%f",strFloatC);
    CGFloat strFloatD = (CGFloat)[_D_Count floatValue];
    NSLog(@"%f",strFloatD);
    CGFloat strFloatE = (CGFloat)[_E_Count floatValue];
    NSLog(@"%f",strFloatE);
    CGFloat strFloatF = (CGFloat)[_F_Count floatValue];
    NSLog(@"%f",strFloatF);
    

    //bar chart
    static NSNumberFormatter *barChartFormatter;
    if (!barChartFormatter){
        barChartFormatter = [[NSNumberFormatter alloc] init];
        barChartFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        barChartFormatter.allowsFloats = YES;
        barChartFormatter.maximumFractionDigits = 0;
    }
    
    self.barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 250.0, SCREEN_WIDTH, 250.0)];
           self.barChart.showLabel = NO;
    self.barChart.backgroundColor = [UIColor clearColor];
    self.barChart.yLabelFormatter = ^(CGFloat yValue){
        return [barChartFormatter stringFromNumber:[NSNumber numberWithFloat:yValue]];
    };
    
    self.barChart.yChartLabelWidth = 20.0;
    self.barChart.chartMarginLeft = 30.0;
    self.barChart.chartMarginRight = 10.0;
    self.barChart.chartMarginTop = 5.0;
    self.barChart.chartMarginBottom = 10.0;
    

    self.barChart.labelMarginTop = 5.0;
    self.barChart.showChartBorder = YES;
    [self.barChart setXLabels:@[@"Violence Offense",@"Property Offense",@"Drug Offense",@"Public Offense",@"Justice Offense",@"Other Offense"]];

    [self.barChart setYValues:@[@(strFloatA),@(strFloatB),@(strFloatC),@(strFloatD),@(strFloatE),@(strFloatF)]];
    [self.barChart setStrokeColors:@[PNTwitterColor,PNTwitterColor,PNTwitterColor,PNTwitterColor,PNTwitterColor,PNTwitterColor]];

    self.barChart.isShowNumbers = YES;
    self.barChart.isGradientShow = NO;
    [self.barChart strokeChart];
    
    self.barChart.delegate = self;
    
    [self.view addSubview:self.barChart];
    
        NSArray *items = @[[PNPieChartDataItem dataItemWithValue:strFloatA color:PNDarkBlue description:@"Violence"],
                           [PNPieChartDataItem dataItemWithValue:strFloatB color:PNYellow description:@"Property"],
                           [PNPieChartDataItem dataItemWithValue:strFloatC color:PNBrown description:@"Drug"],
                           [PNPieChartDataItem dataItemWithValue:strFloatD color:PNMauve description:@"Public"],
                           [PNPieChartDataItem dataItemWithValue:strFloatE color:PNDeepGreen description:@"Justice"],
                           [PNPieChartDataItem dataItemWithValue:strFloatF color:PNRed description:@"Other"]
                           ];
    
        self.pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(SCREEN_WIDTH /2.0 - 125, 600, 250.0, 250.0) items:items];
        self.pieChart.descriptionTextColor = [UIColor whiteColor];
        self.pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:11.0];
        self.pieChart.descriptionTextShadowColor = [UIColor clearColor];
        self.pieChart.showAbsoluteValues = NO;
        self.pieChart.showOnlyValues = NO;
        [self.pieChart strokeChart];
    
    
        self.pieChart.legendStyle = PNLegendItemStyleStacked;
        self.pieChart.legendFont = [UIFont boldSystemFontOfSize:12.0f];
    
        UIView *legend = [self.pieChart getLegendWithMaxWidth:200];
        [legend setFrame:CGRectMake(SCREEN_WIDTH /2.0 -legend.frame.size.width/2, 870, legend.frame.size.width, legend.frame.size.height)];
        [self.view addSubview:legend];
        
        [self.view addSubview:self.pieChart];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)showInfo {
    TypeInfoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"typeInfo"];

    [self.navigationController pushViewController:vc animated:YES];


}

@end
