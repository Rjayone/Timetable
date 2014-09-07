//
//  AMSettings.h
//  TimeTable
//
//  Created by Admin on 23.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* kSettingGroup = @"CurrentGroup";
static NSString* kSettingCurrentWeek = @"CurrentWeek";
static NSString* kSettingSubgroup = @"Subgroup";
static NSString* kSettingEnableOnHoliday = @"EnableOnHoliday";
static NSString* kSettingWeekDay = @"WeekDay";
static NSString* kSettingColorize = @"Colorize";
static NSString* kPushNotificaation = @"pushNotification";
static NSString* kAlarm = @"Alarm";
static NSString* kWeekOfMonth = @"WeekOfMonth";

#pragma mark - Settings

@interface AMSettings : NSObject

@property (strong, nonatomic) NSString* currentGroup;
@property (assign, nonatomic) NSInteger currentWeek;
@property (assign, nonatomic) NSInteger subgroup;
@property (assign, nonatomic) BOOL holiday;
@property (assign, nonatomic) BOOL colorize;
@property (assign, nonatomic) NSInteger weekDay;
@property (assign, nonatomic) NSInteger weekOfMonth;

//Уведомления
@property (assign, nonatomic) BOOL pushNotification;
@property (assign, nonatomic) NSInteger notificationTimeInterval;
@property (assign, nonatomic) BOOL alarm;

+ (instancetype) currentSettings;
- (void) saveSettings;
- (void) readSettings;
- (NSInteger) currentWeekDay;
@end
