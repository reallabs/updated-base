//
//  PhoneauthViewController.h
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApiFunctions.h"
#import "ESSPhoneNumberField.h"
#import "ESSCountryChooser.h"
#import "HeaderView.h"
#import "Mixpanel.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"
#import "CodeInputView.h"

@import AVFoundation;

@protocol PhoneAuthDelegate <NSObject>
- (void)onNewUserCreatedWithToken:(NSString*)token withPhoneNumber:(NSString*)phoneNumber withUserId:(NSString*)userid;
- (void)onReturningUserValidatedWithToken:(NSString*)token withPhoneNumber:(NSString*)phoneNumber withUserId:(NSString*)userid;
@end


@interface PhoneAuthViewController : UIViewController <HeaderDelegate, CodeInputDelegate, ESSPhoneNumberFieldDelegate>

- (instancetype)initForLoggedOutUser;
    //making public so we can handle all backgrounding states
- (void)viewDidAppear:(BOOL)animated;

@property (nonatomic, readwrite, weak) id<PhoneAuthDelegate> phoneAuthDelegate;

- (void)reset;

@end

