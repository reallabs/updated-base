//
//  ESSPhoneNumberField.m
//  ESSPhoneNumberFieldDemo
//
//  Created by Erik Strottmann on 7/11/14.
//  Copyright (c) 2014 Erik Strottmann. All rights reserved.
//

#import "ESSPhoneNumberField.h"
#import "ESSCountryChooser.h"

#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"

@interface ESSPhoneNumberField ()

/**
 * A button designed to present a modal ESSCountryChooser when tapped. Displays
 * ::countryCode. Recommended use: present a modal country chooser on touch up
 * inside this button, and set the phone number field as its delegate.
 */
@property (readwrite, nonatomic) UIButton *countryCodeButton;
/**
 * A text field where the user enters the national portion of the phone number,
 * ::nationalPhoneNumber.
 */
//@property (readwrite, nonatomic) UITextField *nationalPhoneNumberField;

@end

@implementation ESSPhoneNumberField

#pragma mark - Constants

NSUInteger const kESSPhoneNumberMaximumLength = 15;
NSString * const kESSPhoneNumberFieldDefaultPlaceholder = @"Phone Number";
/** Used to size the button. */
NSString * const kESSPhoneNumberFieldMaxWidthString = @" +888 ";
/** Width of the padding on the left side of ::nationalPhoneNumberField. */
CGFloat const kESSPhoneNumberFieldLeftPadding = 8.0f;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

/** Universal initializer - called by ::initWithFrame and ::initWithCoder. */
- (void)initialize
{
    [self setUpSubviews];
}

#pragma mark - Properties

- (NSString *)phoneNumberE164
{
    if ([self.nationalPhoneNumber isEqualToString:@""]) {
        return @"";
    }
    
    return [self phoneNumberWithFormat:NBEPhoneNumberFormatE164];
}

- (NSString *)nationalPhoneNumberFormatted
{
    NSString *phoneNumber = [self phoneNumberWithFormat:NBEPhoneNumberFormatINTERNATIONAL];
    
    NSUInteger countryCodeEndIndex = self.countryCode.length + 2; // extra chars for + and space
    if (phoneNumber.length >= countryCodeEndIndex &&
        [[phoneNumber substringToIndex:countryCodeEndIndex] isEqualToString:[NSString stringWithFormat:@"+%@ ", self.countryCode]]) {
        
        phoneNumber = [phoneNumber substringFromIndex:countryCodeEndIndex];
    }
    
    return phoneNumber;
}

- (void)setCountryCode:(NSString *)countryCode
{
    _countryCode = countryCode;
    [self.countryCodeButton setTitle:([_countryCode isEqualToString:@""] ?
                                      @"" :
                                      [NSString stringWithFormat:@"+%@", _countryCode])
                            forState:UIControlStateNormal];
}

- (void)setNationalPhoneNumber:(NSString *)nationalPhoneNumber
{
    _nationalPhoneNumber = nationalPhoneNumber;
    
    if (!nationalPhoneNumber || [nationalPhoneNumber isEqualToString:@""]) {
        self.nationalPhoneNumberField.text = @"";
    } else {
        self.nationalPhoneNumberField.text = [self nationalPhoneNumberFormatted];
    }
}

/** Helper to return formatted versions of the phone number. */
- (NSString *)phoneNumberWithFormat:(NBEPhoneNumberFormat)format
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    NBPhoneNumber *phoneNumber = [[NBPhoneNumber alloc] init];
    phoneNumber.countryCode = [formatter numberFromString:self.countryCode];
    phoneNumber.nationalNumber = [formatter numberFromString:self.nationalPhoneNumber];
    
    return [[NBPhoneNumberUtil sharedInstance] format:phoneNumber numberFormat:format error:nil];
}

/** Returns only the decimal digit characters from the string argument. */
- (NSString *)numberCharactersFromString:(NSString *)string
{
    if (!string) { return string; }
    if (string.length < 1) { return @""; }
    return [[string componentsSeparatedByCharactersInSet:
             [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
            componentsJoinedByString:@""];
}

#pragma mark - Subviews

/** Allocates and initializes subviews. */
- (void)setUpSubviews
{
    self.countryCodeButton = [[UIButton alloc] init];
    self.countryCodeButton.titleLabel.font = [UIFont systemFontOfSize:32.0 weight:UIFontWeightHeavy];
    [self addSubview:self.countryCodeButton];
    
    self.nationalPhoneNumberField = [[UITextField alloc] init];
    self.nationalPhoneNumberField.delegate = self;
    self.nationalPhoneNumberField.tintColor = [UIColor whiteColor];
    self.nationalPhoneNumberField.keyboardType = UIKeyboardTypeNumberPad;
    self.nationalPhoneNumberField.font = [UIFont systemFontOfSize:32.0 weight:UIFontWeightHeavy];
    [self addSubview:self.nationalPhoneNumberField];
    
//    self.countryNameView = [[CountryNameView alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(self.layer.frame), CGRectGetHeight(self.layer.frame) / 2)];
//    [self addSubview:self.countryNameView];
    
    [self setUpLayout];
    [self styleSubviews];
}

/** Sets up layout constraints for subviews. */
- (void)setUpLayout
{
    CGRect countryFrame = CGRectMake(0,0,CGRectGetWidth(self.layer.frame) * 0.163, CGRectGetHeight(self.layer.frame));
    self.countryCodeButton.frame = countryFrame;
    
    CGRect numberFrame = CGRectMake(CGRectGetWidth(self.layer.frame) * 0.163,0,CGRectGetWidth(self.layer.frame) - (CGRectGetWidth(self.layer.frame) * 0.163), CGRectGetHeight(self.layer.frame));
    self.nationalPhoneNumberField.frame = numberFrame;
}

- (void)styleSubviews
{
    self.countryCodeButton.backgroundColor = [UIColor accentColor];
    self.countryCodeButton.titleLabel.textColor = [UIColor whiteColor];
    [self.countryCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    self.nationalPhoneNumberField.backgroundColor = [UIColor accentColor];
    self.nationalPhoneNumberField.textColor = [UIColor whiteColor];
    self.nationalPhoneNumberField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:kESSPhoneNumberFieldDefaultPlaceholder attributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0 alpha:0.4]}];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kESSPhoneNumberFieldLeftPadding, 0)];
    self.nationalPhoneNumberField.leftView = paddingView;
    self.nationalPhoneNumberField.leftViewMode = UITextFieldViewModeAlways;
    
