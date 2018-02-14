//
//  LastNameViewController.h
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"
#import "UITextField+Shake.h"

@protocol LastnameViewControllerDelegate <NSObject>

- (void)onSignUpCompletedWithLastname:(NSString*)lastname;
- (void)onBackPressed;

@end

@interface LastnameViewController : UIViewController <HeaderDelegate, UITextFieldDelegate>

@property (nonatomic, readwrite, weak) id<LastnameViewControllerDelegate> delegate;

@end

