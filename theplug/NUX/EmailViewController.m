//
//  EmailViewController.m
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import "EmailViewController.h"

@interface EmailViewController ()

@property (nonatomic, strong) HeaderView *header;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextField *email;
@property (nonatomic, strong) UIButton *nextButton;

@end

@implementation EmailViewController

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
                                withRightButton:@"Skip"
                                  withStatusBar:[self prefersStatusBarHidden]
                                   hasSubheader:NO];
    _header.headerDelegate = self;
    [self.view addSubview:_header];

    CGFloat labelStartX = (32.0 / 375.0) * screenWidth;
    CGFloat labelSizeX = screenWidth - (2*labelStartX);
    CGFloat labelStartY = (108.0 / 667.0) * screenHeight;
    CGFloat labelSizeY = (24.0 / 667.0) * screenHeight;
    CGRect labelRect = CGRectMake(labelStartX, labelStartY, labelSizeX, labelSizeY);

    _nameLabel = [[UILabel alloc] initWithFrame:labelRect];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.text = @"What's your email?";
    _nameLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightBold];
    [self.view addSubview:_nameLabel];

    CGFloat usernameSizeY = (38.0 / 667.0) * screenHeight;
    CGFloat usernameStartX = (32.0 / 375.0) * screenWidth;
    CGFloat usernameSizeX = screenWidth - (2*usernameStartX);
    CGFloat usernameStartY = (152.0 / 667.0) * screenHeight;
    CGRect inputRect = CGRectMake(usernameStartX, usernameStartY, usernameSizeX, usernameSizeY);

        // Firstname input field
    _email= [[UITextField alloc] initWithFrame:inputRect];
    _email.delegate = self;
    _email.tintColor = [UIColor whiteColor];
    _email.adjustsFontSizeToFitWidth = YES;
    _email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.4]}];
    _email.textAlignment = NSTextAlignmentLeft;
    _email.font = [UIFont systemFontOfSize:32.0 weight:UIFontWeightHeavy];
    _email.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _email.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [_email setKeyboardType:UIKeyboardTypeEmailAddress];
    _email.autocorrectionType = UITextAutocorrectionTypeNo;
    _email.textColor = [UIColor whiteColor];
    [self.view addSubview:_email];

    [_email becomeFirstResponder];
        //Sometimes deosnt' work so add a delay?
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_email becomeFirstResponder];
    });

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
    if([_email.text length] == 1 && [string isEqualToString:@""]) {
        _nextButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    } else {
        _nextButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    }
    return YES;
}


- (void)onLeftButtonTapped {
        //    [_delegate onBackPressed];
}

- (void)onNextTapped {
    if(![self NSStringIsValidEmail:_email.text]) {
        [_email shake];
        return;
    } else {
        [_delegate onEmailCompletedWithEmail:_email.text];
    }
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString {
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

-(void) onRightButtonTapped {
    [_delegate onEmailCompletedWithEmail:@""];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}
/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

