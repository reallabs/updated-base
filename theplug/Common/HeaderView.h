//
//  HeaderView.h
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>

@protocol HeaderDelegate <NSObject>
@optional
- (void)onLeftButtonTapped;
- (void)onRightButtonTapped;
- (void)onHeaderTapped;
@end

@interface HeaderView : UIButton

@property (nonatomic, readwrite, weak) id<HeaderDelegate> headerDelegate;

- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString*)title withSubtitle:(NSString*)subtitle withLeftButton:(NSString*)leftButton withRightButton:(NSString*)rightButton withStatusBar:(BOOL)statusBar hasSubheader:(BOOL)hasSubheader;

- (void)setTitleString:(NSString*)title;

- (void)setTitleAttributedString:(NSAttributedString*)title;

- (void)setSubtitleString:(NSString*)title;


- (void)setLeftButtonString:(NSString*)title;

- (void)setLeftButtonAttributedString:(NSAttributedString*)string;

- (void)setRightButtonString:(NSString*)title;

- (void)setRightButtonAttributedString:(NSAttributedString*)string;

- (void)setLeftButtonImage:(UIImage*)image;

- (void)setRightButtonImage:(UIImage*)image;

- (void)setRightButtonSpinner;

- (void)removeLeftButton;

- (void)removeRightButton;

- (void)invert:(float)percentage;

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *subtitle;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;;


@end

