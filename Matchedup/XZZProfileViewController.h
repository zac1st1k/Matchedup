//
//  XZZProfileViewController.h
//  Matchedup
//
//  Created by Zac on 14/01/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol CCProfileViewControllerDelegate <NSObject>

- (void)didPressLike;
- (void)didPressDislike;

@end

@interface XZZProfileViewController : UIViewController

@property (strong, nonatomic) PFObject *photo;
@property (weak, nonatomic) id <CCProfileViewControllerDelegate> delegate;

@end
