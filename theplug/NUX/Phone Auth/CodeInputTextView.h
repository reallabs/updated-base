//
//  CodeInputTextView.h
//  Boom
//
//  Created by James Maxwell on 2/27/17.
//  Copyright © 2017 Upcast, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CodeInputTextDelegate <NSObject>
- (void)onEmptyBackspaceTapped;
@end


@interface CodeInputTextView : UITextField <UITextFieldDelegate>

-(instancetype) initWithFrame:(CGRect)frame;

@property int index;

@property (nonatomic, readwrite, weak) id<CodeInputTextDelegate> codeInputTextDelegate;

-(void) unsetBorder;
@end
