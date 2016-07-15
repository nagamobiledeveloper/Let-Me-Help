//
//  DetailViewController.m
//  Let Me Help
//
//  Created by Vadlapudi Nagaseshu on 7/15/14.
//  Copyright (c) 2014 Naga. All rights reserved.
//

#import "ResultDetailViewController.h"
#import <MapKit/MapKit.h>
#import "Annotation.h"
#import "PopOverMapsViewController.h"
#import "LocationObject.h"
#import "WebViewController.h"

#define BUTTON_INDEX_ZERO 0
#define BUTTON_INDEX_ONE 1
#define BUTTON_INDEX_TWO 2

@interface ResultDetailViewController ()<MKMapViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *phoneButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *takeMeHereButtonOutlet;
@property (weak, nonatomic) IBOutlet MKMapView *customMapView;
@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *customActivityIndicator;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *website;
@property (strong, nonatomic) NSString *hours;

@property double latitude;
@property double longitude;
@property (nonatomic, strong) UIPopoverController *popoverVC;
@property (strong, nonatomic) LocationObject *location;

@property (strong, nonatomic) IBOutlet UIActionSheet *customActionSheet;
@property (strong, nonatomic) IBOutlet UIActionSheet  *googleMapsActionSheet;
@property (strong, nonatomic) IBOutlet UIActionSheet  *appleMapsActionSheet;

@end

@implementation ResultDetailViewController

#pragma mark - Life cycle methods
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closePopOver) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.titleString;;
    [self.customActivityIndicator startAnimating];
    self.location = [LocationObject getInstance];
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@placeid=%@&key=%@", PLACE_DETAILS_API, self.placeID, SEARCH_KEY]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            id jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSArray *result = [jsonData valueForKey:@"result"];
            
            self.name = [result valueForKey:@"name"];
            self.address = [result valueForKey:@"vicinity"];
            self.phone = [result valueForKey:@"formatted_phone_number"];
            self.website = [result valueForKey:@"website"];
            NSDictionary *openHours = [result valueForKey:@"opening_hours"];
            NSArray *weekHours = [openHours valueForKey:@"weekday_text"];
            NSMutableArray *weeks;
            if (weekHours != NULL && weekHours.count == 7) {
                weeks = [[NSMutableArray alloc] initWithArray:weekHours];
                id object = [weeks objectAtIndex:6];
                [weeks removeObjectAtIndex:6];
                [weeks insertObject:object atIndex:0];
            }
            
            NSCalendarUnit dayOfTheWeek = [[NSCalendar currentCalendar] component:NSCalendarUnitWeekday fromDate:[NSDate date]];
            if (weeks != NULL) {
                self.hours = [weeks objectAtIndex:dayOfTheWeek-1];
            }
            
            NSArray *geometry = [result valueForKey:@"geometry"];
            NSArray *location = [geometry valueForKey:@"location"];
            self.latitude =  [[location valueForKey:@"lat"] doubleValue];
            self.longitude = [[location valueForKey:@"lng"] doubleValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayInformationOnTheView];
            });
        }
    }];
    
    [dataTask resume];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)dealloc {
    NSLog(@"%@ %@", self, NSStringFromSelector(_cmd));
}

