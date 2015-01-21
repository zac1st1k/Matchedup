//
//  XZZMatchesViewController.m
//  Matchedup
//
//  Created by Zac on 17/01/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

#import "XZZMatchesViewController.h"
#import <Parse/Parse.h>
#import "XZZConstants.h"
#import "XZZChatViewController.h"

@interface XZZMatchesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *availableChatRooms;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation XZZMatchesViewController

#pragma mark - Lazy Instantiation

- (NSMutableArray *)availableChatRooms
{
    if (!_availableChatRooms) {
        _availableChatRooms = [[NSMutableArray alloc] init];
    }
    return _availableChatRooms;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.activityIndicator startAnimating];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.titleTextAttributes = nil;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    [self updateAvaliableChatRooms];
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
    XZZChatViewController *chatVC = segue.destinationViewController;
    NSIndexPath *indexPath = sender;
    chatVC.chatRoom = [self.availableChatRooms objectAtIndex:indexPath.row];
}

#pragma mark - Helper Methods

- (void)updateAvaliableChatRooms
{
    PFQuery *query = [PFQuery queryWithClassName:@"ChatRoom"];
    [query whereKey:@"user1" equalTo:[PFUser currentUser]];
    PFQuery *queryInverse = [PFQuery queryWithClassName:@"ChatRoom"];
    [query whereKey:@"user2" equalTo:[PFUser currentUser]];
    PFQuery *queryCombined = [PFQuery orQueryWithSubqueries:@[query, queryInverse]];
    [queryCombined includeKey:@"chat"];
    [queryCombined includeKey:@"user1"];//download complete object not only the pointer
    [queryCombined includeKey:@"user2"];
    [queryCombined findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.availableChatRooms removeAllObjects];
            self.availableChatRooms = [objects mutableCopy];
            [self.tableView reloadData];
        }
    }];
    NSLog(@"update chatrooms");
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.availableChatRooms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//    cell.imageView.image = [UIImage imageNamed:@"Chat_user.png"];
    PFObject *chatRoom = [self.availableChatRooms objectAtIndex:indexPath.row];
    PFUser *likedUser;
    PFUser *currentUser = [PFUser currentUser];
    PFUser *testUser1 = chatRoom[kXZZChatRoomUser1Key];
    if ([testUser1.objectId isEqual:currentUser.objectId]) {
        likedUser = [chatRoom objectForKey:kXZZChatRoomUser2Key];
    }
    else {
        likedUser = [chatRoom objectForKey:kXZZChatRoomUser1Key];
    }
    cell.textLabel.text = likedUser[@"profile"][@"firstName"];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    PFQuery *queryForPhoto = [[PFQuery alloc] initWithClassName:kXZZPhotoClassKey];
    [queryForPhoto whereKey:kXZZPhotoUserKey equalTo:likedUser];
    [queryForPhoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            NSLog(@"%@",objects);
            PFObject *photo = objects[0];
            NSLog(@"%@", photo);
            PFFile *pictureFile = photo[kXZZPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                cell.imageView.image = [UIImage imageWithData:data];
                cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            }];
//           [self.tableView reloadData];//Boost Parse API requests
        }
    }];
    NSLog(@"setup cell");
    self.activityIndicator.hidden = YES;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"matchesToChatSegue" sender:indexPath];
    NSLog(@"selected row at index %i", (int)indexPath.row);
}

@end
