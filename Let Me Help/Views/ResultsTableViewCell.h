//
//  SelectionTableViewCell.h
//  Let Me Help
//
//  Created by Vadlapudi Nagaseshu on 7/16/14.
//  Copyright (c) 2014 Naga. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *milesLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingsLabel;

@end
