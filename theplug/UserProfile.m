//
//  UserProfile.m
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import "UserProfile.h"

#import "ApiFunctions.h"

@interface UserProfile ()

@end


@implementation UserProfile

static UserProfile *selfObject = nil;
static dispatch_once_t onceToken;

+ (id)selfObject {
    dispatch_once(&onceToken, ^{
        selfObject = [UserProfile readFromCache];
        UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KEYCHAIN_STRING];
        NSString *userId = [keychain stringForKey:@"userid"];
        if (selfObject == nil) {
            selfObject = [[self alloc] initWithUserId:userId];
        } else {
            [[self alloc] getUserProfile:userId];
        }
    });
    return selfObject;
}

- (id)initWithUserId:(NSString*)userid {

    id toRet = [super init];

    self.userid = userid;

    [self getUserProfile:userid];
    return toRet;

}

- (void)getUserProfile:(NSString*)userid {
    self.userid = userid;
    [ApiFunctions downloadUserProfile:userid completion:^(id responseObject, NSError *error) {
        if (responseObject && !error) {
            // TODO parse profile response!
        } else {
            NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
        }
    }];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.userid forKey:@"userid"];
    [encoder encodeObject:self.userProfileDictionary forKey:@"userProfileDictionary"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.userProfileDictionary = [decoder decodeObjectForKey:@"userProfileDictionary"];
        self.userid = [decoder decodeObjectForKey:@"userid"];
    }
    return self;
}


+ (void)cache {
    NSString *path = [UserProfile pathWithIdentifier:@"userProfileObject"];
    [NSKeyedArchiver archiveRootObject:[UserProfile selfObject] toFile:path];
}

+ (instancetype)readFromCache {
    NSString *path = [UserProfile pathWithIdentifier:@"userProfileObject"];
    UserProfile *toRet = (UserProfile*)[NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return toRet;
}

+ (NSString*)pathWithIdentifier:(NSString*)uniqueID {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@%@", uniqueID, @".txt"];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:path];
    return appFile;
}

@end
