//
//  HeaderView.m
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HeaderView.h"

#define kStatusBarOffset 20

@interface HeaderView() {

}


@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;


@property CGFloat width;
@property CGFloat height;
@property CGFloat primaryFontSize;
@property CGFloat titleFontSize;
@property CGFloat leftRightPadding;
@property BOOL statusBarVisible;

@end

@implementation HeaderView

- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString*)title withSubtitle:(NSString*)subtitle withLeftButton:(NSString*)leftButton withRightButton:(NSString*)rightButton withStatusBar:(BOOL)statusBar hasSubheader:(BOOL)hasSubheader {
    self = [super initWithFrame:frame];
    [self setBackgroundColor:[UIColor clearColor]];

    _width = frame.size.width;
    _statusBarVisible = !statusBar;
    _height = _statusBarVisible ? (frame.size.height - 20) : frame.size.height;
    _titleFontSize = 16.0;
    _leftRightPadding = kLeftRightPadding;
    _primaryFontSize = 14.0;

    if (subtitle != nil && title != nil) {
        [self setupTitle:title withSubtitle:subtitle];
    } else if (title != nil) {
        [self setupTitleOnly:title];
    }

    if (leftButton != nil) {
        [self setupLeftButton:leftButton];
    }

    if (rightButton != nil) {
        [self setupRightButton:rightButton];
    }

        //    if (!hasSubheader) {
        //        // Bottom border
        //        self.clipsToBounds = NO;
        //        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        //        self.layer.shadowPath = shadowPath.CGPath;
        //        self.layer.masksToBounds = NO;
        //        self.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.1].CGColor;
        //        self.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        //        self.layer.shadowRadius = 0.0f;
        //        self.layer.shadowOpacity = 1.0f;
        //    } else {
        ////        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 1.0, frame.size.width, 1.0)];
        ////        [line setBackgroundColor:[UIColor colorWithWhite:0.93 alpha:1.0]];
        ////        [self addSubview:line];
        //    }

    if (_statusBarVisible) {
            // This adds a shadow underneath the status bar
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _width, 20)];
        [header setBackgroundColor:[UIColor accentColor]];
        header.clipsToBounds = NO;
            //        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, header.frame.size.width, header.frame.size.height)];
            //        header.layer.shadowPath = shadowPath.CGPath;
            //        header.layer.masksToBounds = NO;
            //        header.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.1].CGColor;
            //        header.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
            //        header.layer.shadowRadius = 2.0f;
            //        header.layer.shadowOpacity = 1.0f;
        [self addSubview:header];
    }

    return self;
}

#pragma mark - Helper methods

- (void)setupTitle:(NSString*)title withSubtitle:(NSString*)subtitle {

        // If the title is already setup, remove it!
    if (_title) {
            // If we dont have a new title, keep the old one
        if ([title isEqualToString:@""]) {
            title = _title.text;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_title removeFromSuperview];
        });
        _title = nil;
    }

        // Title and Subtitle layout
    CGFloat fullnameStartX = _width / 5;
    CGFloat fullnameSizeY = _titleFontSize * 1.25;
    CGFloat fullnameStartY = _height / 2.0 - fullnameSizeY - 1;
    fullnameStartY = _statusBarVisible  ? (fullnameStartY + kStatusBarOffset) : fullnameStartY;
    CGFloat fullnameSizeX = _width / 5 * 3;

    CGRect fullnameRect = CGRectMake(fullnameStartX, fullnameStartY, fullnameSizeX, fullnameSizeY);

    _title = [[UILabel alloc] initWithFrame:fullnameRect];
    _title.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
    _title.textAlignment = NSTextAlignmentCenter;
    _title.adjustsFontSizeToFitWidth = YES;
    _title.lineBreakMode = NSLineBreakByWordWrapping;
    [_title setTextColor:[UIColor whiteColor]];
    _title.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(onTitleTapped)];
    [_title addGestureRecognizer:tapGesture];

    dispatch_async(dispatch_get_main_queue(), ^{
        [_title setText:title];
        [self addSubview:_title];
    });

        // Subtitle
    CGFloat usernameStartX = _width / 5;
    CGFloat usernameStartY = _height / 2.0 + 1;
    usernameStartY = _statusBarVisible  ? (usernameStartY + kStatusBarOffset) : usernameStartY;
    CGFloat usernameSizeX = _width / 5 * 3;
    CGFloat usernameSizeY = _primaryFontSize;
    CGRect usernameRect = CGRectMake(usernameStartX, usernameStartY, usernameSizeX, usernameSizeY);

    _subtitle = [[UILabel alloc] initWithFrame:usernameRect];
    _subtitle.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular];
    _subtitle.textAlignment = NSTextAlignmentCenter;
    _subtitle.adjustsFontSizeToFitWidth = YES;
    [_subtitle setTextColor:[UIColor whiteColor]];

    dispatch_async(dispatch_get_main_queue(), ^{
        [_subtitle setText:subtitle];
        [self addSubview:_subtitle];
    });
}

