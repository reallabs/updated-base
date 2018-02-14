//
//  PhoneAuthConfirmationViewController.m
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import "PhoneAuthConfirmationViewController.h"
#import <Crashlytics/Crashlytics.h>

@interface PhoneAuthConfirmationViewController ()

@property (nonatomic, strong) UIView *playerContainer;
@property (nonatomic, strong) UITextField *codeInput;
@property (strong, nonatomic) UIButton *resendButton;

@property (strong, nonatomic) NSString *phoneNumber;
@property CGRect screenFrame;
@property CGFloat screenHeight;
@property CGFloat screenWidth;

@property (strong, nonatomic) Mixpanel *mixpanel;

@property NSLock *authLock;
@property BOOL hasAuthenticated;

@end

@implementation PhoneAuthConfirmationViewController

- (instancetype) initWithPhoneNumber:(NSString*)phoneNumber {
    _phoneNumber = phoneNumber;
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
    CGFloat headerFooterHeight = [self prefersStatusBarHidden] ? footerHeight : footerHeight + 20;
    CGFloat primaryFontSize = 16.0;

        // Add in the header
    CGRect headerFrame = CGRectMake(0, 0, _screenWidth, headerFooterHeight);
    HeaderView *header = [[HeaderView alloc] initWithFrame:headerFrame
                                                 withTitle:_phoneNumber
                                              withSubtitle:nil
                                            withLeftButton:@"Back"
                                           withRightButton:@"Next"
                                             withStatusBar:[self prefersStatusBarHidden]
                                              hasSubheader:NO];
    header.headerDelegate = self;
    [self.view addSubview:header];

    // Label part 2
    CGFloat label2StartX = leftRightPadding;
    CGFloat label2StartY = headerFooterHeight + 30;
    CGFloat label2SizeX = _screenWidth - leftRightPadding * 2.0;
    CGFloat label2SizeY = primaryFontSize * 3.0;
    CGRect label2TextRect = CGRectMake(label2StartX, label2StartY, label2SizeX, label2SizeY);

    UILabel *label2Text = [[UILabel alloc] initWithFrame:label2TextRect];
    [label2Text setText:@"A 4 digit confirmation code was sent to your phone. Please enter it below"];
    label2Text.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightRegular];
    [label2Text setTextColor:[UIColor blackColor]];
    [label2Text setTextAlignment:NSTextAlignmentCenter];
    label2Text.numberOfLines = 0;
    label2Text.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:label2Text];

        // Phone number entry text field
    CGFloat phoneStartX = leftRightPadding;
    CGFloat phoneStartY = label2StartY + label2SizeY + 20;
    CGFloat phoneSizeX = _screenWidth - leftRightPadding * 2.0;
    CGFloat phoneSizeY = 0.08 * _screenHeight;
    CGRect phoneRect = CGRectMake(phoneStartX, phoneStartY, phoneSizeX, phoneSizeY);

    _codeInput = [[UITextField alloc] initWithFrame:phoneRect];
    _codeInput.delegate = self;
    _codeInput.keyboardType = UIKeyboardTypeNumberPad;
    _codeInput.backgroundColor = [UIColor whiteColor];
    _codeInput.placeholder = @"- - - -";
    _codeInput.textColor = [UIColor blackColor];
    _codeInput.layer.cornerRadius = phoneSizeY /2;
    _codeInput.layer.borderColor = [[UIColor colorWithWhite:0.0 alpha:0.2] CGColor];
    _codeInput.layer.borderWidth = 0.5f;
    _codeInput.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_codeInput];


    UIView *keyboardButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, phoneSizeY)];
    keyboardButtonView.backgroundColor = [UIColor greenColor];

    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, phoneSizeY)];
    [doneButton setTitle:@"DONE" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [keyboardButtonView addSubview:doneButton];

    _codeInput.inputAccessoryView = keyboardButtonView;

    CGFloat resendStartX = leftRightPadding;
    CGFloat resendStartY = phoneStartY + phoneSizeY + 20;
    CGFloat resendSizeX = _screenWidth - leftRightPadding * 2.0;
    CGFloat resendSizeY = 0.08 * _screenHeight;
    CGRect resendRect = CGRectMake(resendStartX, resendStartY, resendSizeX, resendSizeY);

    _resendButton = [[UIButton alloc] initWithFrame:resendRect];
    [_resendButton setTitle:@"Resend Code" forState:UIControlStateNormal];
    [_resendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _resendButton.layer.cornerRadius = resendSizeY /2;
    _resendButton.layer.borderColor = [[UIColor colorWithWhite:0.0 alpha:0.2] CGColor];
    _resendButton.layer.borderWidth = 0.5f;
    _resendButton.titleLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightRegular];
    [_resendButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_resendButton addTarget:self action:@selector(onResendTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_resendButton];

        // Need to make this this get setup correctly visually
    CGFloat frameStartX = leftRightPadding;
    CGFloat frameSizeX = _screenWidth - (leftRightPadding * 2.0);
    CGFloat frameSizeY = frameSizeX / 1.25;
    CGFloat screenRemaining = _screenHeight - phoneStartY - phoneSizeY;
    CGFloat frameStartY = phoneStartY + phoneSizeY + screenRemaining / 2 - frameSizeY / 2;
    CGRect retakeRect = CGRectMake(frameStartX, frameStartY, frameSizeX, frameSizeY);

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"nux3" ofType:@"mp4"];
    NSURL *assetURL = [NSURL fileURLWithPath:filePath];

        // Progress dots, the third should be highlighted.
    int cornerRadius = 3;
    float alpha = 0.5f;
    int diameter = 2 * cornerRadius;

    CGFloat startX =_screenWidth / 2 - (4.5 * diameter);
    CGFloat startY =_screenHeight - (4 * diameter);
    UIView *circle1 = [[UIView alloc] initWithFrame:CGRectMake(startX,startY,diameter,diameter)];
    circle1.alpha = alpha;
    circle1.layer.cornerRadius = cornerRadius;
    circle1.backgroundColor = [UIColor grayColor];

    UIView *circle2 = [[UIView alloc] initWithFrame:CGRectMake(startX + (2*diameter),startY,diameter,diameter)];
    circle2.alpha = alpha;
    circle2.layer.cornerRadius = cornerRadius;
    circle2.backgroundColor = [UIColor grayColor];

    UIView *circle3 = [[UIView alloc] initWithFrame:CGRectMake(startX + (4*diameter),startY,diameter,diameter)];
    circle3.alpha = alpha;
    circle3.layer.cornerRadius = cornerRadius;
    circle3.backgroundColor = [UIColor blackColor];

    UIView *circle4 = [[UIView alloc] initWithFrame:CGRectMake(startX + (6*diameter),startY,diameter,diameter)];
    circle4.alpha = alpha;
    circle4.layer.cornerRadius = cornerRadius;
    circle4.backgroundColor = [UIColor grayColor];

    UIView *circle5 = [[UIView alloc] initWithFrame:CGRectMake(startX + (8*diameter),startY,diameter,diameter)];
    circle5.alpha = alpha;
    circle5.layer.cornerRadius = cornerRadius;
    circle5.backgroundColor = [UIColor grayColor];

    _authLock = [[NSLock alloc] init];
    _hasAuthenticated = NO;

        //    [self.view addSubview:circle1];
        //    [self.view addSubview:circle2];
        //    [self.view addSubview:circle3];
        //    [self.view addSubview:circle4];
        //    [self.view addSubview:circle5];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[Mixpanel sharedInstance] track:@"NuxPhoneAuthConfirmationViewDidAppear"];

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    NSString *searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if([searchStr length] == 4) {
        _codeInput.text = searchStr;
        [self onRightButtonTapped];
        return NO;
    }
    return YES;
}

