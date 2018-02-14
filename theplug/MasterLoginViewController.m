//
//  MasterLoginViewController.h
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import "MasterLoginViewController.h"

#import "AppDelegate.h"
#import "UserProfile.h"

typedef enum {
    Landing = 0,
    Firstname,
    Lastname,
    PhoneAuth,
    Email,
    Completed,
} LoginState;


@interface MasterLoginViewController ()

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;

@property LoginState state;

@end


@implementation MasterLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KEYCHAIN_STRING];
    if ([keychain stringForKey:@"username"] && [keychain stringForKey:@"userid"]) {

    } else {
        _state = Landing;
        dispatch_async(dispatch_get_main_queue(), ^{
            _landingViewController = [[NuxLandingViewController alloc] init];
            _landingViewController.delegate = self;
            [self.navigationController pushViewController:_landingViewController animated:NO];

//            [ApiFunctions submitEvent:@"nux_landing_shown" wasUserAction:YES withRecipient:nil withRecipientType:nil withjsonExtra:nil completion:^(id responseObject, NSError *error) {
//                if(error) {
//                    NSLog(@"Got and error submitting a event to our API: %@", error.description);
//                }
//            }];
        });

    }
    self.defaults = [NSUserDefaults standardUserDefaults];

}

- (void)viewWillDisappear:(BOOL)animated {
    [_phoneAuthViewController viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [_phoneAuthViewController viewDidAppear:animated];
}

-(void)onLandingNextButtonPressed {
    if (_state == Landing) {
        _state = Firstname;
        dispatch_async(dispatch_get_main_queue(), ^{

            if(!_firstnameController) {
                _firstnameController = [[FirstnameViewController alloc] init];
                _firstnameController.delegate = self;
            }

            [self.navigationController pushViewController:_firstnameController animated:YES];
        });
//        [ApiFunctions submitEvent:@"nux_landing_completed" wasUserAction:YES withRecipient:nil withRecipientType:nil withjsonExtra:nil completion:^(id responseObject, NSError *error) {
//            if(error) {
//                NSLog(@"Got and error submitting a event to our API: %@", error.description);
//            }
//        }];
    }
}

- (void)onSignUpCompletedWithFirstname:(NSString*)firstname {
    if (_state == Firstname) {
        _firstName = firstname;
        _state = Lastname;
        dispatch_async(dispatch_get_main_queue(), ^{

            if (!_lasttnameController) {
                _lasttnameController = [[LastnameViewController alloc] init];
                _lasttnameController.delegate = self;
            }
            [self.navigationController pushViewController:_lasttnameController animated:YES];


        });
//        [ApiFunctions submitEvent:@"nux_firstname_completed" wasUserAction:YES withRecipient:nil withRecipientType:nil withjsonExtra:nil completion:^(id responseObject, NSError *error) {
//            if(error) {
//                NSLog(@"Got and error submitting a event to our API: %@", error.description);
//            }
//        }];
    }
}

- (void)onSignUpCompletedWithLastname:(NSString*)lastname {
    if (_state == Lastname) {
        _lastName = lastname;
        _state = PhoneAuth;
        dispatch_async(dispatch_get_main_queue(), ^{
            _phoneAuthViewController = [[PhoneAuthViewController alloc] init];
            _phoneAuthViewController.phoneAuthDelegate = self;

            [self.navigationController pushViewController:_phoneAuthViewController animated:YES];
        });

//        [ApiFunctions submitEvent:@"nux_permissions_completed" wasUserAction:YES withRecipient:nil withRecipientType:nil withjsonExtra:nil completion:^(id responseObject, NSError *error) {
//            if(error) {
//                NSLog(@"Got and error submitting a event to our API: %@", error.description);
//            }
//        }];
    }
}

- (void)onNewUserCreatedWithToken:(NSString*)token withPhoneNumber:(NSString*)phoneNumber withUserId:(NSString*)userid  {
    if (_state == PhoneAuth) {
        _token = token;
        _phoneNumber = phoneNumber;
        _userId = userid;
        [self setKeychain];
        [UserProfile selfObject];

//        [ApiFunctions submitEvent:@"nux_phone_auth_completed" wasUserAction:YES withRecipient:nil withRecipientType:nil withjsonExtra:@{@"isNewUser": [NSNumber numberWithBool:YES]} completion:^(id responseObject, NSError *error) {
//            if(error) {
//                NSLog(@"Got and error submitting a event to our API: %@", error.description);
//            }
//        }];
    }
}

- (void)onReturningUserValidatedWithToken:(NSString*)token withPhoneNumber:(NSString*)phoneNumber withUserId:(NSString*)userid {
    if (_state == PhoneAuth) {
        _state = Completed;
        _token = token;
        _phoneNumber = phoneNumber;
        _userId = userid;

        [self setKeychain];
        [UserProfile selfObject];
        [self pushEmailController];

//        [ApiFunctions submitEvent:@"nux_phone_auth_completed" wasUserAction:YES withRecipient:nil withRecipientType:nil withjsonExtra:@{@"isNewUser": [NSNumber numberWithBool:NO]} completion:^(id responseObject, NSError *error) {
//            if(error) {
//                NSLog(@"Got and error submitting a event to our API: %@", error.description);
//            }
//        }];
    }
}

- (void)pushEmailController {
    _state = Email;
    if([_email length] > 0) {
            //We probably got this from FB
        [self onEmailCompletedWithEmail:_email];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        _emailController = [[EmailViewController alloc] init];
        _emailController.delegate = self;

        [self.navigationController pushViewController:_emailController animated:YES];

    });
}

- (void)onBackPressed {
    switch(_state) {
        case Landing: {
                //Nothing to do here
            break;
        }
        case Firstname: {
            _state = Landing;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            break;
        }
        case Lastname: {
            _state = Firstname;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            break;
        }
        case PhoneAuth: {
            _state = Firstname;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            break;
        }
        case Email: {
            break;
        }
        default: {
            break;
        }

    }
}

- (void)onEmailCompletedWithEmail:(NSString*)email {
    if (_state == Email) {
        _email = email;
        _state = Completed;
        [_masterLoginViewDelegate onLoginCompleted];


//        [ApiFunctions submitEvent:@"nux_added_email" wasUserAction:YES withRecipient:nil withRecipientType:nil withjsonExtra:nil completion:^(id responseObject, NSError *error) {
//            if(error) {
//                NSLog(@"Got and error submitting a event to our API: %@", error.description);
//            }
//        }];
    }
}


- (void)updateUserInfo {
    NSMutableDictionary *currentState = [[NSMutableDictionary alloc] init];
    [currentState setObject:_firstName forKey:@"firstname"];
    [currentState setObject:_lastName forKey:@"lastname"];
    [currentState setObject:_email forKey:@"email"];

    [ApiFunctions uploadUserData:currentState completion:^(id responseObject, NSError *error) {
    }];
}


- (void)setKeychain {
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KEYCHAIN_STRING];
    [keychain setString:_token forKey:@"access_token"];
    [keychain setString:_phoneNumber forKey:@"phone_number"];
    [keychain setString:_userId forKey:@"userid"];
    [CrashlyticsKit setUserIdentifier:_userId];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end

