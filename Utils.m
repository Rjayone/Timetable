//
//  Utils.m
//  TimeTable
//
//  Created by Admin on 26.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import "Utils.h"
#import "AMTableClasses.h"
#import "ViewController.h"
#import <UIKit/UIKit.h>

@implementation Utils

#pragma mark - Date And Time Methodes

- (NSString*) timePeriodStart:(NSString*) time
{
    NSRange range = [time rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
    if(range.length == 0)
        return time;
    range.length = range.location;
    range.location = 0;
    
    return [time substringWithRange:range];
}


- (NSString*) timePeriodEnd:(NSString*) time
{
    NSRange range = [time rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
    return [time substringFromIndex:range.location+1];
}

- (NSString*) minuteFromTime:(NSString*) time
{
    NSRange range = [time rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    return [time substringFromIndex:range.location+1];
}

- (NSString*) hourFromTime:(NSString*) time
{
    NSRange range = [time rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    range.length = range.location;
    range.location = 0;
    
    return [time substringWithRange:range];
}

- (NSString*) weekDayToString:(NSInteger) weekDay WithUppercase:(BOOL) uppercase
{
    switch (weekDay) {
        case eMonday:    if(uppercase) return @"Понедельник"; else return @"понедельник";
        case eTuesday:   if(uppercase) return @"Вторник"; else return @"вторник";
        case eWednesday: if(uppercase) return @"Среда"; else return @"среда";
        case eThursday:  if(uppercase) return @"Четверг"; else return @"четверг";
        case eFriday:    if(uppercase) return @"Пятница"; else return @"пятница";
        case eSaturday:  if(uppercase) return @"Суббота"; else return @"суббота";
        case eSunday:    if(uppercase) return @"Воскресение"; else return @"воскресение";
    }
    return nil;
}

- (NSString*) weekDayToString:(NSInteger) weekDay WithUppercase:(BOOL) uppercase AndCase:(BOOL) case_
{
    switch (weekDay) {
        case eMonday:    if(uppercase) return @"Понедельник"; else return @"понедельник";
        case eTuesday:   if(uppercase) return @"Вторник"; else return @"вторник";
        case eWednesday: if(uppercase) return @"Среду"; else return @"среду";
        case eThursday:  if(uppercase) return @"Четверг"; else return @"четверг";
        case eFriday:    if(uppercase) return @"Пятницу"; else return @"пятницу";
        case eSaturday:  if(uppercase) return @"Субботу"; else return @"субботу";
        case eSunday:    if(uppercase) return @"Воскресение"; else return @"воскресение";
    }
    return nil;
}

- (NSDate*) dateWithTime:(NSString*) time
{
    NSCalendar* calendar =[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* dateComp = [calendar components:(NSCalendarUnitWeekday | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:[NSDate date]];
    
    ///Проверить timeZone и отключить эту прибавку в 3 часа если нужно.
    dateComp.minute = [[self minuteFromTime:time] integerValue];
    dateComp.hour   = [[self hourFromTime:  time] integerValue];
    NSDate* classEndTimeDate = [calendar dateFromComponents:dateComp];
    
    return classEndTimeDate;
}

- (NSDateComponents*) dateComponentsWithTime:(NSString*) time
{
    NSCalendar* calendar =[[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents* dateComp = [calendar components:(NSCalendarUnitWeekday | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:[NSDate date]];
    
    ///Проверить timeZone и отключить эту прибавку в 3 часа если нужно.
    dateComp.minute = [[self minuteFromTime:time] integerValue];
    dateComp.hour   = [[self hourFromTime:  time] integerValue];
    return dateComp;
}


- (NSInteger) nowAreHoliday
{
    NSCalendar* calendar =[[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents* dateComp = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[NSDate date]];
    
    NSDateComponents *winterHolidayStart = [dateComp copy];
    NSDateComponents *winterHolidayEnd = [dateComp copy];
    NSDateComponents *summerHolidayStart = [dateComp copy];
    NSDateComponents *summerHolidayEnd = [dateComp copy];
    
    NSDateComponents *november7 = [dateComp copy];  november7.day = 7;   november7.month = 11;
    NSDateComponents *december25 = [dateComp copy]; december25.day = 25; december25.month = 12;
    NSDateComponents *march8 = [dateComp copy];     march8.day = 8;      march8.month = 3;
    NSDateComponents *april12 = [dateComp copy];    april12.day = 12;    april12.month = 4;
    NSDateComponents *april21 = [dateComp copy];    april21.day = 21;    april21.month = 4;
    NSDateComponents *may1 = [dateComp copy];       may1.day = 1;        may1.month = 5;
    NSDateComponents *may9 = [dateComp copy];       may9.day = 9;        may9.month = 5;
    
    //winter holiday
    winterHolidayStart.day = 1;
    winterHolidayStart.month = 1;
    winterHolidayEnd.day = 15;
    winterHolidayEnd.month = 2;
    
    //summer holiday
    summerHolidayStart.day = 3;
    summerHolidayStart.month = 6;
    summerHolidayEnd.day = 1;
    summerHolidayEnd.month = 9;
    
    if([[NSDate date] compare:[calendar dateFromComponents:winterHolidayStart]] == 1 &&
       [[NSDate date] compare:[calendar dateFromComponents:winterHolidayEnd]] == -1)
    {
        return eMessageTypeHoliday;
    }
    else if([[NSDate date] compare:[calendar dateFromComponents:summerHolidayStart]] == 1 &&
            [[NSDate date] compare:[calendar dateFromComponents:summerHolidayEnd]] == -1)
    {
        return eMessageTypeHoliday;
    }
    else if(dateComp == november7 || dateComp == december25 || dateComp == march8 || dateComp == april12 || dateComp == april21  || dateComp == may1 || dateComp == may9)
    {
        return eMessageTypeSunday;
    }
    
    return -1;
}

#pragma mark - Other

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    __unused UITouch *touch = [[event allTouches] anyObject];
}

//---------------------------------------------------------------------------------------------------------
- (void)intToBin:(int)theNumber
{
    NSMutableString *str = [NSMutableString string];
    NSInteger numberCopy = theNumber;
    for(NSInteger i = 0; i <= 11 ; i++)
    {
        [str insertString:((numberCopy & 1) ? @"1" : @"0") atIndex:0];
        numberCopy >>= 1;
    }
    NSLog(@"Binary version: %@", str);
}

#pragma mark - Alert defenition

- (void) showAlertWithCode:(NSInteger) code
{
    NSString* message;
    if( code == eAlertMessageSiteNotAvailabel) message = kAlertMessageSiteNotAvailabel;
    if( code == eAlarmMessageNetworkNotAvailabel) message = kAlarmMessageNetworkNotAvailabel;
    if( code == eAlarmMessageIncorrectGroup) message = kAlarmMessageIncorrectGroup;
    if( code == eAlarmMessageFieldsDoesntFilled) message = kAlarmMessageFieldsDoesntFilled;

    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:message delegate:nil cancelButtonTitle:@"Ок" otherButtonTitles: nil];
    [alert show];
}

- (BOOL) showWarningWithCode:(NSInteger) code
{
    NSString* message;
    if( code == eWarningMessageDeleteRow) message = kWarningMessageDeleteRow;
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Предупреждение" message:message delegate:nil cancelButtonTitle:@"Продолжить" otherButtonTitles: @"Отмена",nil];
    [alert show];
    return true;
}



@end