- (void)setupTitleOnly:(NSString*)string {
        // Title only layout
    UIFont *primaryFont = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    NSDictionary *attributes = @{ NSFontAttributeName: primaryFont,
                                  NSForegroundColorAttributeName: [UIColor whiteColor],
                                  NSParagraphStyleAttributeName: paragraphStyle };

    NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    [self setupAttributedTitleOnly:attributed];
}

- (void)setupAttributedTitleOnly:(NSAttributedString*)string {
        // Title only layout
    CGFloat textStartX = _leftRightPadding;
    CGFloat textStartY = 0;
    textStartY = _statusBarVisible  ? (textStartY + kStatusBarOffset) : textStartY;
    CGFloat textSizeX = _width - _leftRightPadding * 2.0;
    CGFloat textSizeY = _height;
    CGRect introTextRect = CGRectMake(textStartX, textStartY, textSizeX, textSizeY);

    _title = [[UILabel alloc] initWithFrame:introTextRect];
    _title.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
    [_title setTextColor:[UIColor whiteColor]];
    [_title setTextAlignment:NSTextAlignmentCenter];
    _title.lineBreakMode = NSLineBreakByWordWrapping;
    _title.numberOfLines = 1;
    [_title setTextColor:[UIColor whiteColor]];
    _title.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(onTitleTapped)];
    [_title addGestureRecognizer:tapGesture];

    dispatch_async(dispatch_get_main_queue(), ^{
        [_title setAttributedText:string];
        [self addSubview:_title];
    });

}

- (void)setupLeftButton:(NSString*)string {
    if (_leftButton) {
        [_leftButton setTitle:string forState:UIControlStateNormal];
        return;
    }
        // Left Button Layout
    CGFloat backSizeX = (_width / 4);
    CGFloat backStartX = 0;
    CGFloat backStartY = 0;
    backStartY = _statusBarVisible  ? (backStartY + kStatusBarOffset) : backStartY;
    CGFloat backSizeY = _height;

    _leftButton  = [[UIButton alloc] initWithFrame:CGRectMake(backStartX, backStartY, backSizeX, backSizeY)];
    _leftButton.titleEdgeInsets = UIEdgeInsetsMake(0, _leftRightPadding, 0, 0);
    _leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _leftButton.titleLabel.numberOfLines = 1;
    _leftButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _leftButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    UIFont *primaryFont = [UIFont systemFontOfSize:18.0 weight:UIFontWeightBold];
    NSDictionary *backAttrs = @{ NSFontAttributeName: primaryFont,
                                 NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSAttributedString *backTitle = [[NSAttributedString alloc] initWithString:string attributes:backAttrs];
    [_leftButton addTarget:self action:@selector(onLeftButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_leftButton setAttributedTitle:backTitle forState:UIControlStateNormal];
        [self addSubview:_leftButton];
        [self bringSubviewToFront:_leftButton];
    });

}


