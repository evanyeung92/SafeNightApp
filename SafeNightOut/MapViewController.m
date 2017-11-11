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
     @property (nonatomic, assign) BOOL boo;
    

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
    map.frame = self.view.bounds;
    map.autoresizingMask = self.view.autoresizingMask;
    
    locationManager = [ [ CLLocationManager alloc ] init ] ;

    locationManager.delegate = self;
    map.delegate = self;
    locationManager.desiredAccuracy =kCLLocationAccuracyNearestTenMeters;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    [locationManager requestLocation];
    
    
    //display nearby restaurant button
    UIImage *btnImage = [UIImage imageNamed:@"restau"];
    [self.restauBtn setImage:btnImage forState:UIControlStateNormal];
    
    
    //Display search TableView on the top of MapView
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    LocationSearchTableViewController *locationSearchTable =
    [storyboard instantiateViewControllerWithIdentifier:@"LocationSearchTable"];
    resultSearchController = [[UISearchController alloc] initWithSearchResultsController:locationSearchTable];
    resultSearchController.searchResultsUpdater = locationSearchTable;
    
    //Enable search bar in the navigation item.
    UISearchBar *searchBar = resultSearchController.searchBar;
    [searchBar sizeToFit];
    searchBar.placeholder = @"Search for places";
    self.navigationItem.titleView = resultSearchController.searchBar;
    
    resultSearchController.hidesNavigationBarDuringPresentation = NO;
    resultSearchController.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;
    
    //Initial a search queue.
    self.searchQueue = [[NSOperationQueue alloc] init];
    self.searchQueue.maxConcurrentOperationCount = 1;
    
    locationSearchTable.mapView = map;
    locationSearchTable.handleMapSearchDelegate = self;
    
    self.boo = true;
    //perform health check before requesting PTV API
    [self healthCheck];
    
    //Call API to show nearby stops
    nearbyStop = [self nearby:locationManager.location];
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [locationManager requestLocation];
    }
}

+ (NSString *)estimateSafetyRank:(double)crimerate
{
    NSString *string;
    if(crimerate >= 0.04 && crimerate <= 0.08)
    {
        string = @"Very Safe";
    }else if(crimerate >= 0.09 && crimerate <= 0.12)
    {
        string = @"Safe";
    }else if(crimerate >= 0.13 && crimerate <= 0.20)
    {
        string = @"Unsafe";
    }else if(crimerate >= 0.21 && crimerate <= 0.30)
    {
        string = @"Extremely Dangerous";
    }
    return string;
}

//Show error if error happens on LocationManager
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error: %@", error);
}


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{

    [map setUserTrackingMode:MKUserTrackingModeNone animated:YES];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(self.boo){
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.01;
    mapRegion.span.longitudeDelta = 0.01;
    mapRegion = [map regionThatFits:mapRegion];
    [map setRegion:mapRegion animated:YES];
        self.boo = false;
    }
}

//drop pin annotation when search for a particular place
- (void)dropPinZoomIn:(MKPlacemark *)placemark
{
    // cache the pin
    selectedPin = placemark;
    // clear existing pins
    [map removeAnnotations:(map.annotations)];
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    
    //Retrieve safety information
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"http://safenightout.azurewebsites.net/AreaSafety.php"];
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    _safetyInfo= [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    
    annotation.coordinate = placemark.coordinate;
    annotation.title = placemark.name;
//    annotation.subtitle = [NSString stringWithFormat:@"%@ %@",
//                           (placemark.locality == nil ? @"" : placemark.locality),
//                           (placemark.administrativeArea == nil ? @"" : placemark.administrativeArea)
//                           ];
    NSString *suburb = placemark.locality;
    NSLog(@"%@",suburb);
    for(NSArray *arr in _safetyInfo){
    if([suburb isEqualToString:[arr valueForKey:@"Suburb name"]]){
        double value = [[arr valueForKey:@"Average crime rate"] doubleValue];
        NSString *safetyRank = [MapViewController estimateSafetyRank:value];
        NSString *string = [NSString stringWithFormat:@"Safety Rank:%1$@ ",safetyRank];
        
        annotation.subtitle = string;
    }
    }
    [map addAnnotation:annotation];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    MKCoordinateRegion region = MKCoordinateRegionMake(placemark.coordinate, span);
    [map setRegion:region animated:true];
}

//current location button clicked lisenter
- (IBAction)currentLocation:(UIButton *)sender {
    MKUserLocation *userLocation = map.userLocation;
    if (!userLocation)
    return;
    
    MKCoordinateRegion region;
    region.center = userLocation.location.coordinate;
    region.span = MKCoordinateSpanMake(0.01, 0.01); //Zoom distance
    region = [map regionThatFits:region];
    [map setRegion:region animated:YES];
}

