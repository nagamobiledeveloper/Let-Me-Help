//
//  ViewController.m
//  Let Me Help
//
//  Created by Vadlapudi Nagaseshu on 5/27/14.
//  Copyright (c) 2014 Naga. All rights reserved.
//

#import "SearchTypesViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SearchTypesTableViewCell.h"
#import "Types.h"
#import "ResultsTableViewController.h"
#import "Reachability.h"
#import "LocationObject.h"

@interface SearchTypesViewController ()<CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *customTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *customSearchBar;

@property(nonatomic, strong) NSMutableArray *copiedArray;
@property(nonatomic, strong) NSArray *placesArray;
@property(assign)BOOL isSearching;
@property(nonatomic, strong) CLLocationManager *lManager;
@property (strong, nonatomic) Types *types;
@property (strong, nonatomic) LocationObject *location;
@property (strong, nonatomic) NSString *searchString;

@end

@implementation SearchTypesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.customSearchBar.showsCancelButton = NO;
    
    self.location = [LocationObject getInstance];
    self.lManager = [[CLLocationManager alloc] init];
    self.lManager.delegate = self;
    self.lManager.distanceFilter = kCLDistanceFilterNone;
    self.lManager.desiredAccuracy = kCLLocationAccuracyBest;
    if([self.lManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.lManager requestWhenInUseAuthorization];
    }
    [self updateCurrentLocation];
    
    self.types = [Types getInstance];
    
    [self.customTableView setAllowsSelection:YES];
    self.customTableView.delegate = self;
    self.placesArray = [[NSArray alloc] init];
    self.placesArray = [[self.types differentSearchPlacesArray] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentLocation) name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - Helpers
- (void)updateCurrentLocation {
    [self.lManager startUpdatingLocation];
}

#pragma mark - Location Manager
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    [self.location setLatitude:location.coordinate.latitude];
    [self.location setLongitude:location.coordinate.longitude];
    
    [self.lManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//    Austin
//    30.3077609,-97.7534014

//    Shanghai
//    31.2243489, 121.4767528
    
//    Dubai
//    24.979447,55.3127729
    
//    Hyderabad
//    17.439186,78.4446354
    Reachability * reach = [Reachability reachabilityWithHostname:GOOGLE_WEBSITE];
    if (![reach isReachable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"We are sorry!!"
                                                    message:@"Please connect to internet to improve user location accuracy."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
        [alert show];
        [self.lManager stopUpdatingLocation];
    }
}

#pragma mark - Table view datasource methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return [self.copiedArray count];
    }else {
        return [self.placesArray count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTypesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTypesCell"];
    if(self.isSearching) {
        if ([self.copiedArray count] != 0) {
            cell.textLabel.text = [self.copiedArray objectAtIndex:indexPath.row];
        }
    }else {
        cell.textLabel.text = [self.placesArray objectAtIndex:indexPath.row];
    }
    return cell;
}

#pragma mark - Table view delegate methods
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    } // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Segue methods
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
//    [self.location setLatitude:30.3077609];
//    [self.location setLongitude:-97.7534014];
    Reachability * reach = [Reachability reachabilityWithHostname:GOOGLE_WEBSITE];
    if ([reach isReachable] && self.location.latitude != 0.0 && self.location.longitude != 0.0) {
        return YES;
    }else if(![reach isReachable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"We are sorry!!"
                                                        message:@"Please connect to the internet to proceed."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }else if(self.location.latitude == 0.0 || self.location.longitude == 0.0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"We are sorry!!"
                                                        message:@"We are not able to get your current location. Please make sure your Location Services are turned ON."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    return NO;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.customTableView indexPathForSelectedRow];
    [self.customSearchBar resignFirstResponder];
    
    if ([[segue identifier] isEqualToString:@"selectionView"]) {
        // Get reference to the destination view controller
        ResultsTableViewController *selectionViewController = [segue destinationViewController];
        
        if (self.isSearching) {
            if ([self.copiedArray count] != 0) {
               selectionViewController.titleString = [self.copiedArray objectAtIndex:indexPath.row];
                selectionViewController.secondarySearchString = nil;
            }else {
                selectionViewController.titleString = self.searchString;
                selectionViewController.secondarySearchString = [self.searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            }
        }else {
            selectionViewController.titleString = [self.placesArray objectAtIndex:indexPath.row];
            selectionViewController.secondarySearchString = nil;
        }
    }
}

#pragma mark - Search bar delegate methods
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        self.copiedArray = [[NSMutableArray alloc] init];
        self.isSearching = YES;
        for(NSString *temString in self.placesArray) {
            NSRange titleRange = [temString rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(titleRange.length != 0) {
                [self.copiedArray addObject:temString];
            }
        }
    }else {
        self.isSearching = NO;
    }
    
    [self.customTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.customSearchBar resignFirstResponder];
    self.customSearchBar.showsCancelButton = NO;
    if ([self.copiedArray count] == 0) {
        self.searchString = [[NSString alloc] initWithString:searchBar.text];
        [self performSegueWithIdentifier:@"selectionView" sender:self];
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    searchBar.text = nil;
    self.customSearchBar.showsCancelButton = NO;
    [self.customSearchBar resignFirstResponder];
    self.isSearching = false;
    [self.customTableView reloadData];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.customSearchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.customSearchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.customSearchBar.showsCancelButton = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
