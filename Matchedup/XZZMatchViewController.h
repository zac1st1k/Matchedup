//
//  XZZMatchViewController.h
//  Matchedup
//
//  Created by Zac on 17/01/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XZZMatchViewControllerDelegate <NSObject>

- (void)presentMatchesViewController;

@end

@interface XZZMatchViewController : UIViewController

@property (strong, nonatomic) UIImage *matchedUserImage;
@property (weak) id <XZZMatchViewControllerDelegate> delegate;

@end
