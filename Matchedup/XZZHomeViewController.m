//
//  XZZHomeViewController.m
//  Matchedup
//
//  Created by Zac on 14/01/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

#import "XZZHomeViewController.h"
#import <Parse/Parse.h>
#import "XZZConstants.h"
#import "XZZTestUser.h"
#import "XZZProfileViewController.h"

@interface XZZHomeViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender;
- (IBAction)settingsBarButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)likeButtonPressed:(UIButton *)sender;
- (IBAction)infoButtonPressed:(UIButton *)sender;
- (IBAction)dislikeButtonPressed:(UIButton *)sender;

@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) PFObject *photo;
@property (strong, nonatomic) NSMutableArray *activities;
@property (nonatomic) int currentPhotoIndex;
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDislikedByCurrentUser;

@end

@implementation XZZHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    [XZZTestUser saveTestUserToParse];
    [self.activityIndicator startAnimating];
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    self.currentPhotoIndex = 0;
    PFQuery *query = [PFQuery queryWithClassName:kXZZPhotoClassKey];
    [query whereKey:kXZZPhotoUserKey notEqualTo:[PFUser currentUser]];
    [query includeKey:kXZZPhotoUserKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.photos = objects;
            [self queryForCurrentPhotoIndex];
            self.activityIndicator.hidden = YES;
        }
        else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"homeToProfileSegue"]) {
        XZZProfileViewController *nextViewController = segue.destinationViewController;
        nextViewController.photo = self.photo;
    }
}

#pragma mark - IBActions

- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender {
}

- (IBAction)settingsBarButtonPressed:(UIBarButtonItem *)sender {
}

- (IBAction)likeButtonPressed:(UIButton *)sender {
    [self checkLike];
}

- (IBAction)infoButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"homeToProfileSegue" sender:nil];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    [self checkDislike];
}

#pragma mark - Helper Methods

- (void)queryForCurrentPhotoIndex
{
    if ([self.photos count] > 0) {
        self.photo = self.photos[self.currentPhotoIndex];
        PFFile *file = self.photo[kXZZPhotoPictureKey];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                self.photoImageView.image = image;
                [self updateView];
            }
            else NSLog(@"%@", error);
        }];
        PFQuery *queryForLike = [PFQuery queryWithClassName:KXZZActivityClassKey];
        [queryForLike whereKey:KXZZActivityTypeKey equalTo:KXZZActivityTypeLikeKey];
        [queryForLike whereKey:KXZZActivityPhotoKey equalTo:self.photo];
        [queryForLike whereKey:KXZZActivityFromUserKey equalTo:[PFUser currentUser]];
        PFQuery *queryForDislike = [PFQuery queryWithClassName:KXZZActivityClassKey];
        [queryForDislike whereKey:KXZZActivityTypeKey equalTo:KXZZActivityTypeDislikeKey];
        [queryForDislike whereKey:KXZZActivityPhotoKey equalTo:self.photo];
        [queryForDislike whereKey:KXZZActivityFromUserKey equalTo:[PFUser currentUser]];
        PFQuery *likeAndDislikeQuery = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDislike]];
        [likeAndDislikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error){
                self.activities = [objects mutableCopy];
                if ([self.activities count] == 0) {
                    self.isLikedByCurrentUser = NO;
                    self.isDislikedByCurrentUser = NO;
                }
                else {
                    PFObject *activity = self.activities[0];
                    if ([activity[KXZZActivityTypeKey] isEqualToString:KXZZActivityTypeLikeKey]) {
                        self.isLikedByCurrentUser = YES;
                        self.isDislikedByCurrentUser = NO;
                    }
                    else if ([activity[KXZZActivityTypeKey] isEqualToString:KXZZActivityTypeDislikeKey]){
                        self.isLikedByCurrentUser = NO;
                        self.isDislikedByCurrentUser = YES;
                    }
                    else{
                        //Some other type of activity
                    }
                }
                self.likeButton.enabled = YES;
                self.dislikeButton.enabled = YES;
                self.infoButton.enabled = YES;
            }
        }];
    }
}

-(void)updateView
{
    NSLog(@"photos are %@", self.photo);
    NSLog(@"photos are %@", self.photo[@"user"]);
    NSLog(@"photos are %@", self.photo[@"user"][@"profile"]);
    self.firstNameLabel.text = self.photo[kXZZPhotoUserKey][kXZZUserProfileKey][kXZZUserProfileFirstNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[kXZZPhotoUserKey][kXZZUserProfileKey][kXZZUserProfileAgeKey]];
    self.tagLineLabel.text = self.photo[kXZZPhotoUserKey][kXZZUserTagLineKey];
}

- (void)setupNextPhoto
{
    if (self.currentPhotoIndex + 1 <self.photos.count) {
        self.currentPhotoIndex ++;
        [self queryForCurrentPhotoIndex];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No more Users to View" message:@"Check Back Later for more People!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)saveLike
{
    PFObject *likeActivity = [PFObject objectWithClassName:KXZZActivityClassKey];
    [likeActivity setObject:KXZZActivityTypeLikeKey forKey:KXZZActivityTypeKey];
    [likeActivity setObject:[PFUser currentUser] forKey:KXZZActivityFromUserKey];
    [likeActivity setObject:[self.photo objectForKey:kXZZPhotoUserKey] forKey:KXZZActivityToUserKey];
    [likeActivity setObject:self.photo forKey:KXZZActivityPhotoKey];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = YES;
        self.isDislikedByCurrentUser = NO;
        [self.activities addObject:likeActivity];
        [self setupNextPhoto];
    }];
}

- (void)saveDislike
{
    PFObject *dislikeActivity = [PFObject objectWithClassName:KXZZActivityClassKey];
    [dislikeActivity setObject:KXZZActivityTypeDislikeKey forKey:KXZZActivityTypeKey];
    [dislikeActivity setObject:[PFUser currentUser] forKey:KXZZActivityFromUserKey];
    [dislikeActivity setObject:[self.photo objectForKey:kXZZPhotoUserKey] forKey:KXZZActivityToUserKey];
    [dislikeActivity setObject:self.photo forKey:KXZZActivityPhotoKey];
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = NO;
        self.isDislikedByCurrentUser = YES;
        [self.activities addObject:dislikeActivity];
        [self setupNextPhoto];
    }];
}

- (void)checkLike
{
    if (self.isLikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    }
    else if (self.isDislikedByCurrentUser){
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveLike];
    }
    else {
        [self saveLike];
    }
}
- (void)checkDislike
{
    if (self.isDislikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    }
    else if (self.isLikedByCurrentUser){
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveDislike];
    }
    else {
        [self saveDislike];
    }
}

@end
