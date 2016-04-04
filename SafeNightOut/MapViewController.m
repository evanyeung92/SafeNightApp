//
//  MapViewController.m
//  SafeNight
//
//  Created by Evan Yeung on 20/03/2016.
//  Copyright (c) 2016 Evan Yeung. All rights reserved.
//

#import "MapViewController.h"
#import "LocationSearchTableViewController.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CoreLocation.h>
#import "CustomAnnotation.h"
#import "StopAnnotation.h"
#import "PTVTableViewController.h"


@interface MapViewController (){

    __weak IBOutlet MKMapView *map;
}
     @property (nonatomic, strong) NSOperationQueue *searchQueue;
    

@end

@implementation MapViewController
        NSString* mDevId = @"1000713";
        NSString* mKey = @"bad6a543-f543-11e5-a65e-029db85e733b";
        NSString* mBaseURL = @"http://timetableapi.ptv.vic.gov.au";
        NSArray * mLines;
        NSDictionary *mTtIds;

        NSString* stopLong;
        NSString* stopLati;


        CLLocationManager *locationManager;
        UISearchController *resultSearchController;
        MKPlacemark *selectedPin;



- (void)viewDidLoad {
    [super viewDidLoad];
    mTtIds = @{@"train":@(0),
               @"tram":@(1),
               @"bus":@(2),
               @"vline":@(3),
               @"nightrider":@(4)};
    map.showsUserLocation = YES;
    map.showsBuildings = YES;
    
    locationManager = [ [ CLLocationManager alloc ] init ] ;

    locationManager.delegate = self;
    locationManager.desiredAccuracy =kCLLocationAccuracyNearestTenMeters;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    [locationManager requestLocation];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    LocationSearchTableViewController *locationSearchTable =
    [storyboard instantiateViewControllerWithIdentifier:@"LocationSearchTable"];
    resultSearchController = [[UISearchController alloc] initWithSearchResultsController:locationSearchTable];
    resultSearchController.searchResultsUpdater = locationSearchTable;
    
    UISearchBar *searchBar = resultSearchController.searchBar;
    [searchBar sizeToFit];
    searchBar.placeholder = @"Search for places";
    self.navigationItem.titleView = resultSearchController.searchBar;
    
    resultSearchController.hidesNavigationBarDuringPresentation = NO;
    resultSearchController.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;
    
    
    self.searchQueue = [[NSOperationQueue alloc] init];
    self.searchQueue.maxConcurrentOperationCount = 1;
    
    locationSearchTable.mapView = map;
    locationSearchTable.handleMapSearchDelegate = self;
    
    [self healthCheck];
    nearbyStop = [self nearby:locationManager.location];
    

}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [locationManager requestLocation];
    }
}

//comment

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
//  CLLocation *location = [locations firstObject];
//    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
//    MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, span);
//    [map setRegion:region animated:true];
    [map setUserTrackingMode:MKUserTrackingModeNone animated:YES];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
   
}

