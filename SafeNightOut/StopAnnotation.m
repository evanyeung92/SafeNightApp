//
//  StopAnnotation.m
//  SafeNight
//
//  Created by Evan Yeung on 3/04/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import "StopAnnotation.h"

@implementation StopAnnotation
@synthesize title;
@synthesize subtitle;
@synthesize stopId;
@synthesize coordinate;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c  title:(NSString *) t  subtitle:(NSString *)timed;
{
    self.subtitle=timed;
    self.title=t;
    self.coordinate=c;
    return self;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c title:(NSString *)tit
{
    self.coordinate=c;
    self.title=tit;
    return self;
}
@end
