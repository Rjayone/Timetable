//
//  ClassesNotification.h
//  TimeTable
//
//  Created by Admin on 27.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMClasses;

static NSString* kNotificationSetDateDay = @"NotificationSetDateDay";
static NSString* kNotificationSetDateMonth = @"NotificationSetDateMonth";

@interface ClassesNotification : NSObject

- (void) registerNotificationForToday:(NSArray*) classes;
- (void) setNotificationForSubject:(AMClasses*) class AtTime:(NSString*) time;
- (void) setNotificationForClasses:(NSArray*) classes;
- (void) saveNotifications;
- (BOOL) notificationDidSetToday;

@end
