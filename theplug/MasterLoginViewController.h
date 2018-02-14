//
//  MasterLoginViewController.m
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Crashlytics/Crashlytics.h>

#import "ApiFunctions.h"
#import "EmailViewController.h"
#import "FirstnameViewController.h"
#import "LastnameViewController.h"
#import "NuxLandingViewController.h"
#import "PhoneAuthViewController.h"
#import "UICKeyChainStore.h"

@protocol MasterLoginViewDelegate <NSObject>

- (void) onLoginCompleted;

@end

@interface MasterLoginViewController : UIViewController <EmailControllerDelegate, FirstnameViewControllerDelegate, LastnameViewControllerDelegate, NuxLandingDelegate, PhoneAuthDelegate>

- (void) setPhoneAuthFirstResponder;

@property (nonatomic, readwrite, weak) id<MasterLoginViewDelegate> masterLoginViewDelegate;

@property (strong, nonatomic) UIButton *nextButton;
@property (strong, nonatomic) NuxLandingViewController *landingViewController;
@property (strong, nonatomic) PhoneAuthViewController *phoneAuthViewController;
@property (strong, nonatomic) FirstnameViewController *firstnameController;
@property (strong, nonatomic) LastnameViewController *lasttnameController;
@property (strong, nonatomic) EmailViewController *emailController;
@property (strong, nonatomic) NSUserDefaults *defaults;
@end

