//
//  LocationObject.h
//  Let Me Help
//
//  Created by Vadlapudi, Seshu on 4/1/15.
//  Copyright (c) 2015 Naga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationObject : NSObject

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, strong) NSString *locationName;

+ (LocationObject *)getInstance;

@end
