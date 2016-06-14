//
//  PopOverDirectionsViewController.m
//  Let Me Help
//
//  Created by Vadlapudi, Seshu on 4/1/15.
//  Copyright (c) 2015 Naga. All rights reserved.
//

#import "PopOverDirectionsViewController.h"
#import "LocationObject.h"
#import <MapKit/MapKit.h>

@interface PopOverDirectionsViewController ()<UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *directionsTableView;
@property (strong, nonatomic) LocationObject *location;

@end

@implementation PopOverDirectionsViewController

#pragma mark - Life cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.location = [LocationObject getInstance];
}

-(void)dealloc {
    NSLog(@"%@ %@", self, NSStringFromSelector(_cmd));
}

#pragma mark - TableView data source methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.directionsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"directionsCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.directionsArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - TableView delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.maps isEqualToString:GOOGLE_MAPS]) {
        NSURL *url;
        if ([[self.directionsArray objectAtIndex:indexPath.row] isEqualToString:DRIVING]) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f&directionsmode=driving", self.location.latitude, self.location.longitude]];
        } else if ([[self.directionsArray objectAtIndex:indexPath.row] isEqualToString:TRANSIT]) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f&directionsmode=transit", self.location.latitude, self.location.longitude]];
        } else if ([[self.directionsArray objectAtIndex:indexPath.row] isEqualToString:WALKING]) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f&directionsmode=walking", self.location.latitude, self.location.longitude]];
        }
        [[UIApplication sharedApplication] openURL:url];
    } else if ([self.maps isEqualToString:APPLE_MAPS]){
        CLLocationCoordinate2D endingCoord = CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude);
        MKPlacemark *endLocation = [[MKPlacemark alloc] initWithCoordinate:endingCoord addressDictionary:nil];
        MKMapItem *endingItem = [[MKMapItem alloc] initWithPlacemark:endLocation];
        endingItem.name = self.location.locationName;
        NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
        if ([[self.directionsArray objectAtIndex:indexPath.row] isEqualToString:DRIVING]) {
            [launchOptions setObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];
        } else if ([[self.directionsArray objectAtIndex:indexPath.row] isEqualToString:TRANSIT]) {
            [launchOptions setObject:MKLaunchOptionsDirectionsModeTransit forKey:MKLaunchOptionsDirectionsModeKey];
        } else if ([[self.directionsArray objectAtIndex:indexPath.row] isEqualToString:WALKING]) {
            [launchOptions setObject:MKLaunchOptionsDirectionsModeWalking forKey:MKLaunchOptionsDirectionsModeKey];
        }
        [endingItem openInMapsWithLaunchOptions:launchOptions];
    }
}
@end
