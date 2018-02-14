//
//  ApiFunctions.m
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import "ApiFunctions.h"
#import "AppDelegate.h"

    //#define ENDPOINT_URL @"https://boom-prod.herokuapp.com/"
    //#define BUCKET_PREFIX @"boom-"

@implementation ApiFunctions


+ (void)uploadUserData:(NSDictionary *)data completion:(void (^)(id responseObject, NSError *error))completion {
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KEYCHAIN_STRING];

    if([keychain stringForKey:@"userid"]) {
        [data setValue:[keychain stringForKey:@"userid"] forKey:@"userid"];
        [self uploadToAPI:@"user/update_user_fields" data:[data mutableCopy] completion:^(id responseObject, NSError *error) {
            if (responseObject && !error) {
                completion(responseObject, nil);
            }
            else {
                NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
                completion(responseObject, error);
            }
        }];
    }
}

+ (void) updateAccessTokenWithCompletion:(void (^)(id responseObject, NSError *error))completion {

    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KEYCHAIN_STRING];
    NSString *userid = [keychain stringForKey:@"userid"];
    if(userid) {
        NSMutableDictionary *data  = [[NSMutableDictionary alloc]init];
        [data setObject:userid forKey:@"userid"];
        [self downloadFromAPIWithGet:@"auth/get_new_access_token" data:data completion:^(id responseObject, NSError *error) {
            if (responseObject && !error) {
                completion(responseObject, nil);
            } else {
                NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
                completion(responseObject, error);
            }
        }];
    }
}



+ (void)uploadPhoneNumber:(NSString *)phone_number completion:(void (^)(id responseObject, NSError *error))completion {
    NSMutableDictionary *data  = [[NSMutableDictionary alloc]init];
    [data setObject:phone_number forKey:@"phone_number"];
    [self uploadToAPI:@"phone_auth" data:data completion:^(id responseObject, NSError *error) {
        if (responseObject && !error) {
            completion(responseObject, nil);
        }
        else {
            NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
            completion(responseObject, error);
        }
    }];
}


+ (void)resendPhoneAuthCode:(NSString *)phone_number completion:(void (^)(id responseObject, NSError *error))completion {
    NSMutableDictionary *data  = [[NSMutableDictionary alloc]init];
    [data setObject:phone_number forKey:@"phone_number"];
    [self uploadToAPI:@"resend_phone_auth" data:data completion:^(id responseObject, NSError *error) {
        if (responseObject && !error) {
            completion(responseObject, nil);
        }
        else {
            NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
            completion(responseObject, error);
        }
    }];
}


+ (void)uploadPhoneAuthCode:(NSString *)auth_code phoneNumber:(NSString*)phone_number completion:(void (^)(id responseObject, NSError *error))completion {
    NSMutableDictionary *data  = [[NSMutableDictionary alloc]init];
    [data setObject:auth_code forKey:@"auth_code"];
    [data setObject:phone_number forKey:@"phone_number"];
    [self downloadFromAPI:@"phone_auth_confirmation" data:data completion:^(id responseObject, NSError *error) {
        if (responseObject && !error) {
            completion(responseObject, nil);
        }
        else {
            NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
            completion(responseObject, error);
        }
    }];
}


+ (void)downloadUserProfile:(NSString *)userid completion:(void (^)(id responseObject, NSError *error))completion {
    NSMutableDictionary *data  = [[NSMutableDictionary alloc]init];
    [data setObject:userid forKey:@"userid"];
    [self downloadFromAPIWithGet:@"user/get_user_data" data:data completion:^(id responseObject, NSError *error) {
        if (responseObject && !error) {
            completion(responseObject, nil);
        }
        else {
            if ([(NSHTTPURLResponse *)responseObject statusCode] == 403) {
                    //We got forbidden when we tried to get the user? Shit let's log out and then back in to reset our token and make sure things run alright
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate logOut];
                [appDelegate maybeLogin];
            }
            NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
            completion(responseObject, error);
        }
    }];
}


