//
//  PopOverTableViewController.m
//  Let Me Help
//
//  Created by Vadlapudi, Seshu on 3/31/15.
//  Copyright (c) 2015 Naga. All rights reserved.
//

#import "PopOverMapsViewController.h"

@interface PopOverMapsViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *customTableView;

@end

@implementation PopOverMapsViewController

#pragma mark - Life cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = MAPS;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView data source methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.mapsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mapsCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.mapsArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - TableView delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSBundle *lmhBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"LMHResources" ofType:@"bundle"]];
    
    // now load and show updated results popover
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:lmhBundle];
    PopOverDirectionsViewController *popoverDirectionsViewController = [storyboard instantiateViewControllerWithIdentifier:@"popOverDirectionsVC"];
    
    if ([[self.mapsArray objectAtIndex:indexPath.row] isEqualToString:GOOGLE_MAPS]) {
        popoverDirectionsViewController.maps = GOOGLE_MAPS;
        popoverDirectionsViewController.directionsArray = @[DRIVING, TRANSIT, WALKING];
    } else {
        popoverDirectionsViewController.maps = APPLE_MAPS;
        popoverDirectionsViewController.directionsArray = @[DRIVING, WALKING];
    }
    
    [self.navigationController pushViewController:popoverDirectionsViewController animated:YES];
}

@end