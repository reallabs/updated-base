//
//  PhoneAuthViewController.m
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import "PhoneAuthViewController.h"
#import "CountryNameView.h"
#import <JDStatusBarNotification/JDStatusBarNotification.h>

typedef enum {
    PhoneNumber = 1,
    AuthCode = 2,
    Verifying = 3,
} AuthState;

@interface PhoneAuthViewController ()

@property (nonatomic, strong) UIImageView *overlay;

@property CGRect screenFrame;
@property CGFloat screenHeight;
@property CGFloat screenWidth;

@property (strong, nonatomic) ESSPhoneNumberField *phoneNumberField;
@property (nonatomic) UINavigationController *modalNavigationController;
@property (nonatomic) ESSCountryChooser *countryChooser;
@property (nonatomic) UILabel *label2Text;
@property (nonatomic) UILabel *label3Text;

@property (nonatomic) CountryNameView *countryNameView;

@property (nonatomic, strong) CodeInputView *codeInput;
@property (strong, nonatomic) UIButton *resendButton;

@property (strong, nonatomic) UIButton *termsButton;
@property (strong, nonatomic) UIButton *privacyButton;
@property (strong, nonatomic) UIButton *nextButton;

@property (strong, nonatomic) HeaderView *header;

@property (strong, nonatomic) NSString *lockEmoji;

@property BOOL hasEnteredPhone;
@property BOOL hasDisappeared;
@property AuthState state;

@property NSLock *authLock;
@property BOOL hasAuthenticated;
@property BOOL isLoggedOut;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *prettyPhoneNumber;

@property CGRect firstLabelRect;
@property CGRect secondLabelRect;

@end

@implementation PhoneAuthViewController

    //Need this to not show skip on this page.