+ (void)submitEvent:(NSString *)eventType wasUserAction:(BOOL)wasUserAction withjsonExtra:(NSDictionary*)extra completion:(void (^)(id responseObject, NSError *error))completion {
    NSMutableDictionary *data  = [[NSMutableDictionary alloc]init];
    [data setObject:eventType forKey:@"event_type"];
    if(extra) {
        [data setObject:extra forKey:@"event_extra"];
    }
    [data setObject:[NSNumber numberWithBool:wasUserAction] forKey:@"user_action"];
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KEYCHAIN_STRING];

    if([keychain stringForKey:@"userid"]) {
        [data setValue:[keychain stringForKey:@"userid"] forKey:@"userid"];
        [self uploadToAPI:@"api/submit_event" data:data completion:^(id responseObject, NSError *error) {
            if (responseObject && !error) {
                completion(responseObject, nil);
            }
            else {
                NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
                completion(responseObject, error);
            }
        }];
    }
}


+ (void) uploadPushToken:(NSString *)token completion:(void (^)(id responseObject, NSError *error))completion {
    NSMutableDictionary *tokenData = [[NSMutableDictionary alloc] init];
    [tokenData setValue:token forKey:@"token"];

    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KEYCHAIN_STRING];

    if([keychain stringForKey:@"userid"]) {
        [tokenData setValue:[keychain stringForKey:@"userid"] forKey:@"userid"];

        [self uploadToAPI:@"api/register_push_token" data:tokenData completion:^(id responseObject, NSError *error) {
            if (responseObject && !error) {
                completion(responseObject, nil);
            } else {
                NSLog(@"%s: serverRequest error: %@", __FUNCTION__, error);
                completion(responseObject, error);
            }
        }];
    }
}


+ (void)uploadToAPI:(NSString *)api data:(NSMutableDictionary *)data completion:(void (^)(id responseObject, NSError *error))completion{

    NSError *error;
    NSURLSession *defaultSession = [NSURLSession sharedSession];
        //    NSString *stringurl =@"http://localhost:8081/";
    NSString *stringurl = ENDPOINT_URL;
    stringurl = [stringurl stringByAppendingString:api];
    NSURL *URL = [NSURL URLWithString:stringurl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];

    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KEYCHAIN_STRING];

    NSData *postData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", [keychain stringForKey:@"access_token"]] forHTTPHeaderField:@"Authorization"];
        // NSLog(@"Our session token is: %@", [NSString stringWithFormat:@"Bearer %@", [keychain stringForKey:@"access_token"]]);
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        //    NSLog(@"Uploading this data: %@", [[NSString alloc]initWithData:postData encoding:NSUTF8StringEncoding]);

    NSURLSessionUploadTask *uploadTask = [defaultSession uploadTaskWithRequest:request fromData:postData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ([(NSHTTPURLResponse *)response statusCode] != 200) {
            if (completion) {
                NSError *error = [NSError errorWithDomain:@"httpError" code:[(NSHTTPURLResponse *)response statusCode] userInfo:nil];
                completion(response, error);
            }
            return;
        }

            // if everything is ok, then just return the response from the server

        if (completion) {
            completion(response, error);
        }
    }];
    [uploadTask resume];
}


+ (void)downloadFromAPI:(NSString *)api userid:(NSString *)userid completion:(void (^)(id responseObject, NSError *error))completion {

    NSMutableDictionary *user_object  = [[NSMutableDictionary alloc]init];
    [user_object setObject:userid forKey:@"userid"];

    NSError *error;
    NSURLSession *defaultSession = [NSURLSession sharedSession];
        //    NSString *stringurl =@"http://localhost:8081/";
    NSString *stringurl =ENDPOINT_URL;

    stringurl = [stringurl stringByAppendingString:api];
    NSURL *URL = [NSURL URLWithString:stringurl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KEYCHAIN_STRING];

    NSData *postData = [NSJSONSerialization dataWithJSONObject:user_object options:NSJSONWritingPrettyPrinted error:&error];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", [keychain stringForKey:@"access_token"]] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSURLSessionUploadTask *uploadTask = [defaultSession uploadTaskWithRequest:request fromData:postData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            // report any network-related errors

        if ([(NSHTTPURLResponse *)response statusCode] != 200) {
            if (completion) {
                NSLog(@"Did not return status 200. Error");
                NSError *error = [NSError errorWithDomain:@"httpError" code:[(NSHTTPURLResponse *)response statusCode] userInfo:nil];
                completion(response, error);
            }
            return;
        }

            // report any errors parsing the JSON

        NSError *parseError = nil;
        NSJSONSerialization *returnedData;
        returnedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];

        if ([data length] > 0 && parseError)  {
            if (completion) {
                NSLog(@"Failed to parse data");
                completion(response, parseError);
            }
            return;
        }

            // if everything is ok, then just return the JSON object

        if (completion) {
            completion(returnedData, error);
        }
    }];

    [uploadTask resume];
}

