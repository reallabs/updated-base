//
//  CountryNameView.m
//  Boom
//
//  Created by James Maxwell on 3/31/17.
//  Copyright © 2017 Upcast, Inc. All rights reserved.
//

#import "CountryNameView.h"

@implementation CountryNameView {
    UILabel *countryName;
    UIButton *carretView;
}

-(instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    countryName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - frame.size.height, frame.size.height)];
    self.backgroundColor = [UIColor accentColor];
    NSLocale *locale = [NSLocale currentLocale];
    if(SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        NSLocale *usLocale =[[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
        NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
        NSString *country = [usLocale displayNameForKey:NSLocaleCountryCode value:countryCode];
        countryName.text = country;
    } else {
        countryName.text = [locale localizedStringForCountryCode:[NSLocale currentLocale].countryCode];
    }
    countryName.textColor = [UIColor colorWithRed:0.0/255.0 green:156.0/255.0 blue:230.0/255.0 alpha:1.0];
    countryName.adjustsFontSizeToFitWidth = YES;
    countryName.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightMedium];
    [self addSubview:countryName];
    
    carretView = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - frame.size.height, 0, frame.size.height, frame.size.height)];
    [carretView setImage:[UIImage imageNamed:@"arrow_right.png"] forState:UIControlStateNormal];
    carretView.imageEdgeInsets = UIEdgeInsetsMake(frame.size.height / 6, frame.size.height/3, frame.size.height/6, 0);
    carretView.userInteractionEnabled = NO;
    [self addSubview:carretView];
    
    return self;
}

-(void) setCountryName:(NSString*)country {
    countryName.text = country;
}


@end