//Function of change map type
- (void) changeMapType: (id)sender
{
    if (map.mapType == MKMapTypeStandard)
        map.mapType = MKMapTypeHybrid;
    else
        map.mapType = MKMapTypeStandard;
}

//show nearby restaurant button clicked lisenter
- (IBAction)restauBtn:(UIButton *)sender{
    
    MKMapView *mapView = map;
    NSMutableArray *annotationsToRemove = [NSMutableArray arrayWithCapacity:[map.annotations count]];
    if(self.restauBtn.selected==YES)
    {
        [self.restauBtn setSelected:NO];
        for(int i = 0; i<[map.annotations count];i++){
            if([[map.annotations objectAtIndex:i] isKindOfClass:[CustomAnnotation class]])
            {
                [annotationsToRemove addObject:[map.annotations objectAtIndex:i]];
            }
        }
        [map removeAnnotations:annotationsToRemove];


    }
    else{
    [self.restauBtn setSelected:YES];
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
                annotation.subtitle = item.phoneNumber;
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
    
    [_restauBtn showsTouchWhenHighlighted];

}
#pragma mark - MKMapViewDelegate
//Add nearby bus stop annotations when change region
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
        NSNumber *stopID = [[nearbyStop objectAtIndex:i] valueForKeyPath:@"result.stop_id"];
        
        
        coordinates.longitude = [longi doubleValue];
        coordinates.latitude = [latit doubleValue];
        
        if(CLLocationCoordinate2DIsValid(coordinates))
        {
            StopAnnotation *annotObj = [[StopAnnotation alloc] initWithCoordinate:coordinates title:address subtitle:type];
            annotObj.stopId = stopID;
            [map addAnnotation:annotObj];
        }else
        {
            NSLog(@"place has invalid coordinates");
        }

        
    }

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
        NSString *train = @"train";
        NSString *tram = @"tram";
        NSString *bus = @"bus";
        NSString *vline = @"V/Line";
        NSString *nightrider = @"NightRider";
        if([annotation.subtitle isEqualToString:train])
        {
        UIImage *ptvImg = [UIImage imageNamed:@"iconTrain"];
        stopView.image = ptvImg;
        }else if([annotation.subtitle isEqualToString:tram])
        {
        UIImage *ptvImg = [UIImage imageNamed:@"iconTram"];
        stopView.image = ptvImg;
        }else if([annotation.subtitle isEqualToString:bus])
        {
            UIImage *ptvImg = [UIImage imageNamed:@"iconBus"];
            stopView.image = ptvImg;
        }else if([annotation.subtitle isEqualToString:vline])
        {
            UIImage *ptvImg = [UIImage imageNamed:@"iconTram"];
            stopView.image = ptvImg;
        }else if([annotation.subtitle isEqualToString:nightrider])
        {
            UIImage *ptvImg = [UIImage imageNamed:@"NightBus_logo"];
            stopView.image = ptvImg;
        }
        
        
        stopView.tintColor = [UIColor blueColor];
        stopView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    } else {
        stopView.annotation = annotation;
    }
  
    UIButton *ptvButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 36)];
    [ptvButton setBackgroundImage:[UIImage imageNamed:@"logo-pt-vic"] forState:UIControlStateNormal];
    stopView.rightCalloutAccessoryView = ptvButton;
   
    return stopView;
    }
    
    else if([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        MKAnnotationView *searchView = (MKAnnotationView *) [map dequeueReusableAnnotationViewWithIdentifier:@"search"];
        if (searchView == nil) {
            searchView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"search"];
            searchView.enabled = YES;
            searchView.canShowCallout = YES;
            searchView.tintColor = [UIColor orangeColor];
        } else {
            searchView.annotation = annotation;
        }
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [button setBackgroundImage:[UIImage imageNamed:@"car"]
                          forState:UIControlStateNormal];
        [button addTarget:self action:@selector(getDirections) forControlEvents:UIControlEventTouchUpInside];
        searchView.leftCalloutAccessoryView = button;

        return searchView;
    }
    
    else if([annotation isKindOfClass:[CustomAnnotation class]])
    {
        MKAnnotationView *searchView = (MKAnnotationView *) [map dequeueReusableAnnotationViewWithIdentifier:@"barandrestaurant"];
        if (searchView == nil) {
            searchView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"barandrestaurant"];
            searchView.enabled = YES;
            searchView.canShowCallout = YES;
            searchView.tintColor = [UIColor blueColor];
            UIButton *callBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
            [callBtn setBackgroundImage:[UIImage imageNamed:@"phone_icon"] forState:UIControlStateNormal];
            searchView.rightCalloutAccessoryView = callBtn;
            [searchView setTag:1];
        } else {
            searchView.annotation = annotation;
        }
        
        return searchView;
        
    }
    return nil;
}

