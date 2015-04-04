//
//  Types.h
//  Let Me Help
//
//  Created by Vadlapudi Nagaseshu on 6/19/14.
//  Copyright (c) 2014 Naga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Types : NSObject

@property(nonatomic, strong) NSArray *differentSearchPlacesArray;
@property(nonatomic, strong) NSDictionary *differentSearchPlacesDictionary;
@property(nonatomic, strong) NSArray *names;

+ (Types *)getInstance;

@end
