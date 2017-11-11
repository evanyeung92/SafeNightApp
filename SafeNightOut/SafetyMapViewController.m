//
//  SafetyMapViewController.m
//  SafeNightOut
//
//  Created by Evan Yeung on 19/04/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import "SafetyMapViewController.h"
#import "LocationSearchTableViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CoreLocation.h>
#import "BarchartViewController.h"
#import "CustomAnnotation.h"

@interface SafetyMapViewController (){
    
    __weak IBOutlet MKMapView *safemap;
}
@property (nonatomic, strong) NSOperationQueue *searchQueue;
@property (nonatomic, assign) BOOL boo;


@end

@implementation SafetyMapViewController
CLLocationManager *safetylocationManager;
UISearchController *safetyresultSearchController;
MKPlacemark *safetyselectedPin;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    safemap.showsUserLocation = YES;
    safemap.showsBuildings = YES;
    safemap.frame = self.view.bounds;
    safemap.autoresizingMask = self.view.autoresizingMask;
    
    safetylocationManager = [ [ CLLocationManager alloc ] init ] ;
    
    safetylocationManager.delegate = self;
    safetylocationManager.desiredAccuracy =kCLLocationAccuracyNearestTenMeters;
    safetylocationManager.distanceFilter = kCLDistanceFilterNone;
    
    if([safetylocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [safetylocationManager requestWhenInUseAuthorization];
    }
    [safetylocationManager startUpdatingLocation];
    [safetylocationManager requestLocation];
    
    //tool bar button
    UIImage *currentBtn = [UIImage imageNamed:@"current-location-icon"];
    UIBarButtonItem *currentLocation = [[UIBarButtonItem alloc] initWithImage:currentBtn style:UIBarButtonItemStylePlain target:self action:@selector(showCurrentLocation:) ];
    
    NSArray *buttons = [[NSArray alloc]
                        initWithObjects:currentLocation, nil];
    [self.mapTool setItems:buttons];

    //Display search TableView on the top of MapView
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    LocationSearchTableViewController *locationSearchTable =
    [storyboard instantiateViewControllerWithIdentifier:@"LocationSearchTable"];
    safetyresultSearchController = [[UISearchController alloc] initWithSearchResultsController:locationSearchTable];
    safetyresultSearchController.searchResultsUpdater = locationSearchTable;
    //Enable search bar in the navigation item.
    UISearchBar *searchBar = safetyresultSearchController.searchBar;
    [searchBar sizeToFit];
    searchBar.placeholder = @"Search for place safety";
    self.navigationItem.titleView = safetyresultSearchController.searchBar;
    
    safetyresultSearchController.hidesNavigationBarDuringPresentation = NO;
    safetyresultSearchController.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;
    
    //Initial a search queue.
    self.searchQueue = [[NSOperationQueue alloc] init];
    self.searchQueue.maxConcurrentOperationCount = 1;
    
    locationSearchTable.mapView = safemap;
    locationSearchTable.handleMapSearchDelegate = self;
    
    self.boo = true;

    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [safetylocationManager requestLocation];
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
    
    [safemap setUserTrackingMode:MKUserTrackingModeNone animated:YES];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(self.boo){
        MKCoordinateRegion mapRegion;
        mapRegion.center = mapView.userLocation.coordinate;
        mapRegion.span.latitudeDelta = 0.01;
        mapRegion.span.longitudeDelta = 0.01;
        mapRegion = [safemap regionThatFits:mapRegion];
        [safemap setRegion:mapRegion animated:YES];
        self.boo = false;
    }

    
//    
//    MKAnnotationView* annotationView = [safemap viewForAnnotation:userLocation];
//    annotationView.canShowCallout = YES;
//    
//    MKPlacemark *currentLocation = [[MKPlacemark alloc]initWithCoordinate:mapView.userLocation.coordinate addressDictionary:nil];
//    userLocation.title = currentLocation.title;
//    userLocation.subtitle = [NSString stringWithFormat:@"%@",
//                             (currentLocation.locality == nil ? @"" : currentLocation.locality)
//                             ];
//    
//    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
}

//drop pin annotation when search for a particular place
- (void)dropPinZoomIn:(MKPlacemark *)placemark
{
    // cache the pin
    safetyselectedPin = placemark;
    // clear existing pins
    [safemap removeAnnotations:(safemap.annotations)];
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    
    annotation.coordinate = placemark.coordinate;
    annotation.title = placemark.name;
    annotation.subtitle = [NSString stringWithFormat:@"%@",
                               (placemark.locality == nil ? @"" : placemark.locality)
                               ];



    [safemap addAnnotation:annotation];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    MKCoordinateRegion region = MKCoordinateRegionMake(placemark.coordinate, span);
    [safemap setRegion:region animated:true];
}

