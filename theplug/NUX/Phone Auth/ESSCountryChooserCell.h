//
//  ESSCountryChooserCell.h
//  ESSPhoneNumberFieldDemo
//
//  Created by Erik Strottmann on 7/12/14.
//  Copyright (c) 2014 Erik Strottmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESSCountry.h"

@interface ESSCountryChooserCell : UITableViewCell

/** Assigns the cell's country code and name labels to the country's values. */
- (void)configureForCountry:(ESSCountry *)country;

@end
