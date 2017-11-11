//
//  SafetyMapViewController.h
//  SafeNightOut
//
//  Created by Evan Yeung on 19/04/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol HandleSafetyMapSearch <NSObject>
- (void)dropPinZoomIn:(MKPlacemark *)placemark;
@end
@interface SafetyMapViewController : UIViewController<CLLocationManagerDelegate, HandleSafetyMapSearch, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *mapTool;

- (IBAction)policeBtn:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *policeBtn;
- (IBAction)currentLocation:(UIButton *)sender;

@property (strong) UIActivityIndicatorView *Spinner;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, copy) NSMutableArray *safetyInfo;
@end
