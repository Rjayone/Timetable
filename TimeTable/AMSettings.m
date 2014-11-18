//
//  AMSettings.m
//  TimeTable
//
//  Created by Admin on 23.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import "AMSettings.h"
#import "Utils.h"
#import <EventKit/EKAlarm.h>
#import <UIKit/UIKit.h>

static AMSettings* sSettings = nil;

@implementation AMSettings

//---------------------------------------------------------------------------------
+ (instancetype) currentSettings
{
    if(sSettings == nil)
    {
        sSettings = [[AMSettings alloc] init];
    }
    return sSettings;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSCalendar* calendar =[[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
        NSDateComponents* dayComps = [calendar components:(NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth) fromDate:[NSDate date]];
        _weekDay = dayComps.weekday-1;
        _weekOfMonth = dayComps.weekOfMonth-1;
        if(_weekOfMonth == 4) _weekOfMonth = 0;
        _notificationTimeInterval = 5;
        
        //NSLog(@"%ld", _weekOfMonth);
        [self readSettings];
    }
    return self;
}

#pragma mark - Save/Read block

//---------------------------------------------------------------------------------
- (void) saveSettings
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:_currentGroup forKey:kSettingGroup];
    [defaults setInteger:_currentWeek forKey:kSettingCurrentWeek];
    [defaults setInteger:_subgroup forKey:kSettingSubgroup];
    [defaults setBool:_holiday forKey:kSettingEnableOnHoliday];
    [defaults setBool:_colorize forKey:kSettingColorize];
    [defaults setBool:_pushNotification forKey:kPushNotificaation];
    [defaults setBool:_alarm forKey:kAlarm];
    [defaults synchronize];
}

//---------------------------------------------------------------------------------
- (void) readSettings
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    __unused NSNumber* currentWeek = [defaults valueForKey:kSettingCurrentWeek];
    NSNumber* subgroup = [defaults valueForKey:kSettingSubgroup];
    NSNumber* enableOnHoliday = [defaults valueForKey:kSettingEnableOnHoliday];
    NSNumber* colorize = [defaults valueForKey:kSettingColorize];
    NSNumber* notification = [defaults valueForKey:kPushNotificaation];
    NSNumber* alarm = [defaults valueForKey:kAlarm];
    
    _currentGroup = [defaults valueForKey:kSettingGroup];
    _currentWeek  = _weekOfMonth;
    _subgroup = subgroup.integerValue;
    _holiday  = enableOnHoliday.boolValue;
    _colorize = colorize.boolValue;
    _pushNotification = notification.boolValue;
    _alarm = alarm.boolValue;
}

#pragma mark - AMSetting setters

- (void) setCurrentGroup:(NSString *)currentGroup
{
    _currentGroup = currentGroup;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:currentGroup forKey:kSettingGroup];
    [defaults synchronize];
}

- (void) setCurrentWeek:(NSInteger)currentWeek
{
    _currentWeek = currentWeek;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:currentWeek forKey:kSettingCurrentWeek];
    [defaults synchronize];
}

- (void) setHoliday:(BOOL)holiday
{
    _holiday = holiday;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:holiday forKey:kSettingEnableOnHoliday];
    [defaults synchronize];
}

- (void) setSubgroup:(NSInteger)subgroup
{
    _subgroup = subgroup;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:subgroup forKey:kSettingSubgroup];
    [defaults synchronize];
}

- (void) setColorize:(BOOL)colorize
{
    _colorize = colorize;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:colorize forKey:kSettingColorize];
    [defaults synchronize];
}

- (void) setPushNotification:(BOOL)pushNotification
{
    _pushNotification = pushNotification;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:pushNotification forKey:kPushNotificaation];
    [defaults synchronize];
    
    //Если напоминания отключены то удаляем все напоминания
    if(pushNotification == false)
    {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

- (void) setAlarm:(BOOL)alarm;
{
    _alarm = alarm;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_alarm forKey:kAlarm];
    [defaults synchronize];
}

//=================================================================================================================
- (NSInteger) currentWeekDay
{
    NSCalendar* calendar =[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* dayComps = [calendar components:(NSCalendarUnitWeekday) fromDate:[NSDate date]];
    return dayComps.weekday - 1;
}


- (void) SetaNewAlarm:(NSString*) classStartTime;
{
    Utils* utils = [[Utils alloc] init];   
    NSCalendar* calendar =[[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents* alarmFireTime = [calendar components:(NSCalendarUnitWeekday | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:[NSDate date]];
    
    NSString* sFireTime = [utils timePeriodStart:classStartTime];
    alarmFireTime.minute = [[utils minuteFromTime:sFireTime] integerValue]+30;
    alarmFireTime.hour   = [[utils hourFromTime:sFireTime] integerValue]+1;
    alarmFireTime.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:3 * 60 * 60];
    NSDate* alarmFireDate = [calendar dateFromComponents:alarmFireTime];
    
    __unused EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:alarmFireDate];
}

@end
