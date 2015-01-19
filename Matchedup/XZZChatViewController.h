//
//  XZZChatViewController.h
//  Matchedup
//
//  Created by Zac on 18/01/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

#import "JSMessagesViewController.h"
#import <Parse/Parse.h>

@interface XZZChatViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (strong, nonatomic) PFObject *chatRoom;

@end
