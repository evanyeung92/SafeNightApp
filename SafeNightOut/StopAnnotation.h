//
//  StopAnnotation.h
//  SafeNight
//
//  Created by Evan Yeung on 3/04/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface StopAnnotation : NSObject<MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
    NSNumber *stopId;
}


@property (nonatomic)CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSNumber *stopId;


-(id)initWithCoordinate:(CLLocationCoordinate2D) c  title:(NSString *) t  subtitle:(NSString *)timed;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c title:(NSString *)tit;



@end