- (instancetype)initForLoggedOutUser {
    self = [super init];
    _isLoggedOut = YES;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    self.view.backgroundColor = [UIColor accentColor];

        // Login Landing Pages View
    _screenFrame = [[[self view] layer] bounds];
    _screenHeight = CGRectGetHeight(_screenFrame);
    _screenWidth = CGRectGetWidth(_screenFrame);

        // Load in generic constants
    CGFloat leftRightPadding = kLeftRightPadding;
    CGFloat footerHeight = kHeaderFooterHeight;
    CGFloat primaryFontSize = 14.0;

        // Add in the header
    CGFloat headerFooterHeight = [self prefersStatusBarHidden] ? footerHeight : footerHeight + 20;
    CGRect headerFrame = CGRectMake(0, 0, _screenWidth, headerFooterHeight);
    _header = [[HeaderView alloc] initWithFrame:headerFrame
                                      withTitle:nil
                                   withSubtitle:nil
                                 withLeftButton:nil
                                withRightButton:nil
                                  withStatusBar:[self prefersStatusBarHidden]
                                   hasSubheader:NO];
    [_header setLeftButtonImage:[UIImage imageNamed:@"🔒"]];
    _header.headerDelegate = self;
    [self.view addSubview:_header];
    _hasEnteredPhone = NO;


        //  Phone number field
    CGFloat phoneStartX = leftRightPadding;
    CGFloat phoneStartY = 159.0/667.0 * _screenHeight;
    CGFloat phoneSizeX = _screenWidth - leftRightPadding * 2.0;
    CGFloat phoneSizeY = 0.16 * _screenHeight;
    CGRect phoneRect = CGRectMake(phoneStartX, phoneStartY, phoneSizeX, phoneSizeY);
    self.phoneNumberField = [[ESSPhoneNumberField alloc] initWithFrame:phoneRect];
    self.phoneNumberField.delegate = self;
    self.phoneNumberField.backgroundColor = [UIColor whiteColor];

    self.countryChooser = [[ESSCountryChooser alloc] initWithStyle:UITableViewStylePlain];
    self.countryChooser.delegate = self.phoneNumberField;

    self.countryChooser.defaultLocale = [NSLocale currentLocale];

    self.modalNavigationController = [[UINavigationController alloc] initWithRootViewController:self.countryChooser];

    self.phoneNumberField.countryCode = self.countryChooser.selectedCountry.callingCode;
    [self.phoneNumberField.countryCodeButton addTarget:self
                                                action:@selector(showCountryCodePicker)
                                      forControlEvents:UIControlEventTouchUpInside];

    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(showCountryCodePicker)];
    [self.phoneNumberField.countryNameView addGestureRecognizer:tap];
    [self.phoneNumberField countryChooser:self.countryChooser didSelectCountry:self.countryChooser.defaultCountry];
    [self.view addSubview:self.phoneNumberField];


        // Lock
    CGFloat lockStartX = _screenWidth / 2 - 10;
    CGFloat lockStartY = phoneStartY + phoneSizeY + 10;
    CGFloat lockSizeX = 10;
    CGFloat lockSizeY = lockSizeX * 1.3;
    CGRect lockRect = CGRectMake(lockStartX, lockStartY, lockSizeX, lockSizeY);

    UIImageView *lockView = [[UIImageView alloc] initWithFrame:lockRect];
    lockView.image = [UIImage imageNamed:@"blackLock.png"];
        //[self.view addSubview:lockView];

        // Label part 2
    CGFloat label2StartX = leftRightPadding;
    CGFloat label2SizeY = 40.0;
    CGFloat label2StartY = phoneStartY - label2SizeY;
    CGFloat label2SizeX = _screenWidth - leftRightPadding * 2.0;
    _firstLabelRect = CGRectMake(label2StartX, label2StartY, label2SizeX, label2SizeY);

    _label2Text = [[UILabel alloc] initWithFrame:_firstLabelRect];
    _lockEmoji = NSLocalizedString(@"What's your phone number?\nUsed to identify you.", nil);
    _label2Text.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightBold];
    _label2Text.lineBreakMode = NSLineBreakByWordWrapping;
    _label2Text.numberOfLines = 0;
    _label2Text.text = _lockEmoji;
    _label2Text.textAlignment = NSTextAlignmentLeft;
    _label2Text.textColor = [UIColor whiteColor];
    [self.view addSubview:_label2Text];

    CGFloat codeStartX = leftRightPadding;
    CGFloat codeStartY = 159.0/667.0 * _screenHeight;
    CGFloat codeSizeX = _screenWidth - leftRightPadding * 2.0;
    CGFloat codeSizeY = 0.08 * _screenHeight;
    CGRect codeRect = CGRectMake(codeStartX, codeStartY, codeSizeX, codeSizeY);
    _codeInput = [[CodeInputView alloc] initWithFrame:codeRect];
    _codeInput.codeInputDelegate = self;
    _codeInput.tintColor = [UIColor whiteColor];
    _codeInput.alpha = 0.0;
    [self.view addSubview:_codeInput];

    _secondLabelRect = CGRectMake(label2StartX, codeStartY + codeSizeY + 20, label2SizeX, label2SizeY);

    CGFloat buttonStartX = leftRightPadding;
    CGFloat buttonStartY = CGRectGetMaxY(_secondLabelRect);
    CGFloat buttonSizeX = _screenWidth - leftRightPadding * 2.0;
    CGFloat buttonSizeY = primaryFontSize * 3.0;
    CGRect buttonRect = CGRectMake(buttonStartX, buttonStartY, buttonSizeX, buttonSizeY);

        //Adding a skip button for pesky users who don't wanna give up thier phone numbers.
    _resendButton = [[UIButton alloc] initWithFrame:buttonRect];
    _resendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _resendButton.titleLabel.numberOfLines = 1;
    _resendButton.backgroundColor = [UIColor accentColor];
    _resendButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _resendButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    UIFont *primaryFont = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    NSDictionary * backAttrs = @{ NSFontAttributeName: primaryFont,
                                  NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:1.0]  };
    NSAttributedString *nextTitle = [[NSAttributedString alloc] initWithString:@"Skip" attributes:backAttrs];
    [_resendButton setAttributedTitle:nextTitle forState:UIControlStateNormal];
        //[self.view addSubview:_skipButton];
    _resendButton.alpha = 0.0;

    _authLock = [[NSLock alloc] init];
    _hasAuthenticated = NO;

    _state = PhoneNumber;

    CGFloat termsSizeX = (_screenWidth - (2*leftRightPadding));
    CGFloat termsStartY = CGRectGetMaxY(buttonRect);
    CGFloat termsSizeY = CGRectGetHeight(buttonRect) / 2;
    CGFloat termsStartX = leftRightPadding;
    CGRect termsRect = CGRectMake(termsStartX, termsStartY, termsSizeX, termsSizeY);

    CGRect privacyRect = CGRectMake(termsStartX, CGRectGetMaxY(termsRect), termsSizeX, termsSizeY);

    _termsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _termsButton.frame = termsRect;
    _termsButton.alpha = 0;
    _termsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_termsButton setBackgroundColor:[UIColor clearColor]];
    [_termsButton setTitle:NSLocalizedString(@"Terms of Use", nil) forState:UIControlStateNormal];
    [_termsButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    [_termsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _termsButton.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [_termsButton
     addTarget:self
     action:@selector(onTermsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        //    [self.view addSubview:_termsButton];

    _privacyButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _privacyButton.frame=privacyRect;
    _privacyButton.alpha = 0;
    _privacyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_privacyButton setBackgroundColor:[UIColor clearColor]];
    [_privacyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_privacyButton setTitle:NSLocalizedString(@"Privacy Policy", nil) forState:UIControlStateNormal];
    [_privacyButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    _privacyButton.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [_privacyButton
     addTarget:self
     action:@selector(onPrivacyButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        //    [self.view addSubview:_privacyButton];

    _hasDisappeared = NO;

    CGFloat nextStartY = (319.0 / 667.0) * _screenHeight;
    CGFloat nextStartX = kLeftRightPadding;
    CGFloat nextSizeX = _screenWidth - (2*kLeftRightPadding);
    CGFloat nextSizeY = (58.0 / 667.0) * _screenHeight;
    CGRect nextRect = CGRectMake(nextStartX, nextStartY, nextSizeX, nextSizeY);
    _nextButton = [[UIButton alloc] initWithFrame:nextRect];
    _nextButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    [_nextButton addTarget:self action:@selector(onNextTapped) forControlEvents:UIControlEventTouchUpInside];
    [_nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [_nextButton setTitleColor:[UIColor accentColor] forState:UIControlStateNormal];
    _nextButton.layer.cornerRadius = nextSizeY / 2;
    [self.view addSubview:_nextButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (_state == AuthCode) {
            //Slight delay here or we never get the cursor to show up.
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.2);
        dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
            [_codeInput becomeFirstResponder];
        });
    } else {
        [self.phoneNumberField.nationalPhoneNumberField becomeFirstResponder];
    }

    [[Mixpanel sharedInstance] track:@"NuxPhoneAuthViewDidAppear"];

}

- (void)showCountryCodePicker {
    [self.navigationController presentViewController:self.modalNavigationController animated:YES completion:nil];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_hasDisappeared == NO) {
        _hasDisappeared = YES;
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.2);
        dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
            [_codeInput becomeFirstResponder];
        });
    }
}

