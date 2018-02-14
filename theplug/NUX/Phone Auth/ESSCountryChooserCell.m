//
//  ESSCountryChooserCell.m
//  ESSPhoneNumberFieldDemo
//
//  Created by Erik Strottmann on 7/12/14.
//  Copyright (c) 2014 Erik Strottmann. All rights reserved.
//

#import "ESSCountryChooserCell.h"

@interface ESSCountryChooserCell ()

@property (weak, nonatomic) IBOutlet UILabel *countryCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryNameLabel;

@end

@implementation ESSCountryChooserCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Initialization code
    self.countryCodeLabel.backgroundColor = [UIColor grayColor];
}

- (void)configureForCountry:(ESSCountry *)country
{
    self.countryCodeLabel.text = [country.callingCode isEqualToString:@""] ?
                                 @"" :
                                 [NSString stringWithFormat:@"+%@", country.callingCode];
    
    self.countryNameLabel.text = [country.name isEqualToString:@""] ? @"" : country.name;
}

@end
