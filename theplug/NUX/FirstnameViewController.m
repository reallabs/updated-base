//
//  FirstNameViewController.m
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import "FirstnameViewController.h"
#import "ApiFunctions.h"

@interface FirstnameViewController ()

@property (nonatomic, strong) NSString *firstnameString;

@property (nonatomic, strong) HeaderView *header;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextField *firstName;
@property (nonatomic, strong) UIButton *nextButton;

@end

@implementation FirstnameViewController

- (instancetype)init {
    self = [super init];
    CGRect layerRect = [[[self view] layer] bounds];
    CGFloat screenHeight = CGRectGetHeight(layerRect);
    CGFloat screenWidth = CGRectGetWidth(layerRect);
    self.view.backgroundColor = [UIColor accentColor];

    CGRect headerFrame = CGRectMake(0, 0, screenWidth, kHeaderFooterHeight);
    _header = [[HeaderView alloc] initWithFrame:headerFrame
                                      withTitle:nil
                                   withSubtitle:nil
                                 withLeftButton:nil
                                withRightButton:nil
                                  withStatusBar:[self prefersStatusBarHidden]
                                   hasSubheader:NO];
    [_header setLeftButtonImage:[UIImage imageNamed:@"back.png"]];
    _header.headerDelegate = self;
    [self.view addSubview:_header];

    CGFloat labelStartX = (32.0 / 375.0) * screenWidth;
    CGFloat labelSizeX = screenWidth - (2*labelStartX);
    CGFloat labelStartY = (108.0 / 667.0) * screenHeight;
    CGFloat labelSizeY = (24.0 / 667.0) * screenHeight;
    CGRect labelRect = CGRectMake(labelStartX, labelStartY, labelSizeX, labelSizeY);

    _nameLabel = [[UILabel alloc] initWithFrame:labelRect];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.text = @"What's your first name?";
    _nameLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightBold];
    [self.view addSubview:_nameLabel];

    CGFloat usernameSizeY = (38.0 / 667.0) * screenHeight;
    CGFloat usernameStartX = (32.0 / 375.0) * screenWidth;
    CGFloat usernameSizeX = screenWidth - (2*usernameStartX);
    CGFloat usernameStartY = (152.0 / 667.0) * screenHeight;
    CGRect inputRect = CGRectMake(usernameStartX, usernameStartY, usernameSizeX, usernameSizeY);

        // Firstname input field
    _firstName= [[UITextField alloc] initWithFrame:inputRect];
    _firstName.delegate = self;
    _firstName.tintColor = [UIColor whiteColor];
    _firstName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"First Name" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.4]}];
    _firstName.textAlignment = NSTextAlignmentLeft;
    _firstName.font = [UIFont systemFontOfSize:32.0 weight:UIFontWeightHeavy];
    _firstName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _firstName.autocapitalizationType = UITextAutocapitalizationTypeWords;
    _firstName.autocorrectionType = UITextAutocorrectionTypeNo;
    _firstName.textColor = [UIColor whiteColor];
    [self.view addSubview:_firstName];

    [_firstName becomeFirstResponder];

    CGFloat nextStartY = (319.0 / 667.0) * screenHeight;
    CGFloat nextStartX = labelStartX;
    CGFloat nextSizeX = screenWidth - (2*labelStartX);
    CGFloat nextSizeY = (58.0 / 667.0) * screenHeight;
    CGRect nextRect = CGRectMake(nextStartX, nextStartY, nextSizeX, nextSizeY);
    _nextButton = [[UIButton alloc] initWithFrame:nextRect];
    _nextButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    [_nextButton addTarget:self action:@selector(onNextTapped) forControlEvents:UIControlEventTouchUpInside];
    [_nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [_nextButton setTitleColor:[UIColor accentColor] forState:UIControlStateNormal];
    _nextButton.layer.cornerRadius = nextSizeY / 2;
    [self.view addSubview:_nextButton];

    return self;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([_firstName.text length] == 1 && [string isEqualToString:@""]) {
        _nextButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    } else {
        _nextButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    }
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[Mixpanel sharedInstance] track:@"NuxSignUpViewDidAppear"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (void)onLeftButtonTapped {
    [_delegate onBackPressed];
}


- (void)onNextTapped {
    if([_firstName.text length] < 1) {
        [_firstName shake];
        return;
    } else {
        [_delegate onSignUpCompletedWithFirstname:_firstName.text];
    }
}

#pragma mark - UIViewController overrides

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return (UIStatusBarStyle)UIBarStyleBlack;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

