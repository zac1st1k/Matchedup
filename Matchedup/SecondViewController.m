//
//  SecondViewController.m
//  Matchedup
//
//  Created by Zac on 11/01/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

#import "SecondViewController.h"
#import "XZZConstants.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>


@interface SecondViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    PFQuery *query = [PFQuery queryWithClassName:kXZZPhotoClassKey];
    [query whereKey:kXZZPhotoUserKey equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kXZZPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.profilePictureImageView.image = [UIImage imageWithData:data];
            }];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
