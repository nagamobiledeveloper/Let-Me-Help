//
//  SelectionTableViewController.m
//  Let Me Help
//
//  Created by Vadlapudi Nagaseshu on 7/16/14.
//  Copyright (c) 2014 Naga. All rights reserved.
//

#import "ResultsTableViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ResultsTableViewCell.h"
#import "ResultDetailViewController.h"
#import "Types.h"
#import "Reachability.h"
#import "LocationObject.h"
#import "SearchTypesViewController.h"

#define MINIMUM_COUNT 7

@interface ResultsTableViewController ()<NSURLConnectionDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *customSelectionTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *customActivityIndicator;

@property (strong, nonatomic) Types *types;
@property (strong, nonatomic) NSString *searchType;
@property (strong, nonatomic) NSMutableArray *secondTimeConnectionArray;
@property (strong, nonatomic) LocationObject *location;

@property (nonatomic, strong) NSArray *namesArray;
@property (nonatomic, strong) NSArray *addressArray;
@property (nonatomic, strong) NSArray *milesArray;
@property (nonatomic, strong) NSArray *placeIDArray;
@property (nonatomic, strong) NSArray *ratingsArray;

@end

@implementation ResultsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.titleString;
    self.customSelectionTableView.delegate = self;
    [self.customActivityIndicator startAnimating];
    self.types = [Types getInstance];
    self.searchType = [[self.types differentSearchPlacesDictionary] valueForKey:self.titleString];
    self.location = [LocationObject getInstance];
    
    if (self.secondarySearchString != nil) {
        [self connectToTheServerForSecondTime];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@location=%f,%f&types=%@&rankby=distance&opennow&sensor=false&key=%@", GOOGLE_NEARBY_SEARCH, self.location.latitude, self.location.longitude, self.searchType, GOOGLE_SEARCH_KEY]];
    
    NSURLSession *firstSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *firstTask = [firstSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data!=nil)
        {
            id jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSArray *results = [jsonData valueForKey:@"results"];
            
            if ([results count] > MINIMUM_COUNT)
            {
                NSArray *geometry = [results valueForKey:@"geometry"];
                self.namesArray = [results valueForKey:@"name"];
                self.addressArray = [results valueForKey:@"vicinity"];
                self.milesArray = [self getDistanceFromCurrentLocation:[geometry valueForKey:@"location"]];
                self.placeIDArray = [results valueForKey:@"place_id"];
                self.ratingsArray = [results valueForKey:@"rating"];
                
                results = nil;
                jsonData = nil;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setTheDataInTheTableView];
                });
            }else
            {
                [self connectToTheServerForSecondTime];
            }
        }
    }];
    
    [firstTask resume];
}

-(NSArray *)getDistanceFromCurrentLocation:(NSArray *)locationDetails
{
    NSMutableArray *milesArray = [[NSMutableArray alloc] init];
    for (NSDictionary *latLong in locationDetails)
    {
        id lat = [latLong valueForKey:@"lat"];
        id lng = [latLong valueForKey:@"lng"];
        
        CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
        CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:self.location.latitude longitude:self.location.longitude];
        CLLocationDistance distance = [userLocation distanceFromLocation:placeLocation];
        [milesArray addObject:[NSString stringWithFormat:@"%.1f",(distance*0.000621371)]];
    }
    return milesArray;
}

