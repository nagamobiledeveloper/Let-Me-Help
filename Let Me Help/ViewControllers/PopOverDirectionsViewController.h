//
//  PopOverDirectionsViewController.h
//  Let Me Help
//
//  Created by Vadlapudi, Seshu on 4/1/15.
//  Copyright (c) 2015 Naga. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GOOGLE_MAPS @"Google Maps"
#define APPLE_MAPS @"Apple Maps"
#define DRIVING @"Driving"
#define TRANSIT @"Transit"
#define WALKING @"Walking"
#define MAPS @"Maps"

@interface PopOverDirectionsViewController : UIViewController

@property(nonatomic, strong) NSString *maps;
@property(nonatomic, strong) NSArray *directionsArray;

@end