- (void)dropPinZoomIn:(MKPlacemark *)placemark
{
    // cache the pin
    selectedPin = placemark;
    // clear existing pins
    [map removeAnnotations:(map.annotations)];
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = placemark.coordinate;
    annotation.title = placemark.name;
    annotation.subtitle = [NSString stringWithFormat:@"%@ %@",
                           (placemark.locality == nil ? @"" : placemark.locality),
                           (placemark.administrativeArea == nil ? @"" : placemark.administrativeArea)
                           ];
    [map addAnnotation:annotation];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    MKCoordinateRegion region = MKCoordinateRegionMake(placemark.coordinate, span);
    [map setRegion:region animated:true];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    MKMapRect mapRect = mapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mapRect), MKMapRectGetMidY(mapRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMidY(mapRect));
    
    CGFloat meters = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    
    if (meters > 5000)
        
        return;
    
    for (int i = 0; i<nearbyStop.count; i++) {
        CLLocationCoordinate2D coordinates;
        NSString *longi = [[nearbyStop objectAtIndex:i] valueForKeyPath:@"result.lon"];
        
        NSString *latit = [[nearbyStop objectAtIndex:i] valueForKeyPath:@"result.lat"];
        NSString *address = [[nearbyStop objectAtIndex:i] valueForKeyPath:@"result.location_name"];
        NSString *type = [[nearbyStop objectAtIndex:i] valueForKeyPath:@"result.transport_type"];
        
        coordinates.longitude = [longi doubleValue];
        coordinates.latitude = [latit doubleValue];
        
        if(CLLocationCoordinate2DIsValid(coordinates))
        {
            StopAnnotation *annotObj = [[StopAnnotation alloc] initWithCoordinate:coordinates title:address subtitle:type ];
            [map addAnnotation:annotObj];
        }else
        {
            NSLog(@"place has invalid coordinates");
        }

        
    }
    // if have some backlogged requests, let's just get rid of them
    
    [self.searchQueue cancelAllOperations];
    
    // issue new MKLoadSearch
    
    [self.searchQueue addOperationWithBlock:^{
        
        __block BOOL done = NO;
        
        MKLocalSearchRequest *requestRestaurant = [[MKLocalSearchRequest alloc] init];
        requestRestaurant.naturalLanguageQuery = @"restaurant";
        requestRestaurant.region = mapView.region;
        
        MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:requestRestaurant];
        [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
            
            NSMutableArray *annotations = [NSMutableArray array];
            
            [response.mapItems enumerateObjectsUsingBlock:^(MKMapItem *item, NSUInteger idx, BOOL *stop) {
                
                for (CustomAnnotation *annotation in mapView.annotations)
                {
                    // if don't need this one, don't add it, just return, and check the next one
                    
                    if ([annotation isKindOfClass:[CustomAnnotation class]])
                        if (item.placemark.coordinate.latitude == annotation.coordinate.latitude &&
                            item.placemark.coordinate.longitude == annotation.coordinate.longitude)
                        {
                            return;
                        }
                }
                
                // otherwise add it
                
                CustomAnnotation *annotation = [[CustomAnnotation alloc] initWithPlacemark:item.placemark];
                annotation.title = item.name;
                annotation.phone = item.phoneNumber;
                annotation.subtitle = item.placemark.addressDictionary[(NSString *)kABPersonAddressStreetKey];
                [annotations addObject:annotation];
            }];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [map addAnnotations:annotations];
            }];
            
            done = YES;
        }];
        
        
        while (!done)
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate distantFuture]];
    }];
}


//Change the apperance of MKAnnotation
- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
       
        //return nil so map view draws "blue dot" for standard user location
        return nil;
    }
    
    else if([annotation isKindOfClass:[StopAnnotation class]]) {
    static NSString *reuseId = @"pin";
    MKAnnotationView *stopView = (MKAnnotationView *) [map dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (stopView == nil) {
        stopView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        stopView.enabled = YES;
        stopView.canShowCallout = YES;
        UIImage *ptvImg = [UIImage imageNamed:@"iconTrain"];
        stopView.image = ptvImg;
        stopView.tintColor = [UIColor brownColor];
        stopView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    } else {
        stopView.annotation = annotation;
    }
  
    UIButton *ptvButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [ptvButton setBackgroundImage:[UIImage imageNamed:@"iconTrain"] forState:UIControlStateNormal];
    stopView.rightCalloutAccessoryView = ptvButton;
    
//    UIButton *driveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    [driveButton setBackgroundImage:[UIImage imageNamed:@"car"]
//                      forState:UIControlStateNormal];
//        [driveButton addTarget:self action:@selector(getDirections) forControlEvents:UIControlEventTouchUpInside];
//    stopView.leftCalloutAccessoryView = driveButton;
    
    return stopView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if(view.rightCalloutAccessoryView)
    {
        PTVTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PTV"];

        [self.navigationController pushViewController:vc animated:YES];
//        NSLog(@"%@",view.annotation.title);
//        NSLog(@"%@",view.annotation.subtitle);
        vc.stopTitle = view.annotation.title;
        
            for (int i = 0; i<nearbyStop.count; i++)
            {
                NSString *mode = [[nearbyStop objectAtIndex:i] valueForKeyPath:@"result.transport_type"];
                NSNumber *stopId = [[nearbyStop objectAtIndex:i] valueForKeyPath:@"result.stop_id"];
                nextDepartures = [self departuresForMode:mode stop:stopId limit:@(5)];

            }
        
        for(int j = 0; j<nextDepartures.count;j++){
            NSMutableArray *lineNumAr = [nextDepartures  objectForKey:@"values"];
            for(int t = 0; t<lineNumAr.count;t++){
                NSString *lineNum = [[lineNumAr objectAtIndex:t] valueForKeyPath:@"platform.direction.line.line_number"];
                NSLog(@"%@",lineNum);
                
            }
            
        }
        
        
       // NSLog(@"%@",nextDepartures);
    }
    
}


- (void)getDirections {
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:selectedPin];
    [mapItem openInMapsWithLaunchOptions:(@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving})];
}