- (void) onNumberInput {
    if([self.phoneNumberField.nationalPhoneNumber length] > 0) {
        _nextButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    }
}

#pragma mark - HeaderDelegate

- (void)onLeftButtonTapped {
    if(_state == AuthCode) {
        [self transitionToPhoneEntry];
    }
}

- (void)onNextTapped {
    if (_hasEnteredPhone || _state == AuthCode) {
        return;
    }
    _hasEnteredPhone = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_header setRightButtonSpinner];
    });

    [[Mixpanel sharedInstance] track:@"NuxPhoneAuthNextButtonTapped"];
    if(self.phoneNumberField.nationalPhoneNumber) {

        NBPhoneNumberUtil *util = [NBPhoneNumberUtil sharedInstance];

        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NBPhoneNumber *phoneNumber = [[NBPhoneNumber alloc] init];
        phoneNumber.countryCode = [formatter numberFromString:self.phoneNumberField.countryCode];
        phoneNumber.nationalNumber = [formatter numberFromString:self.phoneNumberField.nationalPhoneNumber];
        BOOL isValid = [util isValidNumber:phoneNumber];

        if(isValid) {
            [ApiFunctions uploadPhoneNumber:self.phoneNumberField.phoneNumberE164 completion:^(id responseObject, NSError *error) {
                if(error) {
                    [self phoneNumberFailWithText:NSLocalizedString(@"Something went wrong :(", nil)];
                } else {
                    _phoneNumber = self.phoneNumberField.phoneNumberE164;
                    _prettyPhoneNumber = self.phoneNumberField.nationalPhoneNumberFormatted;
                    [self transitionToAuthCode];
                }
            }];
        }
        else {
            [self phoneNumberFailWithText:NSLocalizedString(@"That doesn't seem to be a valid number", nil)];
        }
    }
    else {
        [self phoneNumberFailWithText:NSLocalizedString(@"That doesn't seem to be a valid number", nil)];
    }
}

