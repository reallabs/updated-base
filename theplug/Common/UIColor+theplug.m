//
//  UIColor+theplug.m
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import "UIColor+theplug.h"

@implementation UIColor (theplug)

+ (UIColor*)accentColor {
    return [UIColor colorWithRed:(232.0 / 255.0) green:(50.0 / 255.0) blue:(113.0 / 255.0) alpha:1.0];
}

+ (UIColor*)accentStartColor {
    return [UIColor colorWithRed:(252.0 / 255.0) green:(78.0 / 255.0) blue:(100.0 / 255.0) alpha:1.0];
}

+ (UIColor*)secondaryColor {
    return [UIColor colorWithRed:(0.0 / 255.0) green:(122.0 / 255.0) blue:(255.0 / 255.0) alpha:1.0];
}

+ (UIColor*)backgroundColor {
    return [UIColor colorWithRed:(245.0 / 255.0) green:(245.0 / 255.0) blue:(245.0 / 255.0) alpha:1.0];
}

+ (UIColor*)borderColor {
    return [UIColor colorWithRed:(231.0 / 255.0) green:(231.0 / 255.0) blue:(231.0 / 255.0) alpha:1.0];
}

+ (UIColor*)searchBackgroundColor {
    return [UIColor colorWithRed:(241.0 / 255.0) green:(241.0 / 255.0) blue:(241.0 / 255.0) alpha:1.0];
}

+ (UIColor*)textColor {
    return [UIColor colorWithRed:(28.0 / 255.0) green:(28.0 / 255.0) blue:(28.0 / 255.0) alpha:1.0];
}

+ (UIColor*)lightTextColor {
    return [UIColor colorWithRed:(164.0 / 255.0) green:(166.0 / 255.0) blue:(172.0 / 255.0) alpha:1.0];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end


