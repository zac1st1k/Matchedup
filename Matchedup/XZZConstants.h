//
//  XZZConstants.h
//  Matchedup
//
//  Created by Zac on 12/01/2015.
//  Copyright (c) 2015 1st1k. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XZZConstants : NSObject

#pragma mark - User Profile

extern NSString *const kXZZUserTagLineKey;

extern NSString *const kXZZUserProfileKey;
extern NSString *const kXZZUserProfileNameKey;
extern NSString *const kXZZUserProfileFirstNameKey;
extern NSString *const kXZZUserProfileLocationKey;
extern NSString *const kXZZUserProfileGenderKey;
extern NSString *const kXZZUserProfileBirthdayKey;
extern NSString *const kXZZUserProfileInterestedInKey;
extern NSString *const kXZZUserProfilePictureURLKey;
extern NSString *const kXZZUserProfileRelationsihpStatusKey;
extern NSString *const kXZZUserProfileAgeKey;

#pragma mark - Photo Class

extern NSString *const kXZZPhotoClassKey;
extern NSString *const kXZZPhotoUserKey;
extern NSString *const kXZZPhotoPictureKey;

#pragma mark - Activity Class

extern NSString *const KXZZActivityClassKey;
extern NSString *const KXZZActivityTypeKey;
extern NSString *const KXZZActivityFromUserKey;
extern NSString *const KXZZActivityToUserKey;
extern NSString *const KXZZActivityPhotoKey;
extern NSString *const KXZZActivityTypeLikeKey;
extern NSString *const KXZZActivityTypeDislikeKey;

#pragma mark - Settings

extern NSString *const kXZZMenEnabledKey;
extern NSString *const kXZZWomenEnabledKey;
extern NSString *const kXZZSingleEnabledKey;
extern NSString *const kXZZAgeMaxKey;

#pragma mark - ChatRoom

extern NSString *const kXZZChatRoomClassRoomKey;
extern NSString *const kXZZChatRoomUser1Key;
extern NSString *const kXZZChatRoomUser2Key;

#pragma mark - Chat

extern NSString *const kXZZChatClassKey;
extern NSString *const kXZZChatChatroomKey;
extern NSString *const kXZZChatFromUserKey;
extern NSString *const kXZZChatToUserKey;
extern NSString *const kXZZChatTextKey;

@end
