//
//  Annotation.h
//  LatitudeAndLogitude
//
//  Created by Seshu on 7/9/13.
//  Copyright (c) 2013 Nagaseshu Vadlapudi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Annotation : NSObject<MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