//current location button clicked lisenter
-(IBAction)showCurrentLocation:(id)sender
{
    MKUserLocation *userLocation = safemap.userLocation;
    if (!userLocation)
        return;
    
    MKCoordinateRegion region;
    region.center = userLocation.location.coordinate;
    region.span = MKCoordinateSpanMake(0.01, 0.01); //Zoom distance
    region = [safemap regionThatFits:region];
    [safemap setRegion:region animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Change the apperance of MKAnnotation
- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        
        //return nil so map view draws "blue dot" for standard user location
        return nil;
    }
    else if([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        MKAnnotationView *searchView = (MKAnnotationView *) [safemap dequeueReusableAnnotationViewWithIdentifier:@"search"];
        if (searchView == nil) {
            searchView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"search"];
            searchView.enabled = YES;
            searchView.canShowCallout = YES;
            searchView.tintColor = [UIColor orangeColor];
        } else {
            searchView.annotation = annotation;
        }
//        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//        [button setBackgroundImage:[UIImage imageNamed:@"car"]
//                          forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(getDirections) forControlEvents:UIControlEventTouchUpInside];
//        searchView.leftCalloutAccessoryView = button;
//        

        UIButton *safetyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [safetyButton setBackgroundImage:[UIImage imageNamed:@"Your_Safety"] forState:UIControlStateNormal];
        searchView.rightCalloutAccessoryView = safetyButton;
        
        return searchView;
    }
    else if([annotation isKindOfClass:[CustomAnnotation class]])
    {
        MKAnnotationView *searchView = (MKAnnotationView *) [safemap dequeueReusableAnnotationViewWithIdentifier:@"police"];
        if (searchView == nil) {
            searchView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"police"];
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

- (void)getDirections {
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:safetyselectedPin];
    [mapItem openInMapsWithLaunchOptions:(@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving})];
}

//Show Safe information callout button and pass data to next ViewController
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{

    if(view.rightCalloutAccessoryView && !(view.tag == 1))
    {
        BarchartViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"barchart"];
        
        
        vc.placeAddress = view.annotation.title;
        vc.suburbName = view.annotation.subtitle;

        //Retrieve safety information
        [NSThread detachNewThreadSelector: @selector(Start) toTarget:self withObject:nil];
        
        NSError *error;
        NSString *url_string = [NSString stringWithFormat: @"http://safenightout.azurewebsites.net/SafetyRankInfo.php"];
        NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
        _safetyInfo= [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        
        NSString *suburb = view.annotation.subtitle;
        for(NSArray *arr in _safetyInfo){
            if([suburb isEqualToString:[arr valueForKey:@"Suburb_name"]]){
                double value = [[arr valueForKey:@"Average_crime_rate"] doubleValue];
                NSString *safetyRank = [SafetyMapViewController estimateSafetyRank:value];
                
                vc.safetyRank = safetyRank;
                vc.crimeRate =[arr valueForKey:@"Average_crime_rate"];
                vc.council = [arr valueForKey:@"LGA"];
                
                vc.A_Type_percent =[arr valueForKey:@"A_Type"];
                vc.B_Type_percent =[arr valueForKey:@"B_Type"];
                vc.C_Type_percent =[arr valueForKey:@"C_Type"];
                vc.D_Type_percent =[arr valueForKey:@"D_Type"];
                vc.E_Type_percent =[arr valueForKey:@"E_Type"];
                vc.F_Type_percent =[arr valueForKey:@"F_Type"];
                
                vc.A_Count = [arr valueForKey:@"A_Count"];
                vc.B_Count = [arr valueForKey:@"B_Count"];
                vc.C_Count = [arr valueForKey:@"C_Count"];
                vc.D_Count = [arr valueForKey:@"D_Count"];
                vc.E_Count = [arr valueForKey:@"E_Count"];
                vc.F_Count = [arr valueForKey:@"F_Count"];
            }
        }
        [NSThread detachNewThreadSelector: @selector(Stop) toTarget:self withObject:nil];
        
        [self.navigationController pushViewController:vc animated:YES];
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

- (void) Start
{
    self.Spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.Spinner.color = [UIColor blackColor];
    self.Spinner.center = CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0);
    self.Spinner.hidden = NO;
    self.Spinner.hidesWhenStopped = YES;
    [self.view addSubview:self.Spinner];
    [self.Spinner startAnimating];
    

}

- (void) Stop
{
    [self.Spinner stopAnimating];
    self.Spinner.hidden = YES;
}

//show nearby police stations button clicked lisenter
- (IBAction)policeBtn:(UIButton *)sender {
    MKMapView *mapView = safemap;
    NSMutableArray *annotationsToRemove = [NSMutableArray arrayWithCapacity:[safemap.annotations count]];
    if(self.policeBtn.selected==YES)
    {
        [self.policeBtn setSelected:NO];
        for(int i = 0; i<[safemap.annotations count];i++){
            if([[safemap.annotations objectAtIndex:i] isKindOfClass:[CustomAnnotation class]])
            {
                [annotationsToRemove addObject:[safemap.annotations objectAtIndex:i]];
            }
        }
        [safemap removeAnnotations:annotationsToRemove];
        
        
    }
    else{
        [self.policeBtn setSelected:YES];
        [self.searchQueue cancelAllOperations];
        
        // issue new MKLoadSearch
        
        [self.searchQueue addOperationWithBlock:^{
            
            __block BOOL done = NO;
            
            MKLocalSearchRequest *requestRestaurant = [[MKLocalSearchRequest alloc] init];
            requestRestaurant.naturalLanguageQuery = @"police";
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
                    [safemap addAnnotations:annotations];
                }];
                
                done = YES;
            }];
            
            
            while (!done)
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                         beforeDate:[NSDate distantFuture]];
        }];
    }
    [_policeBtn showsTouchWhenHighlighted];
}
- (IBAction)currentLocation:(UIButton *)sender {
    MKUserLocation *userLocation = safemap.userLocation;
    if (!userLocation)
        return;
    
    MKCoordinateRegion region;
    region.center = userLocation.location.coordinate;
    region.span = MKCoordinateSpanMake(0.01, 0.01); //Zoom distance
    region = [safemap regionThatFits:region];
    [safemap setRegion:region animated:YES];
}

- (void)getInfo {

}
@end
