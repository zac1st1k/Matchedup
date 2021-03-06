//
//  XZZChatViewController.m
//  Matchedup
//
//  Created by Zac on 18/01/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

#import "XZZChatViewController.h"
#import <Parse/Parse.h>
#import "XZZConstants.h"

@interface XZZChatViewController ()

@property (strong, nonatomic) PFUser *withUser;
@property (strong, nonatomic) PFUser *currentUser;

@property (strong, nonatomic) NSTimer *chatTimer;
@property (nonatomic) BOOL initialLoadComplete;

@property (strong, nonatomic) NSMutableArray *chats;

@end

@implementation XZZChatViewController

- (NSMutableArray *)chats
{
    if (!_chats) {
        _chats = [[NSMutableArray alloc] init];
    }
    return _chats;
}

- (void)viewDidLoad {
    self.delegate = self;
    self.dataSource = self;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[JSBubbleView appearance] setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0f]];
    self.messageInputView.textView.placeHolder = @"New Message";
    [self setBackgroundColor:[UIColor whiteColor]];
    self.currentUser = [PFUser currentUser];
    PFUser *testUser1 = self.chatRoom[kXZZChatRoomUser1Key];
    if ([testUser1.objectId isEqual:self.currentUser.objectId]) {
        self.withUser = self.chatRoom[kXZZChatRoomUser2Key];
    }
    else {
        self.withUser = self.chatRoom[kXZZChatRoomUser1Key];
    }
    self.title = self.withUser[kXZZUserProfileKey][kXZZUserProfileFirstNameKey];
    self.initialLoadComplete = NO;
    [self checkForNewChats];
    self.chatTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForNewChats) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.titleTextAttributes = nil;
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

- (void)viewDidDisappear:(BOOL)animated
{
    [self.chatTimer invalidate];
    self.chatTimer = nil;
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chats count];
}

#pragma mark - TableView Delegate

- (void)didSendText:(NSString *)text
{
    if (text.length != 0) {
        PFObject *chat = [PFObject objectWithClassName:kXZZChatClassKey];
        [chat setObject:self.chatRoom forKey:kXZZChatChatroomKey];
        [chat setObject:self.currentUser forKey:kXZZChatFromUserKey];
        [chat setObject:self.withUser forKey:kXZZChatToUserKey];
        [chat setObject:text forKey:kXZZChatTextKey];
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.chats addObject:chat];
            [JSMessageSoundEffect playMessageSentSound];
            [self.tableView reloadData];
            [self finishSend];
            [self scrollToBottomAnimated:YES];
        }];
    }
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kXZZChatFromUserKey];
    if ([testFromUser.objectId isEqual:self.currentUser.objectId]) {
        return JSBubbleMessageTypeOutgoing;
    }
    else {
        return JSBubbleMessageTypeIncoming;
    }
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kXZZChatFromUserKey];
    if ([testFromUser.objectId isEqual:self.currentUser.objectId]) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleGreenColor]];
    }
    else {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleLightGrayColor]];

    }
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyAll;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyNone;
}

- (JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyNone;
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages View Data Source REQUIRED

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    NSString *message = chat[kXZZChatTextKey];
    return message;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Helper Methods

- (void)checkForNewChats
{
    int oldChatCount = (int)[self.chats count];
    PFQuery *queryForChats = [PFQuery queryWithClassName:kXZZChatClassKey];
    [queryForChats whereKey:kXZZChatChatroomKey equalTo:self.chatRoom];
    [queryForChats orderByAscending:@"createdAt"];
    [queryForChats findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (self.initialLoadComplete == NO || oldChatCount != [objects count]) {
                self.chats = [objects mutableCopy];
                [self.tableView reloadData];
                if (self.initialLoadComplete == YES) {
                    [JSMessageSoundEffect playMessageReceivedAlert];
                }
                self.initialLoadComplete = YES;
                [self scrollToBottomAnimated:YES];
            }
        }
    }];
}

@end