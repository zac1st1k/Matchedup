//
//  XZZLoginViewController.m
//  Matchedup
//
//  Created by Zac on 11/01/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

#import "XZZLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "XZZConstants.h"

@interface XZZLoginViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation XZZLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.activityIndicator.hidden = YES;
    
    //    FBLoginView *loginView = [[FBLoginView alloc] init];
    //    loginView.center = self.view.center;
    //    [self.view addSubview:loginView];
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

- (IBAction)loginButtonPressed:(id)sender
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    NSArray *permissionsArray = @[@"user_about_me", @"user_interests", @"user_relationships", @"user_birthday", @"user_location", @"user_relationship_details"];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        if (!user) {
            if (!error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"The Facebook Login was Canceled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }
        else {
            [self updateUserInformation];
            [self performSegueWithIdentifier:@"loginToTabBarSegue" sender:self];
        }
    }];
}

#pragma mark - Helper Method

- (void)updateUserInformation
{
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//        NSLog(@"%@", result);
        if (!error) {
            NSDictionary *userDictionary = (NSDictionary *)result;
            
            //create URL
            NSString *facebookID = userDictionary[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resource=1",facebookID]];
            
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:8];
            if (userDictionary[@"name"]) {
                userProfile[kXZZUserProfileNameKey] = userDictionary[@"name"];
            }
            if (userDictionary[@"first_name"]) {
                userProfile[kXZZUserProfileFirstNameKey] = userDictionary[@"first_name"];
            }
            if (userDictionary[@"location"][@"name"]) {
                userProfile[kXZZUserProfileLocationKey] = userDictionary[@"location"][@"name"];
            }
            if (userDictionary[@"gender"]) {
                userProfile[kXZZUserProfileGenderKey] = userDictionary[@"gender"];
            }
            if (userDictionary[@"birthday"]) {
                userProfile[kXZZUserProfileBirthdayKey] = userDictionary[@"birthday"];
            }
            if (userDictionary[@"interested_in"]) {
                userProfile[kXZZUserProfileInterestedInKey] = userDictionary[@"interested_in"];
            }
            
            if ([pictureURL absoluteString]) {
                userProfile[kXZZUserPictureURL] = [pictureURL absoluteString];
            }
            
            [[PFUser currentUser] setObject:userProfile forKey:kXZZUserProfileKey];
            [[PFUser currentUser] saveInBackground];
        }
        else{
            NSLog(@"Error in FB request %@", error);
        }
    }];
}

@end
