//
//  XZZTestUser.m
//  Matchedup
//
//  Created by Zac on 17/01/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

#import "XZZTestUser.h"
#import <Parse/Parse.h>
#import "XZZConstants.h"

@implementation XZZTestUser

+ (void)saveTestUserToParse
{
    PFUser *newUser = [PFUser user];
    newUser.username = @"user1";
    newUser.password = @"password1";
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSDictionary *profile = @{@"age":@28, @"birthday":@"11/12/1985", @"firstName":@"Julie", @"gender":@"femail", @"location":@"Berlin, Germany", @"name":@"Julie Adams"};
            [newUser setObject:profile forKey:@"profile"];
            [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                UIImage *profileImage = [UIImage imageNamed:@"faye.png"];
                NSData *imageData = UIImagePNGRepresentation(profileImage);
                PFFile *photoFile = [PFFile fileWithData:imageData];
                [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded){
                        PFObject *photo = [PFObject objectWithClassName:kXZZPhotoClassKey];
                        [photo setObject:newUser forKey:kXZZPhotoUserKey];
                        [photo setObject:photoFile forKey:kXZZPhotoPictureKey];
                        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            NSLog(@"Photo saved successfully");
                        }];
                    }
                }];
            }];
        }
    }];
}

@end
