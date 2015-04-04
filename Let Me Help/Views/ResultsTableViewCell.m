//
//  SelectionTableViewCell.m
//  Let Me Help
//
//  Created by Vadlapudi Nagaseshu on 7/16/14.
//  Copyright (c) 2014 Naga. All rights reserved.
//

#import "ResultsTableViewCell.h"

@implementation ResultsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