- (void)phoneNumberFailWithText:(NSString*)text {
    _hasEnteredPhone = NO;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:text
                                                        message:NSLocalizedString(@"Please try again.", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                              otherButtonTitles:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alertView show];
    });
}

- (void)transitionToAuthCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_header setRightButtonString:@""];
        _state = AuthCode;
        _hasEnteredPhone = NO;

        [_header setLeftButtonImage:[UIImage imageNamed:@"back.png"]];
        UIFont *primaryFont = [UIFont systemFontOfSize:18.0 weight:UIFontWeightMedium];
        NSDictionary * backAttrs = @{ NSFontAttributeName: primaryFont,
                                      NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:1.0]  };
        NSAttributedString *nextTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Resend", nil) attributes:backAttrs];
        [_resendButton addTarget:self action:@selector(onResendTapped) forControlEvents:UIControlEventTouchUpInside];
        [_resendButton setAttributedTitle:nextTitle forState:UIControlStateNormal];
        [self.view addSubview:_resendButton];
        _label2Text.frame = _firstLabelRect;
        _codeInput.alpha = 1.0;
        _nextButton.alpha = 0.0;
        _resendButton.alpha = 1.0;
        _termsButton.alpha = 1.0;
        _privacyButton.alpha = 1.0;
        [_label2Text setText:[NSString stringWithFormat:NSLocalizedString(@"Enter the 4 digit code sent to your phone %@", nil), _prettyPhoneNumber]];
            //        [_header setTitleString:NSLocalizedString(@"Enter Code", nil)];
        [_codeInput becomeFirstResponder];
        self.phoneNumberField.alpha = 0.0;
        _label2Text.alpha = 1.0;
        [_label3Text removeFromSuperview];
    });
}


-(void) transitionToPhoneEntry {
    dispatch_async(dispatch_get_main_queue(), ^{
        _state = PhoneNumber;
        [_header setLeftButtonString:@""];
        UIFont *primaryFont = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
        NSDictionary * backAttrs = @{ NSFontAttributeName: primaryFont,
                                      NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.4]  };
        NSAttributedString *nextTitle = [[NSAttributedString alloc] initWithString:@"Skip" attributes:backAttrs];
        [_resendButton removeTarget:self action:@selector(onResendTapped) forControlEvents:UIControlEventTouchUpInside];
        [_resendButton setAttributedTitle:nextTitle forState:UIControlStateNormal];
        [_resendButton removeFromSuperview];
        if(_isLoggedOut) {
            _resendButton.alpha = 0.0;
        }
        _nextButton.alpha = 1.0;
        _label2Text.frame = _firstLabelRect;
        _codeInput.alpha = 0.0;
        _termsButton.alpha = 0.0;
        _privacyButton.alpha = 0.0;
        [_label2Text setText:_lockEmoji];
            //        [_header setTitleString:@"Sign Up"];

        self.phoneNumberField.alpha = 1.0;
        [self.phoneNumberField becomeFirstResponder];
        _label2Text.alpha = 1.0;
        [self.view addSubview:_label3Text];
    });
}