-(id) initWithPath:(NSString*)path devId:(NSString*)devId key:(NSString*)key
{
    self = [super init];
    
    if( self)
    {
        mBaseURL = path;
        mDevId = devId;
        mKey = key;
        mLines = nil;
        mTtIds = @{@"train":@(0),
                   @"tram":@(1),
                   @"bus":@(2),
                   @"vline":@(3),
                   @"nightrider":@(4)};
    }
    
    return self;
}

-(id) initWithDevId:(NSString*)devId key:(NSString*)key
{
    return [self initWithPath:@"http://timetableapi.ptv.vic.gov.au" devId:devId key:key];
}

-(BOOL) healthCheck
{
    NSDictionary *response = [self doApiCall:[NSString stringWithFormat:@"/v2/healthcheck?timestamp=%@", [MapViewController UTCrfc822Date:[NSDate date] ]] useCache:NO];
    
    
    return [response[@"clientClockOK"] integerValue] == 1
    &&  [response[@"databaseOK"] integerValue] == 1
    &&  [response[@"memcacheOK"] integerValue] == 1
    &&  [response[@"securityTokenOK"] integerValue] == 1;
    
}

-(id) doApiCall:(NSString*)apiCall
{
    return [self doApiCall:apiCall useCache:YES];
}

-(id) doApiCall:(NSString*)apiCall useCache:(BOOL)useCache
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", mBaseURL, [MapViewController signApiCall:apiCall]]];
    
    id response = [self httpWrapper:url];
      //  NSLog( @"%@", response );
    return response;
}

-(id) httpWrapper:(NSURL*)url
{
    __block id response = nil;
    
    void (^doStuff)() = ^void()
    {
        int retry = 3;
        NSError * error;
        
        
        while( retry > 0) {
            NSData * data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url
                                                                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                                 timeoutInterval:600] returningResponse:nil error:&error ];
            
            if( data != nil )
            {
                response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if( response != nil)
                    retry = 0;
            }
            
            if(data == nil || response == nil)
            {
                NSLog(@"Bad response %@", url);
                NSLog(@"%@", error);
                --retry;
            }
        }
    };
    

        doStuff();

    
    return response;
}

+(NSString*) signApiCall:(NSString*)apiCall
{
    NSString* signedApiCall;
    NSString* signature;
    
    if([apiCall rangeOfString:@"?"].location != NSNotFound)
        signedApiCall = [NSString stringWithFormat:@"%@&devid=%@", apiCall, mDevId];
    else
        signedApiCall = [NSString stringWithFormat:@"%@?devid=%@", apiCall, mDevId];
    
    signature = [MapViewController hmac:signedApiCall withKey:mKey];
    
    return [NSString stringWithFormat:@"%@&signature=%@", signedApiCall, signature];
}

+(NSString *)hmac:(NSString *)plainText withKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [plainText cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMACData = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    NSString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    
    for (int i = 0; i < HMACData.length; ++i)
        HMAC = [HMAC stringByAppendingFormat:@"%02lX", (unsigned long)buffer[i]];
    
    return HMAC;
}

+(NSString *)UTCrfc822Date:(NSDate*)datetime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    return [dateFormatter stringFromDate:datetime];
}

-(NSArray*) nearby:(CLLocation*)location
{

        return [self doApiCall:[NSString stringWithFormat:@"/v2/nearme/latitude/%f/longitude/%f?limit=5", location.coordinate.latitude, location.coordinate.longitude]];

}

-(NSDictionary*) departuresForMode:(NSString*)mode stop:(NSNumber*)stop limit:(NSNumber*)limit
{
    NSString* request;
    
    request = [NSString stringWithFormat:@"/v2/mode/%@/stop/%@/departures/by-destination/limit/%@", [MapViewController transportTypeToMode:mode], stop, limit ];
    
    return [self doApiCall:request useCache:[limit isEqualToNumber:@(0)]];
}

+(NSNumber*) transportTypeToMode:(NSString*)transportType
{
    return [mTtIds valueForKey:transportType];
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
