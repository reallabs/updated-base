//
//  AppDelegate.m
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import "AppDelegate.h"

#import <Appirater/Appirater.h>
#import "ApiFunctions.h"
#import "MasterLoginViewController.h"
#import "ViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) MasterLoginViewController *loginViewController;

@property (nonatomic, strong) ViewController *rootViewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

// Override point for customization after application launch.
#ifdef DEBUG
        //         [self logOut];
#endif

        // Override point for customization after application launch.
//    [Fabric with:@[[AWSCognito class], [Crashlytics class]]];

    [self maybeLogin];

    // [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
//    [Mixpanel sharedInstance].flushInterval = 60.0;
//    [Mixpanel sharedInstance].flushOnBackground = YES;
//    [[Mixpanel sharedInstance] track:@"didFinishLaunching"];
//    [[Mixpanel sharedInstance] flush];

    [Appirater setAppId:@"1143879020"];
    [Appirater setDaysUntilPrompt:1];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:20];
    [Appirater setTimeBeforeReminding:20];
#ifdef DEBUG
        //        [Appirater setDebug:YES];
#endif
    [Appirater appLaunched:YES];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)maybeLogin {
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KEYCHAIN_STRING];
    BOOL loggedIn = NO;
    if (![keychain stringForKey:@"hasLoggedIn"]) {
        [self logOut];
        _navigationController.navigationBar.hidden = YES;
        _loginViewController = [[MasterLoginViewController alloc] init];
        _loginViewController.masterLoginViewDelegate = self;

        _navigationController.navigationBarHidden = YES;
        _navigationController = [[UINavigationController alloc]
                                 initWithRootViewController:_loginViewController];
    } else {
        [self updateAccessToken];
        [self createAndAddMainViewControllers];
        loggedIn = YES;
    }

    _navigationController.navigationBar.hidden = YES;

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = _navigationController;
    [self.window makeKeyAndVisible];

}

- (void)createAndAddMainViewControllers {

    _firstViewController = [[UIViewController alloc] init];
    _firstViewController.view.backgroundColor = [UIColor redColor];

    _navigationController = [[UINavigationController alloc]
                             initWithRootViewController:_firstViewController];
}

- (void)updateAccessToken {
    [ApiFunctions updateAccessTokenWithCompletion:^(id responseObject, NSError *error) {
        if (!error && responseObject) {
            UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KEYCHAIN_STRING];
            NSString *userid = [NSString stringWithFormat:@"%@", responseObject[@"userid"]];
            NSString *token = [NSString stringWithFormat:@"%@", responseObject[@"token"]];
            [keychain setString:token  forKey:@"access_token"];
            [keychain setString:userid forKey:@"userid"];

        } else {
            NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
        }
    }];
}

- (void)logOut {
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KEYCHAIN_STRING];
    [keychain removeItemForKey:@"hasLoggedIn"];
    [keychain removeItemForKey:@"phone_number"];
    [keychain removeItemForKey:@"userid"];
    [keychain removeItemForKey:@"access_token"];

        // This is a bug
        // WE can use this, but only if we setup a plist file with the 'standard' defaults
        // Which seems error prone, as we will inevitable forget to add defaults
        // [NSUserDefaults resetStandardUserDefaults];

        // This is safer
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];

    [self resetKeychain];
    // TODO [UserProfileObject purgeCache];

    [[Mixpanel sharedInstance] track:@"UserWasLoggedOut"];
}

#pragma mark - Keychain helpers

- (void)resetKeychain {
    [self deleteAllKeysForSecClass:kSecClassGenericPassword];
    [self deleteAllKeysForSecClass:kSecClassInternetPassword];
    [self deleteAllKeysForSecClass:kSecClassCertificate];
    [self deleteAllKeysForSecClass:kSecClassKey];
    [self deleteAllKeysForSecClass:kSecClassIdentity];
}

- (void)deleteAllKeysForSecClass:(CFTypeRef)secClass {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:(__bridge id)secClass forKey:(__bridge id)kSecClass];
    OSStatus result = SecItemDelete((__bridge CFDictionaryRef) dict);
    NSAssert(result == noErr || result == errSecItemNotFound, @"Error deleting keychain data (%d)", (int)result);
}

@end
