//
//  ApiFunctions.h
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UICKeyChainStore.h"
#import "Mixpanel.h"
#import <Photos/Photos.h>
#import <Contacts/Contacts.h>

@protocol ApiFunctionsDelegate <NSObject>


@end

@interface ApiFunctions : NSObject

    // NUX

+ (void)uploadUserData:(NSDictionary*)data
            completion:(void (^)(id responseObject, NSError *error))completion;


+ (void)updateAccessTokenWithCompletion:(void (^)(id responseObject, NSError *error))completion;

+ (void)uploadPhoneNumber:(NSString *)phone_number
               completion:(void (^)(id responseObject, NSError *error))completion;

+ (void)resendPhoneAuthCode:(NSString *)phone_number
                 completion:(void (^)(id responseObject, NSError *error))completion;

+ (void)uploadPhoneAuthCode:(NSString *)auth_code
                phoneNumber:(NSString*)phone_number
                 completion:(void (^)(id responseObject, NSError *error))completion;

    // User

+ (void)downloadUserProfile:(NSString *)userid completion:(void (^)(id responseObject, NSError *error))completion;



    // Common

+ (void)submitEvent:(NSString *)eventType wasUserAction:(BOOL)wasUserAction withjsonExtra:(NSDictionary*)extra completion:(void (^)(id responseObject, NSError *error))completion;

+ (void)uploadPushToken:(NSString *)token completion:(void (^)(id responseObject, NSError *error))completion;


@property (nonatomic, readwrite, weak) id<ApiFunctionsDelegate> apiFunctionsDelegate;

@end

