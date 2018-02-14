//
//  NuxLandingViewController.h
//  theplug
//
//  Created by Timothy Lenardo on 2/14/18.
//  Copyright © 2018 Mango Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol NuxLandingDelegate <NSObject>

- (void)onLandingNextButtonPressed;

@end

@interface NuxLandingViewController : UIViewController

@property (assign, nonatomic) NSInteger index;
@property (nonatomic, strong) UIImageView *backgroundImage;


@property (nonatomic, readwrite, weak) id<NuxLandingDelegate> delegate;
@end