-(void)connectToTheServerForSecondTime
{
    NSURL *url;
    if (self.secondarySearchString != nil) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?location=%f,%f&radius=50000&opennow&query=%@&key=%@", self.location.latitude, self.location.longitude, self.secondarySearchString, GOOGLE_SEARCH_KEY]];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@location=%f,%f&radius=50000&types=%@&opennow&sensor=false&key=%@", GOOGLE_NEARBY_SEARCH, self.location.latitude, self.location.longitude, self.searchType, GOOGLE_SEARCH_KEY]];
    }
    
    NSURLSession *secondSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *secondTask = [secondSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        id jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSArray *results = [jsonData valueForKey:@"results"];
        if ([results count] != 0 && error == nil)
        {
            self.searchType = nil;
            NSArray *geometry = [results valueForKey:@"geometry"];
            NSArray *calculatedMiles = [self getDistanceFromCurrentLocation:[geometry valueForKey:@"location"]];
            self.secondTimeConnectionArray = [[NSMutableArray alloc] init];
            
            NSString *str = [[results valueForKey:@"vicinity"] objectAtIndex:0];
            if ([str class] == [NSNull class]) {
                for (int i=0; i<[[results valueForKey:@"name"] count]; i++) {
                    NSDictionary *dict = @{
                                           @"name":[[results valueForKey:@"name"] objectAtIndex:i],
                                           @"vicinity":[[[results valueForKey:@"formatted_address"]objectAtIndex:i]stringByReplacingOccurrencesOfString:@", United States" withString:@""],
                                           @"miles":[calculatedMiles objectAtIndex:i],
                                           @"sorting":[NSString stringWithFormat:@"%@, %d", [calculatedMiles objectAtIndex:i], i],
                                           @"place_id":[[results valueForKey:@"place_id"]objectAtIndex:i],
                                           @"rating":[[results valueForKey:@"rating"]objectAtIndex:i]
                                           };
                    [self.secondTimeConnectionArray addObject:dict];
                }
                
            } else {
                for (int i=0; i<[[results valueForKey:@"name"] count]; i++)
                {
                    NSDictionary *dict = @{
                                           @"name":[[results valueForKey:@"name"] objectAtIndex:i],
                                           @"vicinity":[[results valueForKey:@"vicinity"] objectAtIndex:i],
                                           @"miles":[calculatedMiles objectAtIndex:i],
                                           @"sorting":[NSString stringWithFormat:@"%@, %d", [calculatedMiles objectAtIndex:i], i],
                                           @"place_id":[[results valueForKey:@"place_id"]objectAtIndex:i],
                                           @"rating":[[results valueForKey:@"rating"]objectAtIndex:i]
                                           };
                    [self.secondTimeConnectionArray addObject:dict];
                }
                
            }
            
            NSArray *mile = [self.secondTimeConnectionArray valueForKey:@"sorting"];
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"doubleValue" ascending:YES];
            NSArray *sortedArray = [mile sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
            NSMutableArray* myArray = [[NSMutableArray alloc] init];
            for (NSString *numberString in sortedArray)
            {
                [myArray addObjectsFromArray:[numberString componentsSeparatedByString:@","]];
            }
            NSMutableArray* indexArray = [[NSMutableArray alloc] init];
            for (int i=0; i<[myArray count]; i++)
            {
                if (i%2!=0)
                {
                    [indexArray addObject:[myArray objectAtIndex:i]];
                }
            }
            results = nil;
            jsonData = nil;
            calculatedMiles = nil;
            
            NSMutableArray *sortedAccordingToMiles = [[NSMutableArray alloc] initWithCapacity:[indexArray count]];
            for (int i = 0; i<[indexArray count]; i++)
            {
                [sortedAccordingToMiles addObject:[self.secondTimeConnectionArray objectAtIndex:[[indexArray objectAtIndex:i] integerValue]]];
            }
            self.secondTimeConnectionArray = nil;
            indexArray = nil;
            myArray = nil;
            
            self.namesArray = [sortedAccordingToMiles valueForKey:@"name"];
            self.addressArray = [sortedAccordingToMiles valueForKey:@"vicinity"];
            self.milesArray = [sortedAccordingToMiles valueForKey:@"miles"];
            self.placeIDArray = [sortedAccordingToMiles valueForKey:@"place_id"];
            self.ratingsArray = [sortedAccordingToMiles valueForKey:@"rating"];
            
            sortedAccordingToMiles = nil;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setTheDataInTheTableView];
            });
        }else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.customActivityIndicator stopAnimating];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"We are Sorry!!"
                                                                message:[NSString stringWithFormat:@"We didn't find any %@ open at this time near your current location. Please try again later.", self.titleString]
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
                NSArray *viewControllers = self.navigationController.viewControllers;
                [self.navigationController popToViewController:[viewControllers firstObject] animated:YES];
            });
        }
    }];
    
    [secondTask resume];
}

-(void)setTheDataInTheTableView
{
    [self.customActivityIndicator stopAnimating];
    [self.customSelectionTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.namesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsTableViewCell"];
    
    cell.nameLabel.text = [self.namesArray objectAtIndex:indexPath.row];
    cell.addressLabel.text = [self.addressArray objectAtIndex:indexPath.row];
    
    if ([self.ratingsArray objectAtIndex:indexPath.row] != nil && ![[self.ratingsArray objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]]) {
        cell.ratingsLabel.text = [NSString stringWithFormat:@"Rating: %@/5", [self.ratingsArray objectAtIndex:indexPath.row]];
    } else {
        cell.ratingsLabel.text = @"";
    }
    
    cell.milesLabel.text = [NSString stringWithFormat:@"%@ Miles", [self.milesArray objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - Table view delegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
    {
        [cell setPreservesSuperviewLayoutMargins:NO];
    } // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Segue methods
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    Reachability * reach = [Reachability reachabilityWithHostname:GOOGLE_WEBSITE];
    if ([reach isReachable])
    {
        return YES;
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"We are Sorry!!"
                                                        message:@"Please connect to the internet to proceed."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"placeDetails"])
    {
        ResultsTableViewCell *cell = (ResultsTableViewCell *)sender;
        NSIndexPath *indexPath = [self.customSelectionTableView indexPathForSelectedRow];
        NSString *placeID = [self.placeIDArray objectAtIndex:indexPath.row];
        ResultDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.placeID = placeID;
        detailViewController.titleString = cell.nameLabel.text;
    }
}


@end
