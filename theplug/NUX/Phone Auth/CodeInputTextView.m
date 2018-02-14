//
//  CodeInputTextView.m
//  Boom
//
//  Created by James Maxwell on 2/27/17.
//  Copyright © 2017 Upcast, Inc. All rights reserved.
//

#import "CodeInputTextView.h"

@implementation CodeInputTextView {
    CALayer *bottomBorder;
}

-(instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.delegate = self;
    self.keyboardType = UIKeyboardTypeNumberPad;
    self.backgroundColor = [UIColor accentColor];
    self.textColor = [UIColor blackColor];
    self.textAlignment = NSTextAlignmentCenter;
    self.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightMedium];
    
    bottomBorder = [CALayer layer];
    [self unsetBorder];
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(0, CGRectGetHeight(frame) - 1, CGRectGetWidth(frame), 1);
    [self.layer addSublayer:bottomBorder];
    
    return self;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int isBackSpace = strcmp(_char, "\b");
    //Allow backspaces
    if (isBackSpace == -8) {
        if([searchStr length] == 0) {
            [self unsetBorder];
        }
        return YES;
    }
    if([searchStr length] == 0) {
        [self unsetBorder];
        return YES;
    }
    if([searchStr length] == 1) {
        [self setBorder];
        return YES;
    }
    return NO;
}


- (void)deleteBackward
{
    [super deleteBackward];
    if([self.text length] == 0) {
        [_codeInputTextDelegate onEmptyBackspaceTapped];
    }
}

-(void) unsetBorder {
    bottomBorder.borderColor = [UIColor colorWithRed:209.0/255.0 green:209.0/255.0 blue:209.0/255.0 alpha:1.0].CGColor;
}


-(void) setBorder {
    bottomBorder.borderColor = [UIColor whiteColor].CGColor;
}

@end
