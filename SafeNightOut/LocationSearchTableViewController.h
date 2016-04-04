//
//  LocationSearchTableViewController.h
//  SafeNight
//
//  Created by Evan Yeung on 22/03/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;
#import "MapViewController.h"
@interface LocationSearchTableViewController : UITableViewController<UISearchResultsUpdating>
@property MKMapView *mapView;
@property id <HandleMapSearch>handleMapSearchDelegate;
@end
