//
//  NuxLandingViewController.m
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import "NuxLandingViewController.h"
#import "Mixpanel.h"

#import <Shimmer/FBShimmeringView.h>

@interface NuxLandingViewController ()

@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UILabel *mangoText;
@property (nonatomic, strong) UIButton *letsGoButton;
@property (nonatomic, strong) UIButton *termsButton;
@property (nonatomic, strong) UIButton *privacyButton;

@property (nonatomic, strong) FBShimmeringView *shimmerView;


@property CGFloat screenHeight;
@property CGFloat screenWidth;

@end

@implementation NuxLandingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth = [UIScreen mainScreen].bounds.size.width;

    _backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    // _backgroundImage.image = [UIImage imageNamed:@"confetti.png"];
    [self.view addSubview:_backgroundImage];

    CGFloat mangoStartY = (219.0 / 667.0) * _screenHeight;
    CGFloat mangoSizeY = (77.0 / 667.0) * _screenHeight;
    CGFloat mangoSizeX = (59.0 / 375.0) * _screenWidth;
    CGFloat mangoStartX = (168.0 / 375.0) * _screenWidth;
    CGRect mangoRect = CGRectMake(mangoStartX, mangoStartY, mangoSizeX, mangoSizeY);
    _logoView = [[UIImageView alloc] initWithFrame:mangoRect];
    [_logoView setBackgroundColor:[UIColor accentColor]];
        // _logoView.image = [UIImage imageNamed:@"mango.png"];
    [self.view addSubview:_logoView];

    CGFloat labelStartY = (334.0 / 667.0) * _screenHeight;
    CGFloat labelSizeY = (48.0 / 667.0) * _screenHeight;
    CGFloat labelSizeX = _screenWidth / 2;
    CGFloat labelStartX = (_screenWidth / 2) - (labelSizeX / 2);
    CGRect labelRect = CGRectMake(labelStartX, labelStartY, labelSizeX, labelSizeY);
    _mangoText = [[UILabel alloc] initWithFrame:labelRect];
    _mangoText.text = @"subtext";
    _mangoText.numberOfLines = 2;
    _mangoText.adjustsFontSizeToFitWidth = YES;
    _mangoText.textAlignment = NSTextAlignmentCenter;
    _mangoText.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightHeavy];
    _mangoText.textColor = [UIColor colorWithRed:203.0/255.0 green:204.0/255.0 blue:206.0/255.0 alpha:1.0];
    [self.view addSubview:_mangoText];

    CGFloat buttonSizeX = _screenWidth / 5 * 4;
    CGFloat buttonSizeY = (58.0 / 667.0) * _screenHeight;
    CGFloat buttonStartY = (479.0 / 667.0) * _screenHeight;
    CGFloat buttonStartX = (_screenWidth / 2) - (buttonSizeX / 2);
    CGRect buttonRect = CGRectMake(buttonStartX, buttonStartY, buttonSizeX, buttonSizeY);

    _shimmerView = [[FBShimmeringView alloc] initWithFrame:buttonRect];
    _letsGoButton = [[UIButton alloc] initWithFrame:_shimmerView.bounds];
    _letsGoButton.layer.cornerRadius = buttonSizeY / 2;
    [_letsGoButton addTarget:self action:@selector(onNextButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_letsGoButton setBackgroundColor:[UIColor accentColor]];
    [_letsGoButton setTitle:NSLocalizedString(@"Get Started", nil) forState:UIControlStateNormal];
    [_letsGoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _letsGoButton.titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightBold];


    _shimmerView.contentView = _letsGoButton;
    _shimmerView.shimmering = YES;
    _shimmerView.shimmeringSpeed = 130;
    _shimmerView.shimmeringHighlightWidth = 1.0;
    _shimmerView.shimmeringAnimationOpacity = 0.85;
    _shimmerView.shimmeringBeginFadeDuration = 1.0;


    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    [[Mixpanel sharedInstance] track:@"NuxLandingViewDidAppear"
                          properties:@{@"language": language}];

    CGFloat termsSizeX = (_screenWidth - (kLeftRightPadding * 2.0)) / 3;
    CGFloat termsStartY = CGRectGetMaxY(buttonRect);
    CGFloat termsSizeY = buttonRect.size.height;
    CGFloat termsStartX = (_screenWidth / 2) - termsSizeX;
    CGRect termsRect = CGRectMake(termsStartX, termsStartY, termsSizeX, termsSizeY);

    CGRect privacyRect = CGRectMake((_screenWidth / 2), termsStartY, termsSizeX, termsSizeY);

    _termsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _termsButton.frame = termsRect;
    _termsButton.alpha = 1.0;
    [_termsButton setBackgroundColor:[UIColor clearColor]];
    [_termsButton setTitle:@"Terms of Use" forState:UIControlStateNormal];
    [_termsButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_termsButton setTitleColor:[UIColor colorWithRed:167.0/255.0 green:167.0/255.0 blue:167.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    _termsButton.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [_termsButton
     addTarget:self
     action:@selector(onTermsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_termsButton];

    _privacyButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _privacyButton.frame=privacyRect;
    _privacyButton.alpha = 1.0;
    [_privacyButton setBackgroundColor:[UIColor clearColor]];
    [_privacyButton setTitleColor:[UIColor colorWithRed:167.0/255.0 green:167.0/255.0 blue:167.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_privacyButton setTitle:@"Privacy Policy" forState:UIControlStateNormal];
    [_privacyButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    _privacyButton.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [_privacyButton
     addTarget:self
     action:@selector(onPrivacyButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_privacyButton];

    [self.view addSubview:_shimmerView];
}


- (BOOL)setAsLink:(NSString*)textToFind linkURL:(NSString*)linkURL {


    return NO;
}


- (void)onTermsButtonTapped {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://mango.lol/terms"] options:@{} completionHandler:^(BOOL success) {
            //
    }];
}


- (void)onPrivacyButtonTapped {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://mango.lol/privacy"] options:@{} completionHandler:^(BOOL success) {
            //
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (void)onNextButtonTapped {
    [_delegate onLandingNextButtonPressed];
}

#pragma mark - UIViewController overrides

- (BOOL)prefersStatusBarHidden{
    return YES;
}
@end
