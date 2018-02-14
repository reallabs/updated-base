//
//  FirstNameViewController.h
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextField+Shake.h"


@protocol FirstnameViewControllerDelegate <NSObject>

- (void)onSignUpCompletedWithFirstname:(NSString*)firstname;
- (void)onBackPressed;

@end

@interface FirstnameViewController : UIViewController <HeaderDelegate, UITextFieldDelegate>

- (instancetype)init;

@property (nonatomic, readwrite, weak) id<FirstnameViewControllerDelegate> delegate;

@end