//    CALayer *topBorder = [CALayer layer];
//    topBorder.borderColor = [UIColor blackColor].CGColor;
//    topBorder.borderWidth = 1;
//    topBorder.frame = CGRectMake(-1, CGRectGetHeight(self.countryCodeButton.frame), CGRectGetWidth(self.layer.frame)+2, 1);
//    [self.layer addSublayer:topBorder];
//    
//    CALayer *bottomBorder = [CALayer layer];
//    bottomBorder.borderColor = [UIColor blackColor].CGColor;
//    bottomBorder.borderWidth = 1;
//    bottomBorder.frame = CGRectMake(-1, CGRectGetHeight(self.layer.frame) - 1, CGRectGetWidth(self.layer.frame)+2, 1);
//    [self.layer addSublayer:bottomBorder];
//    
//    CALayer *rightBorder = [CALayer layer];
//    rightBorder.borderColor = [UIColor blackColor].CGColor;
//    rightBorder.borderWidth = 1;
//    rightBorder.frame = CGRectMake(CGRectGetMaxX(self.countryCodeButton.frame) - 1, CGRectGetHeight(self.countryCodeButton.frame), 1, CGRectGetHeight(self.countryCodeButton.frame));
//    [self.layer addSublayer:rightBorder];
}

#pragma mark - Control events

- (UIControlEvents)allControlEvents
{
    return UIControlEventEditingChanged;
}

#pragma mark - ESSCountryChooserDelegate

- (void)countryChooser:(ESSCountryChooser *)countryChooser didSelectCountry:(ESSCountry *)country;
{
    self.countryCode = country.callingCode;
    [self.countryNameView setCountryName:country.name];
    if (self.nationalPhoneNumber) {
        // reload nationalPhoneNumberField formatting
        self.nationalPhoneNumber = self.nationalPhoneNumber;
    }
    
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString
{
    if (textField != self.nationalPhoneNumberField) {
        return YES;
    }
    
    [_delegate onNumberInput];
    // Replace the characters
    NSString *substringBeforeRange = [textField.text substringToIndex:range.location];
    NSString *digitsBeforeRange = [self numberCharactersFromString:substringBeforeRange];
    
    NSString *substringInRange = [textField.text substringWithRange:range];
    NSString *digitsInRange = [self numberCharactersFromString:substringInRange];
    
    NSString *substringAfterRange = [textField.text substringFromIndex:(range.location + range.length)];
    NSString *digitsAfterRange = [self numberCharactersFromString:substringAfterRange];
    
    NSString *replacementDigits = [self numberCharactersFromString:replacementString];
    
    if (digitsInRange.length == 0 && substringInRange.length > 0 &&
        replacementDigits.length == 0 && replacementString.length == 0) {
        // Trying to delete only formatting characters
        // Instead, delete exactly one digit
        if (digitsBeforeRange.length > 0) {
            digitsBeforeRange = [digitsBeforeRange substringToIndex:digitsBeforeRange.length - 1];
        }
    }
    
    // Limit phone number length to kESSPhoneNumberMaximumLength
    NSInteger maxReplacementLength = ((NSInteger) kESSPhoneNumberMaximumLength) -
                                     self.countryCode.length -
                                     digitsBeforeRange.length -
                                     digitsAfterRange.length;

    if (((NSInteger) replacementDigits.length) > maxReplacementLength) {
        replacementDigits = maxReplacementLength >= 0 ?
                            [replacementDigits substringToIndex:maxReplacementLength] :
                            @"";
    }
    
    self.nationalPhoneNumber = [NSString stringWithFormat:@"%@%@%@", digitsBeforeRange, replacementDigits, digitsAfterRange];
    
    [_delegate onNumberInput];
    
    // Put the cursor back where it belongs
    NSUInteger cursorIndex = [self string:self.nationalPhoneNumberField.text indexAfterNthDigit:digitsBeforeRange.length] + replacementDigits.length;
    UITextPosition *cursorPosition = [textField positionFromPosition:textField.beginningOfDocument offset:cursorIndex];
    UITextRange *cursorRange = [textField textRangeFromPosition:cursorPosition toPosition:cursorPosition];
    textField.selectedTextRange = cursorRange;
    
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
    
    return NO;
}

/**
 * Returns the index one greater than that of the n-th numerical character in
 * string. If string contains less than n numerical characters, 
 * 
 * Example: string:@"(323) 555-0123" indexAfterNthDigit:4 returns 7.
 */
- (NSUInteger)string:(NSString *)string indexAfterNthDigit:(NSUInteger)n
{
    if (n < 1) { return 0; }
    
    NSUInteger index = 0;
    NSUInteger numberCharacterCount = 0;
    
    NSUInteger length = string.length;
    unichar buffer[length + 1];
    [string getCharacters:buffer];
    
    for (int i = 0; i < length; i++) {
        if (isdigit(buffer[i])) {
            index = i + 1;
            numberCharacterCount++;
            
            if (numberCharacterCount == n) {
                break;
            }
        }
    }
    
    return index;
}

@end
