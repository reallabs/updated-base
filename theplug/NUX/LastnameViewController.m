//
//  LastnameViewController.m
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import "LastnameViewController.h"

@interface LastnameViewController ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextField *lastName;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) HeaderView *header;
@end

@implementation LastnameViewController

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
    _nameLabel.text = @"What's your last name?";
    _nameLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightBold];
    [self.view addSubview:_nameLabel];

    CGFloat usernameSizeY = (38.0 / 667.0) * screenHeight;
    CGFloat usernameStartX = (32.0 / 375.0) * screenWidth;
    CGFloat usernameSizeX = screenWidth - (2*usernameStartX);
    CGFloat usernameStartY = (152.0 / 667.0) * screenHeight;
    CGRect inputRect = CGRectMake(usernameStartX, usernameStartY, usernameSizeX, usernameSizeY);

        // lastName input field
    _lastName= [[UITextField alloc] initWithFrame:inputRect];
    _lastName.delegate = self;
    _lastName.tintColor = [UIColor whiteColor];
    _lastName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Last Name" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.4]}];
    _lastName.textAlignment = NSTextAlignmentLeft;
    _lastName.font = [UIFont systemFontOfSize:32.0 weight:UIFontWeightHeavy];
    _lastName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _lastName.autocapitalizationType = UITextAutocapitalizationTypeWords;
    _lastName.autocorrectionType = UITextAutocorrectionTypeNo;
    _lastName.textColor = [UIColor whiteColor];
    [self.view addSubview:_lastName];

    [_lastName becomeFirstResponder];

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
    if([_lastName.text length] == 1 && [string isEqualToString:@""]) {
        _nextButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    } else {
        _nextButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    }
    return YES;
}


- (void)onLeftButtonTapped {
    [_delegate onBackPressed];
}

- (void)onNextTapped {
    if([_lastName.text length] < 1) {
        [_lastName shake];
        return;
    } else {
        [_delegate onSignUpCompletedWithLastname:_lastName.text];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}


- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end

