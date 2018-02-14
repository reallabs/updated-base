//
//  ESSPhoneNumberField.h
//  ESSPhoneNumberFieldDemo
//
//  Created by Erik Strottmann on 7/11/14.
//  Copyright (c) 2014 Erik Strottmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESSCountryChooser.h"
#import "CountryNameView.h"

@protocol ESSPhoneNumberFieldDelegate <NSObject>

- (void) onNumberInput;

@end

@interface ESSPhoneNumberField : UIControl <ESSCountryChooserDelegate, UITextFieldDelegate>

/** The E.164 standard limits phone numbers to 15 characters. */
extern NSUInteger const kESSPhoneNumberMaximumLength;
/** Default placeholder text for ::nationalPhoneNumberField. */
extern NSString * const kESSPhoneNumberFieldDefaultPlaceholder;

/**
 * A button designed to present a modal ESSCountryCodePicker when tapped.
 * Displays ::countryCode. Recommended use: present a modal country code picker
 * on touch up inside this button, and set the phone number field as its
 * delegate.
 */
@property (readonly, nonatomic) UIButton *countryCodeButton;
/**
 * A text field where the user enters the national portion of the phone number,
 * ::nationalPhoneNumber.
 */
@property (readwrite, nonatomic) UITextField *nationalPhoneNumberField;

@property (readwrite, nonatomic) CountryNameView *countryNameView;

/** The phone number, in E.164 format, displayed in the phone number field. */
@property (readonly, nonatomic) NSString *phoneNumberE164;
/** The country calling code displayed in the phone number field, without +. */
@property (nonatomic) NSString *countryCode;
/** The national portion of the phone number displayed in the phone number field. */
@property (nonatomic) NSString *nationalPhoneNumber;
/**
 * The phone number displayed in the phone number field, formatted in the
 * international style but without the country code,.
 */
@property (readonly, nonatomic) NSString *nationalPhoneNumberFormatted;


@property (nonatomic, readwrite, weak) id<ESSPhoneNumberFieldDelegate> delegate;

@end
