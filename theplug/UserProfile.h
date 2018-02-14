//
//  UserProfile.h
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

@interface UserProfile : NSObject

+ (id)selfObject;

@property (nonatomic, strong) NSString *userid;
@property (nonatomic, strong) NSMutableDictionary *userProfileDictionary;

- (id)initWithUserId:(NSString*)userid;

+ (void)purgeCache;

@end

