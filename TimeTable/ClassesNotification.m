//
//  ClassesNotification.m
//  TimeTable
//
//  Created by Admin on 27.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassesNotification.h"
#import "Utils.h"
#import "AMClasses.h"
#import "AMSettings.h"


@implementation ClassesNotification

//------------------------------------------------------------------------------------------------------------------------
- (void) registerNotificationForToday:(NSArray*) classes
{
    Utils* utils = [[Utils alloc] init];
    
    //Если на сегодня заданы напоминания то проверим попадает ли время запуска приложения на момент занятий
    if(classes.count < 1)
        return;
    
    if([self notificationDidSetToday])
    {
        ///Например если пары начались в 8:00, а мы закгрузились в 11:40 и расписание не установелно
        NSDate* currentDate = [NSDate date];
        for(int i = 0; i < classes.count-1; i++)
        {
            AMClasses* currentClass = [classes objectAtIndex:i];
            AMClasses* notifClass   = [classes objectAtIndex:i+1];
            NSString* sClassTimeEnd = [utils timePeriodEnd:currentClass.timePeriod];
            NSDate* classEndDate = [utils dateWithTime:sClassTimeEnd];
            
            if(![currentDate compare:classEndDate] || [currentDate compare:classEndDate] == -1)
            {
                [self setNotificationForSubject:notifClass AtTime:sClassTimeEnd];
            }
        }
        [self saveNotifications];
    }
    else //Если на сегодня напоминания не установлены
    {
        //Установим напоминания для первой пары, так как оно устанавливается по времени начала пары, а не по окончанию
        AMClasses* firstClass = [classes objectAtIndex:0];
        [self setNotificationForSubject:firstClass AtTime:[utils timePeriodStart:firstClass.timePeriod]];
        if(classes.count > 1)
        {
            for(int i = 1; i < classes.count - 1; i++)
            {
                AMClasses* currentClass = [classes objectAtIndex:i];
                AMClasses* notifClass   = [classes objectAtIndex:i+1];
                NSString* sClassTimeEnd = [utils timePeriodEnd:currentClass.timePeriod];
                [self setNotificationForSubject:notifClass AtTime:sClassTimeEnd];
            }
            [self saveNotifications];
        }
    }
}

//------------------------------------------------------------------------------------------------------------------------
- (void) setNotificationForSubject:(AMClasses*) class AtTime:(NSString*) time
{
    Utils* utils = [[Utils alloc] init];
    AMSettings* settings = [AMSettings currentSettings];
    NSCalendar* calendar =[[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents* classStartDateComp = [utils dateComponentsWithTime:time];
    classStartDateComp.minute -= settings.notificationTimeInterval;
    NSDate* notificationDate = [calendar dateFromComponents:classStartDateComp];
    
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = notificationDate;
    localNotification.alertBody = [class stringForNotification];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    NSLog(@"Notification for %@ was created", class.subject);
}

//------------------------------------------------------------------------------------------------------------------------
- (void) setNotificationForClasses:(NSArray*) classes
{
    __unused Utils* utils = [[Utils alloc] init];
    __unused AMSettings* settings = [AMSettings currentSettings];
}

//------------------------------------------------------------------------------------------------------------------------
- (void) saveNotifications
{
    NSCalendar* calendar =[[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents* dateComp = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth) fromDate:[NSDate date]];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:dateComp.day forKey:kNotificationSetDateDay];
    [defaults setInteger:dateComp.month forKey:kNotificationSetDateMonth];
    [defaults synchronize];
}

//------------------------------------------------------------------------------------------------------------------------
- (NSDateComponents*) readNotifications
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* day = [defaults valueForKey:kNotificationSetDateDay];
    NSNumber* month = [defaults valueForKey:kNotificationSetDateMonth];
    
    NSCalendar* calendar =[[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents* dateComp = [calendar components:(NSCalendarUnitYear) fromDate:[NSDate date]];
    dateComp.day = day.integerValue;
    dateComp.month = month.integerValue;
    
    return dateComp;
}

//------------------------------------------------------------------------------------------------------------------------
- (BOOL) notificationDidSetToday
{
    NSDateComponents* notificationSaveDateComp = [self readNotifications];
    NSCalendar* calendar =[[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents* dateComp = [calendar components:(NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    
    if(notificationSaveDateComp.month == dateComp.month && notificationSaveDateComp.day == dateComp.day)
        return YES;
    return NO;
}

//------------------------------------------------------------------------------------------------------------------------
- (BOOL) canSetNewNotification:(AMClasses*) class
{
    return false;
}

@end
