//
//  ESSCountryChooser.h
//  ESSPhoneNumberFieldDemo
//
//  Created by Erik Strottmann on 7/11/14.
//  Copyright (c) 2014 Erik Strottmann. All rights reserved.
//

#import "ESSCountry.h"

#import <UIKit/UIKit.h>

@class ESSCountryChooser;

#pragma mark - ESSCountryChooserDelegate

@protocol ESSCountryChooserDelegate <NSObject>

@required
- (void)countryChooser:(ESSCountryChooser *)countryChooser didSelectCountry:(ESSCountry *)country;
@optional
- (void)countryChooserDidCancel:(ESSCountryChooser *)countryChooser;

@end

#pragma mark - ESSCountryChooser

@interface ESSCountryChooser : UITableViewController

/** Default value for ::defaultSectionTitle. */
extern NSString * const kESSCountryChooserDefaultDefaultSectionTitle;
/** Default value for ::dismissDelay. */
extern NSTimeInterval const kESSCountryChooserDefaultDismissDelay;

@property (weak, nonatomic) id<ESSCountryChooserDelegate> delegate;

/**
 * The row containing the default locale, and its corresponding country code, is
 * displayed at the top of the list, and is selected by default. By default,
 * defaultLocale is set to the device's current locale. If nil, no row will be
 * displayed at the top or selected by default.
 */
@property (nonatomic) NSLocale *defaultLocale;
/** To set, use ::defaultLocale. */
@property (readonly, nonatomic) ESSCountry *defaultCountry;
@property (nonatomic) ESSCountry *selectedCountry;
/**
 * The title for the "default" section, if present.
 * ::kESSCountryChooserDefaultDefaultSectionTitle by default.
 */
@property (nonatomic) NSString *defaultSectionTitle;
/**
 * The time interval between row selection and chooser dismissal.
 * ::kESSCountryChooserDefaultDismissDelay by default.
 */
@property (nonatomic) NSTimeInterval dismissDelay;

/** Cancels the chooser without changing ::selectedCountry. */
- (void)cancelChooser;

@end
