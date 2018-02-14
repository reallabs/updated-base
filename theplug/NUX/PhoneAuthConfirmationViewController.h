//
//  PhoneAuthConfirmationViewController.h
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ApiFunctions.h"
#import "HeaderView.h"
#import "Mixpanel.h"

@protocol PhoneAuthConfirmationDelegate <NSObject>

- (void)onBackPressed;
- (void)onNewUserCreatedWithToken:(NSString*)token withPhoneNumber:(NSString*)phoneNumber withUserId:(NSString*)userid withUsername:(NSString*)username;
- (void)onReturningUserValidatedWithToken:(NSString*)token withPhoneNumber:(NSString*)phoneNumber withUserId:(NSString*)userid withUsername:(NSString*)username withProfilePhotoKey:(NSString*)profilePhotoKey;

@end


@interface PhoneAuthConfirmationViewController : UIViewController <HeaderDelegate, UITextFieldDelegate>

- (instancetype) initWithPhoneNumber:(NSString*)phoneNumber;

@property (nonatomic, readwrite, weak) id<PhoneAuthConfirmationDelegate> phoneAuthConfirmationDelegate;

@end