#pragma mark - HeaderDelegate

- (void)onLeftButtonTapped {
    [[Mixpanel sharedInstance] track:@"NuxPhoneAuthConfirmationBackButtonTapped"];
    [_phoneAuthConfirmationDelegate onBackPressed];
}

- (void)onRightButtonTapped {
    [[Mixpanel sharedInstance] track:@"NuxPhoneAuthConfirmationNextButtonTapped"];

    [ApiFunctions uploadPhoneAuthCode:_codeInput.text phoneNumber:_phoneNumber completion:^(id responseObject, NSError *error) {
        [_authLock lock];
        if (_hasAuthenticated) {
            return;
        }
        if (!error && [responseObject[@"authStatus"]  isEqual:@"authSucceeded"]) {

            [[Mixpanel sharedInstance] track:@"NUX PhoneConfirmation Session Length"];
            [[Mixpanel sharedInstance] track:@"NuxPhoneAuthConfirmationAuthSucceeded"];

            if([responseObject[@"userType"] isEqualToString:@"newUser"]) {
                _hasAuthenticated = YES;
                [_phoneAuthConfirmationDelegate onNewUserCreatedWithToken:responseObject[@"token"] withPhoneNumber:_phoneNumber withUserId:[NSString stringWithFormat:@"%@", responseObject[@"userid"][@"id"]] withUsername:nil];
                [[Mixpanel sharedInstance] createAlias:[NSString stringWithFormat:@"%@", responseObject[@"userid"][@"id"]] forDistinctID:[Mixpanel sharedInstance].distinctId];
            }
            else {
                if (responseObject[@"userid"][@"username"] != [NSNull null]) {
                    _hasAuthenticated = YES;
                    [_phoneAuthConfirmationDelegate onReturningUserValidatedWithToken:responseObject[@"token"] withPhoneNumber:_phoneNumber withUserId:[NSString stringWithFormat:@"%@", responseObject[@"userid"][@"id"]] withUsername:responseObject[@"userid"][@"username"]withProfilePhotoKey:responseObject[@"userid"][@"profile_photo_key"]];
                }
                    //TODO: We need to build another "Only set profile photo on login" thing.
                    //                else if( responseObject[@"userid"][@"profilePhotoKey"]  == [NSNull null]) {
                    //                    [_phoneAuthConfirmationDelegate onNewUserCreatedWithToken:responseObject[@"token"] withPhoneNumber:_phoneNumber withUserId:[NSString stringWithFormat:@"%@", responseObject[@"userid"][@"id"]] withUsername:responseObject[@"username"]];
                    //                }
                else {
                    _hasAuthenticated = YES;
                    [_phoneAuthConfirmationDelegate onNewUserCreatedWithToken:responseObject[@"token"] withPhoneNumber:_phoneNumber withUserId:[NSString stringWithFormat:@"%@", responseObject[@"userid"][@"id"]] withUsername:nil];

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
                [[Mixpanel sharedInstance] track:@"NuxPhoneAuthConfirmationIncorrectCode"];
            });
        }
        [_authLock unlock];
    }];
}

- (void)doneButtonTapped {
    [self onRightButtonTapped];
}

- (void)onResendTapped {
    [[Mixpanel sharedInstance] track:@"NuxPhoneAuthConfirmationResendButtonTapped"];
    [ApiFunctions resendPhoneAuthCode:_phoneNumber completion:^(id responseObject, NSError *error) {
        if (responseObject && !error) {
                //TODO - handle the success case?
        } else {
            NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
                //TODO - handle the error case?
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