- (void)setupAttributedLeftButton:(NSAttributedString*)string {
        // Left Button Layout
    CGFloat backSizeX = (_width / 4);
    CGFloat backStartX = 0;
    CGFloat backStartY = 0;
    backStartY = _statusBarVisible  ? (backStartY + kStatusBarOffset) : backStartY;
    CGFloat backSizeY = _height;

    _leftButton  = [[UIButton alloc] initWithFrame:CGRectMake(backStartX, backStartY, backSizeX, backSizeY)];
    _leftButton.titleEdgeInsets = UIEdgeInsetsMake(0, _leftRightPadding, 0, 0);
    _leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _leftButton.titleLabel.numberOfLines = 1;
    _leftButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _leftButton.titleLabel.lineBreakMode = NSLineBreakByClipping;

    [_leftButton addTarget:self action:@selector(onLeftButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_leftButton setAttributedTitle:string forState:UIControlStateNormal];
        [self addSubview:_leftButton];
        [self bringSubviewToFront:_leftButton];
    });

}

- (void)setupRightButton:(NSString*)string {
    if (_rightButton) {
        [_rightButton setTitle:string forState:UIControlStateNormal];
        return;
    }
        // Right Button Layout
    CGFloat nextSizeX =  (_width / 4);
    CGFloat nextStartX = _width - nextSizeX;
    CGFloat nextStartY = 0;
    nextStartY = _statusBarVisible  ? (nextStartY + kStatusBarOffset) : nextStartY;
    CGFloat nextSizeY = _height;

    _rightButton  = [[UIButton alloc] initWithFrame:CGRectMake(nextStartX, nextStartY, nextSizeX, nextSizeY)];
    _rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, _leftRightPadding);
    _rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _rightButton.titleLabel.numberOfLines = 1;
    _rightButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _rightButton.titleLabel.lineBreakMode = NSLineBreakByClipping;

    UIFont *primaryFont = [UIFont systemFontOfSize:18.0 weight:UIFontWeightBold];
    NSDictionary *backAttrs = @{ NSFontAttributeName: primaryFont,
                                 NSForegroundColorAttributeName: [UIColor whiteColor]};
    if ([self makeTextAccent:string]) {
        backAttrs = @{ NSFontAttributeName: [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold],
                       NSForegroundColorAttributeName: [UIColor whiteColor]   };
    }
    NSAttributedString *nextTitle = [[NSAttributedString alloc] initWithString:string attributes:backAttrs];
    [_rightButton addTarget:self action:@selector(onRightButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_rightButton setAttributedTitle:nextTitle forState:UIControlStateNormal];
        [self addSubview:_rightButton];
        [self bringSubviewToFront:_rightButton];
    });
}


- (void)setupAttributedRightButton:(NSAttributedString*)string {
        // Left Button Layout
        // Right Button Layout
    CGFloat nextSizeX =  (_width / 4);
    CGFloat nextStartX = _width - nextSizeX;
    CGFloat nextStartY = 0;
    nextStartY = _statusBarVisible  ? (nextStartY + kStatusBarOffset) : nextStartY;
    CGFloat nextSizeY = _height;

    _rightButton  = [[UIButton alloc] initWithFrame:CGRectMake(nextStartX, nextStartY, nextSizeX, nextSizeY)];
    _rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, _leftRightPadding);
    _rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _rightButton.titleLabel.numberOfLines = 1;
    _rightButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _rightButton.titleLabel.lineBreakMode = NSLineBreakByClipping;

    [_rightButton addTarget:self action:@selector(onRightButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_rightButton setAttributedTitle:string forState:UIControlStateNormal];
        [self addSubview:_rightButton];
        [self bringSubviewToFront:_rightButton];
    });

}

#pragma mark - Setters

- (void)setTitleString:(NSString*)string {
    if (_title) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_title setText:string];
        });
    } else {
        [self setupTitleOnly:string];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendSubviewToBack:_title];
    });
}