#pragma mark - Actions
- (IBAction)phoneButtonSelected:(id)sender {
    if (self.phone != nil) {
        NSString *phoneNumber = [@"telprompt://" stringByAppendingString:self.phone];
        NSURL *rul = [NSURL URLWithString: [phoneNumber stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:rul];
    }
}

- (IBAction)takeMeHereButtonClicked:(id)sender {
    self.location.locationName = self.name;
    self.location.latitude =  self.latitude;
    self.location.longitude = self.longitude;
    
    BOOL canHandle = [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"comgooglemaps://"]];
    self.customActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: APPLE_MAPS, nil];
    NSMutableArray *mapsArray = [[NSMutableArray alloc] init];
    [mapsArray addObject:APPLE_MAPS];
    if (canHandle) {
        [self.customActionSheet addButtonWithTitle:GOOGLE_MAPS];
        [mapsArray addObject:GOOGLE_MAPS];
    }
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        NSBundle *lmsBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"LMHResources" ofType:@"bundle"]];
        
        // now load and show updated results popover
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:lmsBundle];
        
        UINavigationController *popoverNavigationViewController = [storyboard instantiateViewControllerWithIdentifier:@"popOverMapsNavigationVC"];
        
        PopOverMapsViewController *popoverViewController = [storyboard instantiateViewControllerWithIdentifier:@"popOverMapsVC"];
        popoverViewController.mapsArray = mapsArray;
        
        popoverNavigationViewController.viewControllers = @[popoverViewController];
        self.popoverVC = [[UIPopoverController alloc] initWithContentViewController:popoverNavigationViewController];
        [self.popoverVC presentPopoverFromRect:[self.takeMeHereButtonOutlet frame] inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown animated:YES];
        
    } else {
        self.customActionSheet.tag = 1;
        [self.customActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    
}

#pragma mark - Action sheet delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.customActionSheet) {
        [self.customActionSheet resignFirstResponder];
        if (buttonIndex == BUTTON_INDEX_TWO) {
            self.googleMapsActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:DRIVING, TRANSIT, WALKING,nil];
            self.googleMapsActionSheet.tag = 1;
            [self.googleMapsActionSheet showInView:[UIApplication sharedApplication].keyWindow];
        } else if(buttonIndex == BUTTON_INDEX_ZERO) {
            self.appleMapsActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:DRIVING, TRANSIT, WALKING,nil];
            self.appleMapsActionSheet.tag = 1;
            [self.appleMapsActionSheet showInView:[UIApplication sharedApplication].keyWindow];
        }
    } else if (actionSheet == self.googleMapsActionSheet && buttonIndex < 3) {
        NSURL *url;
        if (buttonIndex == BUTTON_INDEX_ZERO) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f&directionsmode=driving", self.latitude, self.longitude]];
        } else if (buttonIndex == BUTTON_INDEX_ONE) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f&directionsmode=transit", self.latitude, self.longitude]];
        } else if (buttonIndex == BUTTON_INDEX_TWO) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f&directionsmode=walking", self.latitude, self.longitude]];
        }
        if (url != nil) {
            [[UIApplication sharedApplication] openURL:url];
        }
    } else if (actionSheet == self.appleMapsActionSheet && buttonIndex < 3){
        CLLocationCoordinate2D endingCoord = CLLocationCoordinate2DMake(self.latitude, self.longitude);
        MKPlacemark *endLocation = [[MKPlacemark alloc] initWithCoordinate:endingCoord addressDictionary:nil];
        MKMapItem *endingItem = [[MKMapItem alloc] initWithPlacemark:endLocation];
        endingItem.name = self.name;
        NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
        if (buttonIndex == BUTTON_INDEX_ZERO) {
            [launchOptions setObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];
        } else if (buttonIndex == BUTTON_INDEX_ONE) {
            [launchOptions setObject:MKLaunchOptionsDirectionsModeTransit forKey:MKLaunchOptionsDirectionsModeKey];
        } else if (buttonIndex == BUTTON_INDEX_TWO) {
            [launchOptions setObject:MKLaunchOptionsDirectionsModeWalking forKey:MKLaunchOptionsDirectionsModeKey];
        }
        if (launchOptions != nil) {
            [endingItem openInMapsWithLaunchOptions:launchOptions];
        }
    }
}

#pragma mark - Helper methods
- (void)displayInformationOnTheView {
    [self.customActivityIndicator stopAnimating];
    self.customMapView.delegate = self;
    
    self.nameLabel.text = self.name;
    self.addressLabel.text = self.address;
    self.hoursLabel.text = self.hours;
    [self.phoneButtonOutlet setTitle:self.phone forState:UIControlStateNormal];
    [self.takeMeHereButtonOutlet setTitle:@"Take Me Here" forState:UIControlStateNormal];
    
    MKCoordinateSpan spanCordinate;
    spanCordinate.latitudeDelta = 0.6f;
    spanCordinate.longitudeDelta = 0.6f;
    
    CLLocationCoordinate2D pinCordinate;
    pinCordinate.latitude = self.latitude;
    pinCordinate.longitude = self.longitude;
    
    MKCoordinateRegion region;
    region.center = pinCordinate;
    region.span = spanCordinate;
    
    Annotation *myAnn;
    NSMutableArray *annotationObjects = [[NSMutableArray alloc]init];
    
    // Adding different annotations
    myAnn = [[Annotation alloc]init];
    myAnn.coordinate = pinCordinate;
    myAnn.title = self.name;
    myAnn.subtitle = self.address;
    [annotationObjects addObject:myAnn];
    
    [self.customMapView addAnnotations:annotationObjects];
    [self.customMapView setRegion:region animated:YES];
    
    if (self.website != nil && ![self.website isKindOfClass:[NSNull class]]) {
        NSBundle *lmhBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"LMHResources" ofType:@"bundle"]];
        NSString *path = [lmhBundle pathForResource:@"web" ofType:@"png"];
        UIImage* webImage = [UIImage imageWithContentsOfFile:path];
        
        UIBarButtonItem *websiteButton = [[UIBarButtonItem alloc] initWithImage:webImage style:UIBarButtonItemStylePlain target:self action:@selector(showWebsite)];
        
        websiteButton.tintColor = [UIColor blueColor];
        self.navigationItem.rightBarButtonItem = websiteButton;
    }
}

- (void)closePopOver {
    if (self.popoverVC && self.popoverVC.isPopoverVisible) {
        [self.popoverVC dismissPopoverAnimated:NO];
        self.popoverVC = nil;
    }
}

- (void)showWebsite {
    NSBundle *lmsBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"LMHResources" ofType:@"bundle"]];
    
    // now load and show updated results popover
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:lmsBundle];
    
    WebViewController *webViewController = [storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
    webViewController.url = self.website;
    [self presentViewController:webViewController animated:YES completion:nil];
}

@end
