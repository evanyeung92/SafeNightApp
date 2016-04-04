//
//  CustomAnnotation.h
//  SafeNight
//
//  Created by Evan Yeung on 1/04/2016.
//  Copyright © 2016 Evan Yeung. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomAnnotation : MKPlacemark
{
    
    NSString *title;
    NSString *subtitle;
    NSString *time;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic,retain) NSString *time;
@property (nonatomic,retain) NSString *phone;




@end
