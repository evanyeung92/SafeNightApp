//
//  MapViewController.h
//  SafeNight
//
//  Created by Evan Yeung on 20/03/2016.
//  Copyright (c) 2016 Evan Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@protocol HandleMapSearch <NSObject>
- (void)dropPinZoomIn:(MKPlacemark *)placemark;
@end

@interface MapViewController : UIViewController<CLLocationManagerDelegate, HandleMapSearch, MKMapViewDelegate>
{
//typedef void (^completionBlock) (id data);
    NSArray *nearbyStop;
    NSDictionary *nextDepartures;
    NSMutableData *muData;
}
@property (weak, nonatomic) IBOutlet UIButton *restauBtn;
- (IBAction)restauBtn:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *pubBtn;
- (IBAction)pubBtn:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *currentLoc;
- (IBAction)currentLocation:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet UIToolbar *mapTool;

-(id) initWithPath:(NSString*)path devId:(NSString*)devId key:(NSString*)key;
-(id) initWithDevId:(NSString*)devId key:(NSString*)key;

-(BOOL) healthCheck;
-(id) nearby:(CLLocation*)location;
-(id) departuresForMode:(NSString*)mode stop:(NSNumber*)stop limit:(NSNumber*)limit;
+(NSNumber*) transportTypeToMode:(NSString*)transportType;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, copy) NSMutableArray *safetyInfo;

@end
