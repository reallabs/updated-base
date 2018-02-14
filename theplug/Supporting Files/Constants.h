//
//  Constants.h
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//


#define kLeftRightPadding 24
#define kHeaderFooterHeight 56

// Layout macros
#define NORMALIZED_WIDTH(XXX) (int)(XXX / 375.0 * SCREEN_WIDTH)
#define NORMALIZED_HEIGHT(XXX) (int)(XXX / 667.0 * SCREEN_HEIGHT)
#define MIDDLE_START(XXX, YYY) (int)(XXX / 2.0 - YYY / 2.0)


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)


#define TICK(XXX) NSDate *XXX = [NSDate date]
#define TOCK(XXX) NSLog(@"%s: %f", #XXX, -[XXX timeIntervalSinceNow])

#ifdef DEBUG
#define ENDPOINT_URL @"https://realtalk-dev.herokuapp.com/"
#define KEYCHAIN_STRING @"com.reallabs.base-ios-project"
#else
#define ENDPOINT_URL @"https://realtalk-prod.herokuapp.com/"
#define KEYCHAIN_STRING @"com.reallabs.base-ios-project"
#endif

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