- (void)setTitleAttributedString:(NSAttributedString*)title {
    if (_title) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_title setAttributedText:title];
        });
    } else {
        [self setupAttributedTitleOnly:title];
    }
}

- (void)setSubtitleString:(NSString*)string {
    if (_subtitle) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_subtitle setText:string];
        });
    } else {
        [self setupTitle:@"" withSubtitle:string];
    }
}

- (void)setLeftButtonString:(NSString*)string {
    if (_leftButton) {
        [_leftButton setBackgroundColor:[UIColor accentColor]];
        CGFloat backSizeX = (_width / 4);
        CGFloat backStartX = 0;
        CGFloat backStartY = 0;
        backStartY = _statusBarVisible  ? (backStartY + kStatusBarOffset) : backStartY;
        CGFloat backSizeY = _height;
        _leftButton.frame = CGRectMake(backStartX, backStartY, backSizeX, backSizeY);

        UIFont *primaryFont = [UIFont systemFontOfSize:18.0 weight:UIFontWeightBold];
        NSDictionary *backAttrs = @{ NSFontAttributeName: primaryFont,
                                     NSForegroundColorAttributeName: [UIColor whiteColor]};
        NSAttributedString *nextTitle = [[NSAttributedString alloc] initWithString:string attributes:backAttrs];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_leftButton setAttributedTitle:nextTitle forState:UIControlStateNormal];
        });
    } else {
        [self setupLeftButton:string];
    }
}


- (void)setLeftButtonAttributedString:(NSAttributedString*)string {
    if (_leftButton) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_leftButton setAttributedTitle:string forState:UIControlStateNormal];
        });
    } else {
        [self setupAttributedLeftButton:string];
    }
}

- (void)setRightButtonString:(NSString*)string {
    if (_rightButton) {
            // Right Button Layout
        CGFloat nextSizeX =  (_width / 4);
        CGFloat nextStartX = _width - nextSizeX;
        CGFloat nextStartY = 0;
        nextStartY = _statusBarVisible  ? (nextStartY + kStatusBarOffset) : nextStartY;
        CGFloat nextSizeY = _height;

        UIFont *primaryFont = [UIFont systemFontOfSize:18.0 weight:UIFontWeightBold];
        NSDictionary *backAttrs = @{ NSFontAttributeName: primaryFont,
                                     NSForegroundColorAttributeName: [UIColor whiteColor] };
        if([self makeTextAccent:string]) {
            backAttrs = @{ NSFontAttributeName: [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold],
                           NSForegroundColorAttributeName: [UIColor whiteColor] };
        }
        if(_spinner) {
            [_spinner removeFromSuperview];
        }
        NSAttributedString *nextTitle = [[NSAttributedString alloc] initWithString:string attributes:backAttrs];
        __block HeaderView *blockSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [blockSelf setImage:nil forState:UIControlStateNormal];
            blockSelf.rightButton.frame = CGRectMake(nextStartX, nextStartY, nextSizeX, nextSizeY);
            [blockSelf.rightButton setAttributedTitle:nextTitle forState:UIControlStateNormal];
        });
    } else {
        [self setupRightButton:string];
    }
}


- (void)setRightButtonAttributedString:(NSAttributedString*)string {
    if (_rightButton) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_rightButton setAttributedTitle:string forState:UIControlStateNormal];
        });
    } else {
        [self setupAttributedRightButton:string];
    }
}

- (void)setLeftButtonImage:(UIImage*)image {
    if (_leftButton) {
        NSAttributedString *nextTitle = [[NSAttributedString alloc] initWithString:@"" attributes:nil];
        [_leftButton setAttributedTitle:nextTitle forState:UIControlStateNormal];
    } else {
        [self setupLeftButton:@""];
    }

    CGFloat backSizeX = (_width / 4);
    CGFloat backStartX = 0;
    CGFloat backStartY = 0;
    backStartY = _statusBarVisible  ? (backStartY + kStatusBarOffset) : backStartY;
    CGFloat backSizeY = _height;
    _leftButton.frame = CGRectMake(backStartX, backStartY, backSizeX, backSizeY);
        //    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_leftButton setImage:image forState:UIControlStateNormal];
    [_leftButton setTintColor:[UIColor whiteColor]];
    [_leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, kLeftRightPadding, 0, 0)];
}

