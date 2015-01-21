//
//  XZZProfileViewController.m
//  Matchedup
//
//  Created by Zac on 14/01/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

#import "XZZProfileViewController.h"
#import "XZZConstants.h"
#import <Parse/Parse.h>

@interface XZZProfileViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;

@end

@implementation XZZProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.titleTextAttributes = nil;
    PFFile *pictureFile = self.photo[kXZZPhotoPictureKey];
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.profilePictureImageView.image = [UIImage imageWithData:data];
    }];
    PFUser *user = self.photo[kXZZPhotoUserKey];
    self.locationLabel.text = user[kXZZUserProfileKey][kXZZUserProfileLocationKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", user[kXZZUserProfileKey][kXZZUserProfileAgeKey]];
    if (user[kXZZUserProfileKey][kXZZUserProfileRelationsihpStatusKey] == nil) {
        self.statusLabel.text = @"Single";
    }
    else {
        self.statusLabel.text = user[kXZZUserProfileKey][kXZZUserProfileRelationsihpStatusKey];
    }
    self.tagLineLabel.text = user[kXZZUserTagLineKey];
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    self.title = user[kXZZUserProfileKey][kXZZUserProfileFirstNameKey];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - IBAction

- (IBAction)likeButtonPressed:(UIButton *)sender
{
    [self.delegate didPressLike];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender
{
    [self.delegate didPressDislike];
}

@end
