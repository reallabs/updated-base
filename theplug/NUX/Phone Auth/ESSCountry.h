//
//  ESSCountry.h
//  ESSPhoneNumberFieldDemo
//
//  Created by Erik Strottmann on 7/11/14.
//  Copyright (c) 2014 Erik Strottmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESSCountry : NSObject

/** ISO two-letter country code */
@property (nonatomic) NSString *regionCode;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *callingCode;

+ (instancetype)countryWithRegionCode:(NSString *)regionCode
                                 name:(NSString *)name
                          callingCode:(NSString *)callingCode;

@end
