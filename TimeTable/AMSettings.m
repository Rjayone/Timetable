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

//Значение дня года первого сентября
- (const NSInteger) firstSeptemberDayOfYear
{
    NSCalendar* calendar =[[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents* dateComp = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[NSDate date]];
    NSDateComponents *firstSeptemberDC = [dateComp copy];  firstSeptemberDC.day = 1;   firstSeptemberDC.month = 9;
    NSDate* firstSeptember = [calendar dateFromComponents:firstSeptemberDC];
    return [calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:firstSeptember];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _friendGroup = @"unselected";
        _groupSet = [NSMutableArray new];
        NSCalendar* calendar =[[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
        NSDateComponents* dayComps = [calendar components:(NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekdayOrdinal) fromDate:[NSDate date]];
        _weekDay = dayComps.weekday-1;
        ////////////////////////////////////////////////
        //Это день года, то есть 1 января 2014 -  1 день
        //1 декабря 2014 - 335
        NSUInteger currentDayOfYear = [calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:[NSDate date]];
        NSInteger firstSeptemberDayOfYear = [self firstSeptemberDayOfYear];
        NSInteger deltaDay = currentDayOfYear - firstSeptemberDayOfYear;
        
       
        if(deltaDay >= 0)
        {
            _weekOfMonth = ((deltaDay / 7) % 4);
        }
        else
        {
            _weekOfMonth = (((deltaDay + 365) / 7) % 4);
        }
        _notificationTimeInterval = 5;
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
    [defaults setObject:@(_currentGroupId) forKey:kSettingGroupId];
    [defaults setObject:_groupSet forKey:kGroupSet];
    [defaults setInteger:_currentWeek forKey:kSettingCurrentWeek];
    [defaults setInteger:_subgroup forKey:kSettingSubgroup];
    [defaults setBool:_holiday forKey:kSettingEnableOnHoliday];
    [defaults setBool:_colorize forKey:kSettingColorize];
    [defaults setBool:_extramural forKey:kExtramural];
    [defaults setBool:_pushNotification forKey:kPushNotificaation];
    [defaults setBool:_alarm forKey:kAlarm];
    [defaults synchronize];
}

//---------------------------------------------------------------------------------
- (void) readSettings
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* currentGroupId = [defaults valueForKey:kSettingGroupId];
    __unused NSNumber* currentWeek = [defaults valueForKey:kSettingCurrentWeek];
    NSNumber* subgroup = [defaults valueForKey:kSettingSubgroup];
    NSNumber* enableOnHoliday = [defaults valueForKey:kSettingEnableOnHoliday];
    NSNumber* colorize = [defaults valueForKey:kSettingColorize];
    NSNumber* extramural = [defaults valueForKey:kExtramural];
    NSNumber* notification = [defaults valueForKey:kPushNotificaation];
    NSNumber* alarm = [defaults valueForKey:kAlarm];
    
    _currentGroup = [defaults valueForKey:kSettingGroup];
    _currentGroupId = [currentGroupId integerValue];
    _currentWeek  = _weekOfMonth;
    _subgroup = subgroup.integerValue;
    _holiday  = enableOnHoliday.boolValue;
    _colorize = colorize.boolValue;
    _extramural = extramural.boolValue;
    _pushNotification = notification.boolValue;
    _alarm = alarm.boolValue;
    if([defaults valueForKey:kGroupSet] == NULL) return;
        _groupSet = [(NSMutableArray*)[defaults valueForKey:kGroupSet] mutableCopy];
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

- (void)setExtramural:(BOOL)extramural {
    _extramural = extramural;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:extramural forKey:kExtramural];
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
