//
//  CodeInputView.h
//  Boom
//
//  Created by James Maxwell on 2/27/17.
//  Copyright © 2017 Upcast, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CodeInputTextView.h"


@protocol CodeInputDelegate <NSObject>
- (void)onCodeEntered:(NSMutableString*)code;
@end

@interface CodeInputView : UITextField <UITextFieldDelegate>

-(instancetype) initWithFrame:(CGRect)frame;

@property (nonatomic, strong) NSMutableString *code;

@property (nonatomic, readwrite, weak) id<CodeInputDelegate> codeInputDelegate;

@property int currentDigit;

-(void) clearLastTextField;
-(void) clearAllFields;
-(void) firstTextFieldBecomeFirstResponder;
-(void) becomeFirstResponderAtCorrectSpot;

@end

