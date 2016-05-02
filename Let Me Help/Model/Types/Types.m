//
//  Types.m
//  Let Me Help
//
//  Created by Vadlapudi Nagaseshu on 6/19/14.
//  Copyright (c) 2014 Naga. All rights reserved.
//

#import "Types.h"
static Types *instance = nil;

@implementation Types

+ (Types *)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Types alloc]init];
    });
    return instance;
}

- (id)init
{
    if (self = [super init])
    {
        self.differentSearchPlacesArray = @[@"Restaurants", @"Food Delivery", @"Food Takeaway", @"Cafe", @"Bakery", @"Grocery", @"Gas Station", @"Petrol", @"ATM", @"Banks", @"Subway Station", @"Train Station", @"Gym", @"Pharmacy", @"Hospital", @"Doctor", @"Dentist", @"Physiotherapist", @"Car Rental", @"Car Repair", @"Car Wash", @"Car Dealer", @"Laundry", @"Movie Rental", @"Movie Theater", @"Museum", @"Bar", @"Night Club", @"Liquor Store", @"Shopping Mall", @"Furniture Store", @"Electronic Store", @"Electrician", @"Hardware Store", @"Painter", @"Park", @"Parking", @"Pubs", @"Pet Store", @"Plumber", @"Police", @"Post Office", @"Locksmith", @"Fire Station", @"Florist", @"Airport", @"Amusement Park", @"Aquarium", @"Art Gallery",  @"Beauty Salon", @"Bicycle Store", @"Book Store", @"Bowling Alley", @"Bus Station", @"Campground", @"Casino", @"Cemetery", @"Church", @"City Hall", @"Clothing Store", @"Convenience Store", @"Courthouse", @"Department Store", @"Funeral Home", @"Hair Care", @"Hindu Temple", @"Home Goods", @"Insurance Agency", @"Jewelry Store", @"Lawyer", @"Library", @"Government Office", @"Lodging", @"Mosque", @"Moving Company", @"Real Estate Agency", @"Roofing Contractor", @"School", @"Shoe Store", @"Spa", @"Stadium", @"Storage", @"Store", @"Taxi Stand", @"Travel Agency", @"University", @"Veterinary Care", @"Zoo", @"RV park"];
        
        self.differentSearchPlacesDictionary = @{
                                 @"Restaurants":@"restaurant",
                                 @"Food Delivery":@"meal_delivery",
                                 @"Food Takeaway":@"meal_takeaway",
                                 @"Cafe":@"cafe",
                                 @"Campground":@"campground",
                                 @"ATM":@"atm",
                                 @"Amusement Park":@"amusement_park",
                                 @"Aquarium":@"aquarium",
                                 @"Art Gallery":@"art_gallery",
                                 
                                 @"Airport":@"airport",
                                 @"Banks":@"bank",
                                 @"Gas Station":@"gas_station",
                                 @"Bakery":@"bakery",
                                 @"Subway Station":@"subway_station",
                                 @"Train Station":@"train_station",
                                 
                                 @"Bar":@"bar",
                                 @"Beauty Salon":@"beauty_salon",
                                 @"Bicycle Store":@"bicycle_store",
                                 @"Book Store":@"book_store",
                                 @"Bowling Alley":@"bowling_alley",
                                 @"Bus Station":@"bus_station",
                                 
                                 @"Casino":@"casino",
                                 @"Cemetery":@"cemetery",
                                 @"Church":@"church",
                                 @"City Hall":@"city_hall",
                                 @"Clothing Store":@"clothing_store",
                                 @"Convenience Store":@"convenience_store",
                                 @"Courthouse":@"courthouse",
                                 @"Department Store":@"department_store",
                                 
                                 @"Funeral Home":@"funeral_home",
                                 @"Hair Care":@"hair_care",
                                 @"Hindu Temple":@"hindu_temple",
                                 @"Home Goods":@"home_goods_store",
                                 @"Insurance Agency":@"insurance_agency",
                                 @"Jewelry Store":@"jewelry_store",
                                 @"Lawyer":@"lawyer",
                                 @"Library":@"library",
                                 @"Government Office":@"local_government_office",
                                 @"Lodging":@"lodging",
                                 @"Mosque":@"mosque",
                                 @"Moving Company":@"moving_company",
                                 @"Petrol":@"gas_station",
                                 @"Real Estate Agency":@"real_estate_agency",
                                 @"Roofing Contractor":@"roofing_contractor",
                                 @"School":@"school",
                                 @"Shoe Store":@"shoe_store",
                                 @"Spa":@"spa",
                                 @"Stadium":@"stadium",
                                 @"Storage":@"storage",
                                 @"Store":@"store",
                                 @"Taxi Stand":@"taxi_stand",
                                 @"Travel Agency":@"travel_agency",
                                 @"University":@"university",
                                 @"Veterinary Care":@"veterinary_care",
                                 @"Zoo":@"zoo",
                                 @"RV park":@"rv_park",
                                 
                                 @"Shopping Mall":@"shopping_mall",
                                 @"Furniture Store":@"furniture_store",
                                 @"Electronic Store":@"electronics_store",
                                 @"Electrician":@"electrician",
                                 @"Hardware Store":@"hardware_store",
                                 
                                 @"Hospital":@"hospital",
                                 @"Doctor":@"doctor",
                                 @"Dentist":@"dentist",
                                 @"Physiotherapist":@"physiotherapist",
                                 @"Pharmacy":@"pharmacy",
                                 
                                 @"Gym":@"gym",
                                 @"Grocery":@"grocery_or_supermarket",
                                 @"Laundry":@"laundry",
                                 
                                 @"Car Rental":@"car_rental",
                                 @"Car Repair":@"car_repair",
                                 @"Car Wash":@"car_wash",
                                 @"Car Dealer":@"car_dealer",
                                 @"Movie Rental":@"movie_rental",
                                 @"Movie Theater":@"movie_theater",
                                 
                                 @"Museum":@"museum",
                                 @"Night Club":@"night_club",
                                 @"Pubs":@"night_club",
                                 @"Liquor Store":@"liquor_store",
                                 @"Painter":@"painter",
                                 @"Park":@"park",
                                 @"Parking":@"parking",
                                 @"Pet Store":@"pet_store",
                                 
                                 @"Plumber":@"plumber",
                                 @"Locksmith":@"locksmith",
                                 @"Police":@"police",
                                 @"Post Office":@"post_office",
                                 
                                 @"Fire Station":@"fire_station",
                                 @"Florist":@"florist"
                                 };
        
    }
    return self;
}
@end