//Show PTV callout button and pass data to next TableViewController
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if(view.rightCalloutAccessoryView && !(view.tag == 1))
    {
        PTVTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PTV"];
        NSNumber *stpId = ((StopAnnotation*)view.annotation).stopId;

        [self.navigationController pushViewController:vc animated:YES];
        vc.stopTitle = view.annotation.title;
        
        nextDepartures = [self departuresForMode:view.annotation.subtitle stop:stpId limit:@(1)];
        
        NSMutableArray *lineNumAr = [nextDepartures  objectForKey:@"values"];
        NSMutableArray *fullInfo = [[NSMutableArray alloc]init];
        

        for(int t = 0; t<lineNumAr.count;t++)
        {
          NSMutableArray *busInformation = [[NSMutableArray alloc] init];
          NSString *lineNum = [[lineNumAr objectAtIndex:t] valueForKeyPath:@"platform.direction.line.line_number"];
          NSString *lineName = [[lineNumAr objectAtIndex:t] valueForKeyPath:@"platform.direction.line.line_name_short"];
          NSString *destination = [[lineNumAr objectAtIndex:t] valueForKeyPath:@"run.destination_name"];
          NSString *depTime = [[lineNumAr objectAtIndex:t] valueForKeyPath:@"time_timetable_utc"];
             NSString *type = [[lineNumAr objectAtIndex:t] valueForKeyPath:@"platform.direction.line.transport_type"];
            
            [busInformation addObject:lineNum];
            [busInformation addObject:lineName];
            [busInformation addObject:destination];
            [busInformation addObject:depTime];
            [busInformation addObject:type];
            
            [fullInfo addObject:busInformation];
           
        }
        
        
        
        NSMutableArray *infoArrayWithKeys = [[NSMutableArray alloc]init];
        for (NSArray *arr in fullInfo) {
            
            NSDictionary *dict = @{
                                   @"bus_route" : [arr objectAtIndex:0],
                                   @"line_name" : [arr objectAtIndex:1],
                                   @"destination" : [arr objectAtIndex:2],
                                   @"time" : [arr objectAtIndex:3],
                                   @"type" : [arr objectAtIndex:4],
                                   };
            
            [infoArrayWithKeys addObject:dict];
        }
        
      NSLog(@"%@",infoArrayWithKeys);
        vc.busInfo = infoArrayWithKeys;
   
    }
    
    else if( view.tag == 1 && view.rightCalloutAccessoryView){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Call" message:view.annotation.subtitle preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSString *phoneNumber = view.annotation.subtitle;
            NSString *finalString = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSLog(@"%@",finalString);
            finalString = [finalString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",finalString]];
            NSLog(@"%@",phoneUrl);
            if ([[UIApplication sharedApplication] canOpenURL:phoneUrl])
                [[UIApplication sharedApplication] openURL:phoneUrl];
            
            
            
        }];
        
        UIAlertAction *noButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alert addAction:okButton];
        [alert addAction:noButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

//transfer data to string
+(NSString *)UTCrfc822Date:(NSDate*)datetime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    return [dateFormatter stringFromDate:datetime];
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
    };\
    

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


- (IBAction)pubBtn:(UIButton *)sender {
    
    MKMapView *mapView = map;
    NSMutableArray *annotationsToRemove = [NSMutableArray arrayWithCapacity:[map.annotations count]];
    if(self.pubBtn.selected==YES)
    {
        [self.pubBtn setSelected:NO];
        for(int i = 0; i<[map.annotations count];i++){
            if([[map.annotations objectAtIndex:i] isKindOfClass:[CustomAnnotation class]])
            {
                [annotationsToRemove addObject:[map.annotations objectAtIndex:i]];
            }
        }
        [map removeAnnotations:annotationsToRemove];
        
        
    }
    else{
        [self.pubBtn setSelected:YES];
        [self.searchQueue cancelAllOperations];
        
        // issue new MKLoadSearch
        
        [self.searchQueue addOperationWithBlock:^{
            
            __block BOOL done = NO;
            
            MKLocalSearchRequest *requestRestaurant = [[MKLocalSearchRequest alloc] init];
            requestRestaurant.naturalLanguageQuery = @"Bar";
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
                    annotation.subtitle = item.phoneNumber;
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
    
    [self.pubBtn showsTouchWhenHighlighted];
}
@end
