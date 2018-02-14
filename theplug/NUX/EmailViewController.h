//
//  EmailViewController.h
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import "HeaderView.h"
#import "UITextField+Shake.h"

@protocol EmailControllerDelegate <NSObject>

- (void) onEmailCompletedWithEmail:(NSString*)email;
- (void) onBackPressed;

@end

@interface EmailViewController : UIViewController <HeaderDelegate, UITextFieldDelegate>

@property (nonatomic, readwrite, weak) id<EmailControllerDelegate> delegate;

@end