- (void)setRightButtonImage:(UIImage*)image {
    if (_rightButton) {
        NSAttributedString *nextTitle = [[NSAttributedString alloc] initWithString:@"" attributes:nil];
        [_rightButton setAttributedTitle:nextTitle forState:UIControlStateNormal];
    } else {
        [self setupRightButton:@""];
    }

    if(_spinner) {
        [_spinner removeFromSuperview];
    }
    CGFloat nextSizeX =  (_width / 4);
    CGFloat nextStartX = _width - nextSizeX;
    CGFloat nextStartY = 0;
    nextStartY = _statusBarVisible  ? (nextStartY + kStatusBarOffset) : nextStartY;
    CGFloat nextSizeY = _height;
    _rightButton.frame = CGRectMake(nextStartX, nextStartY, nextSizeX, nextSizeY);

        //    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_rightButton setImage:image forState:UIControlStateNormal];
    [_rightButton setTintColor:[UIColor whiteColor]];
    [_rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, kLeftRightPadding)];
}


- (void)setRightButtonSpinner {
    if (_rightButton) {
        NSAttributedString *nextTitle = [[NSAttributedString alloc] initWithString:@"" attributes:nil];
        [_rightButton setAttributedTitle:nextTitle forState:UIControlStateNormal];
    } else {
        [self setupRightButton:@""];
    }
        // Right Button Layout
    CGFloat nextSizeX =  20;
    CGFloat nextSizeY = 20;
    CGFloat nextStartX = _width - nextSizeX - _leftRightPadding;
    CGFloat nextStartY = (_height / 2.0) - (nextSizeX / 2.0);
    nextStartY = _statusBarVisible  ? (nextStartY + kStatusBarOffset) : nextStartY;
    _rightButton.frame = CGRectMake(nextStartX, nextStartY, nextSizeX, nextSizeY);

    _spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,nextSizeY,nextSizeY)];
    _spinner.color = [UIColor whiteColor];
    [_spinner startAnimating];

    [_rightButton addSubview:_spinner];
}


#pragma mark - Remove left/right button for configuration

- (void)removeLeftButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_leftButton removeFromSuperview];
        [self setNeedsDisplay];
        [self setNeedsLayout];
    });
    _leftButton = nil;
}

- (void)removeRightButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_rightButton removeFromSuperview];
        [self setNeedsDisplay];
        [self setNeedsLayout];
    });
    _rightButton = nil;
}

#pragma mark - Event Listeners

- (void)onTitleTapped {
    if ([self.headerDelegate respondsToSelector:@selector(onHeaderTapped)]) {
        [self.headerDelegate onHeaderTapped];
    }
}

- (void)onLeftButtonTapped {
    if ([self.headerDelegate respondsToSelector:@selector(onLeftButtonTapped)]) {
        [self.headerDelegate onLeftButtonTapped];
    }
}

- (void)onRightButtonTapped {
    if ([self.headerDelegate respondsToSelector:@selector(onRightButtonTapped)]) {
        [self.headerDelegate onRightButtonTapped];
    }
}

#pragma mark - Helpers

- (BOOL)makeTextAccent:(NSString*)string {
    return NO;
}

- (void)invert:(float)percentage {
    if (percentage == 1.0) {
        [self setBackgroundColor:[UIColor clearColor]];
        _rightButton.alpha = 0.0;
        [_title setTextColor:[UIColor whiteColor]];
    } else {
        [self setBackgroundColor:[UIColor clearColor]];
        _rightButton.alpha = 1.0;
        [_title setTextColor:[UIColor whiteColor]];
    }
}

@end

