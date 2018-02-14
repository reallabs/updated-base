//
//  CodeInputView.m
//  Boom
//
//  Created by James Maxwell on 2/27/17.
//  Copyright © 2017 Upcast, Inc. All rights reserved.
//

#import "CodeInputView.h"

@implementation CodeInputView {
}


-(instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"••••" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.4]}];
    self.textAlignment = NSTextAlignmentLeft;
    self.delegate = self;
    self.font = [UIFont systemFontOfSize:32.0 weight:UIFontWeightHeavy];
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.autocorrectionType = UITextAutocorrectionTypeYes;
    self.textColor = [UIColor whiteColor];
    self.keyboardType = UIKeyboardTypeNumberPad;
    
    return self;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([textField.text length] == 3 && [string length] == 1) {
        [_codeInputDelegate onCodeEntered:[[NSString stringWithFormat:@"%@%@", textField.text, string] mutableCopy]];
    }
    return YES;
}


@end