- (void)onCodeEntered:(NSMutableString*)code {
    [_header setRightButtonSpinner];
    [ApiFunctions  uploadPhoneAuthCode:code phoneNumber:_phoneNumber completion:^(id responseObject, NSError *error) {
        [_authLock lock];
        if (_hasAuthenticated) {
            return;
        }
        if (!error && [responseObject[@"authStatus"]  isEqual:@"authSucceeded"]) {

            [[Mixpanel sharedInstance] track:@"NuxPhoneAuthConfirmationAuthSucceeded"];

            if([responseObject[@"userType"] isEqualToString:@"newUser"]) {
                _hasAuthenticated = YES;
                [_phoneAuthDelegate onNewUserCreatedWithToken:responseObject[@"token"] withPhoneNumber:_phoneNumber withUserId:[NSString stringWithFormat:@"%@", responseObject[@"userid"][@"id"]]];
                [[Mixpanel sharedInstance] createAlias:[NSString stringWithFormat:@"%@", responseObject[@"userid"][@"id"]] forDistinctID:[Mixpanel sharedInstance].distinctId];
            }
            else {
                if(responseObject[@"userid"][@"username"] != [NSNull null]) {
                    _hasAuthenticated = YES;
                    [_phoneAuthDelegate onReturningUserValidatedWithToken:responseObject[@"token"] withPhoneNumber:_phoneNumber withUserId:[NSString stringWithFormat:@"%@", responseObject[@"userid"][@"id"]]];
                }
                    //TODO: We need to build another "Only set profile photo on login" thing.
                    //                else if( responseObject[@"userid"][@"profilePhotoKey"]  == [NSNull null]) {
                    //                    [_phoneAuthConfirmationDelegate onNewUserCreatedWithToken:responseObject[@"token"] withPhoneNumber:_phoneNumber withUserId:[NSString stringWithFormat:@"%@", responseObject[@"userid"][@"id"]] withUsername:responseObject[@"username"]];
                    //                }
                else {
                    _hasAuthenticated = YES;
                    [_phoneAuthDelegate onNewUserCreatedWithToken:responseObject[@"token"] withPhoneNumber:_phoneNumber withUserId:[NSString stringWithFormat:@"%@", responseObject[@"userid"][@"id"]]];

                }
            }
        } else {
            NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"That doesn't seem to be a valid code"
                                                                message:@"Please try again."
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alertView show];
                _codeInput.text = @"";
                [[Mixpanel sharedInstance] track:@"NuxPhoneAuthConfirmationIncorrectCode"];
            });
        }
        [_authLock unlock];
    }];
}

- (void)reset {
    _hasEnteredPhone = NO;
}

- (void)onResendTapped {

    UIActivityIndicatorView *myIndicator = [[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [myIndicator setCenter:CGPointMake(_resendButton.frame.size.width / 2, _resendButton.frame.size.height / 2)];
    [_resendButton addSubview:myIndicator];
    [_resendButton setAttributedTitle:nil forState:UIControlStateNormal];
    [myIndicator startAnimating];
    [[Mixpanel sharedInstance] track:@"NuxPhoneAuthConfirmationResendButtonTapped"];
    [ApiFunctions resendPhoneAuthCode:_phoneNumber completion:^(id responseObject, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (responseObject && !error) {
                [JDStatusBarNotification showWithStatus:@"Resent Phone Auth code" dismissAfter:3.0 styleName:JDStatusBarStyleSuccess];
                [UIView animateWithDuration:0.3
                                      delay:0.3
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     UIFont *primaryFont = [UIFont systemFontOfSize:18.0 weight:UIFontWeightMedium];
                                     NSDictionary * backAttrs = @{ NSFontAttributeName: primaryFont,
                                                                   NSForegroundColorAttributeName: [UIColor colorWithRed:0.0/255.0 green:156.0/255.0 blue:230.0/255.0 alpha:1.0]  };
                                     NSAttributedString *nextTitle = [[NSAttributedString alloc] initWithString:@"Resend" attributes:backAttrs];
                                     [_resendButton setAttributedTitle:nextTitle forState:UIControlStateNormal];
                                 }
                                 completion:^(BOOL finished){
                                     [myIndicator removeFromSuperview];
                                 }];


            } else {
                NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
                [JDStatusBarNotification showWithStatus:@"Cannot Send Phone Auth Code" dismissAfter:3.0 styleName:JDStatusBarStyleError];
            }
        });
    }];
}

-(void) doneButtonTapped {
    [self onRightButtonTapped];
}

- (void)onTermsButtonTapped {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://vivify.me/terms"]];
}


- (void)onPrivacyButtonTapped {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://vivify.me/privacy"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}


- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}


#pragma mark - UIViewController overrides

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return (UIStatusBarStyle)UIBarStyleBlack;
}

@end