+ (void)downloadFromAPI:(NSString *)api data:(NSDictionary *)data completion:(void (^)(id responseObject, NSError *error))completion {

    NSError *error;
    NSURLSession *defaultSession = [NSURLSession sharedSession];
        //    NSString *stringurl =@"http://localhost:8081/";
    NSString *stringurl =ENDPOINT_URL;

    stringurl = [stringurl stringByAppendingString:api];
    NSURL *URL = [NSURL URLWithString:stringurl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KEYCHAIN_STRING];

    NSData *postData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", [keychain stringForKey:@"access_token"]] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSURLSessionUploadTask *uploadTask = [defaultSession uploadTaskWithRequest:request fromData:postData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            // report any network-related errors

        if ([(NSHTTPURLResponse *)response statusCode] != 200) {
            if (completion) {
                NSLog(@"Did not return status 200. Error");
                NSError *error = [NSError errorWithDomain:@"httpError" code:[(NSHTTPURLResponse *)response statusCode] userInfo:nil];
                completion(response, error);
            }
            return;
        }

            // report any errors parsing the JSON

        NSError *parseError = nil;
        NSJSONSerialization *returnedData;
        returnedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];

        if ([data length] > 0 && parseError)  {
            if (completion) {
                NSLog(@"Failed to parse data");
                completion(response, parseError);
            }
            return;
        }

            // if everything is ok, then just return the JSON object

        if (completion) {
            completion(returnedData, error);
        }
    }];

    [uploadTask resume];
}

+ (void)downloadFromAPIWithGet:(NSString *)api data:(NSDictionary *)data completion:(void (^)(id responseObject, NSError *error))completion {
    NSURLSession *defaultSession = [NSURLSession sharedSession];
        //    NSString *stringurl =@"http://localhost:8081/";
    NSString *stringurl =ENDPOINT_URL;
    stringurl = [stringurl stringByAppendingString:api];
    stringurl = [stringurl stringByAppendingString:@"?"];
    for(id key in data) {
        stringurl = [stringurl stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, [data objectForKey:key]]];
    }
    NSURL *URL = [NSURL URLWithString:[stringurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KEYCHAIN_STRING];

    [request setHTTPMethod:@"GET"];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", [keychain stringForKey:@"access_token"]] forHTTPHeaderField:@"Authorization"];
        //    NSLog(@"Our Bearer Token is: %@", [keychain stringForKey:@"access_token"]);
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    NSURLSessionDataTask *downloadTask = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            // report any network-related errors

        if ([(NSHTTPURLResponse *)response statusCode] != 200) {
            if (completion) {
                NSLog(@"Did not return status 200. Error");
                NSError *error = [NSError errorWithDomain:@"httpError" code:[(NSHTTPURLResponse *)response statusCode] userInfo:nil];
                completion(response, error);
            }
            return;
        }

            // report any errors parsing the JSON
        if(!data) {
            NSError *error = [NSError errorWithDomain:@"noDataReturned" code:[(NSHTTPURLResponse *)response statusCode] userInfo:nil];
            if (completion) {
                completion(nil, error);
            }
        } else {
            NSError *parseError = nil;
            NSJSONSerialization *returnedData;
            returnedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];

            if ([data length] > 0 && parseError) {
                if (completion) {
                    NSLog(@"Failed to parse data");
                    completion(response, parseError);
                }
                return;
            }

                // if everything is ok, then just return the JSON object

            if (completion) {
                completion(returnedData, error);
            }
        }
    }];

    [downloadTask resume];
}



@end

