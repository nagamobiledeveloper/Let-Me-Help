//
//  LocationObject.m
//  Let Me Help
//
//  Created by Vadlapudi, Seshu on 4/1/15.
//  Copyright (c) 2015 Naga. All rights reserved.
//

#import "LocationObject.h"

static LocationObject *instance = nil;

@implementation LocationObject

+ (LocationObject *)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LocationObject alloc]init];
    });
    return instance;
}

@end
