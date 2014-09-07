//
//  AMClasses.m
//  TimeTable
//
//  Created by Admin on 20.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import "AMClasses.h"
#import "AMXMLParserDelegate.h"
#import "Utils.h"
#import "AMTableClasses.h"

@implementation AMClasses

- (NSString *)description
{
    return [NSString stringWithFormat:@"Subject: %@\nTeacher: %@\nTimePeriod: %@\nAuditorium: %@\nSubjectType: %ld\nSubgroup: %ld\nWeekDay: %ld\nWeekList: %ld", _subject, _teacher, _timePeriod, _auditorium, (long)_subjectType, (long)_subgroup, (long)_weekDay, (long)_weekList];
}

- (instancetype) initWithDictionary:(NSDictionary*) dict
{
    AMClasses* class = [[AMClasses alloc] init];
    NSNumber* subjectType = [dict valueForKey:kSubjectType];
    NSNumber* subgroup =    [dict valueForKey:kSubgroup];
    NSNumber* weekDay =     [dict valueForKey:kWeekDay];
    NSNumber* weekList =    [dict valueForKey:kWeekList];
    
    class.subject     = [dict valueForKey: kSubject];
    class.teacher     = [dict valueForKey: kTeacher];
    class.timePeriod  = [dict valueForKey: kTimePeriod];
    class.auditorium  = [dict valueForKey: kAuditorium];
    class.subjectType = subjectType.integerValue;
    class.subgroup    = subgroup.integerValue;
    class.weekDay     = weekDay.integerValue;
    class.weekList    = weekList.integerValue;
    
    return class;
}


- (NSString*) stringForNotification
{
    NSString* string = @"Следующая пара: ";
    NSString* subject = _subject;
    NSString* type;
    NSString* startTime = [[Utils alloc] timePeriodStart:_timePeriod];
    if(_subjectType == eClassType_Lab) type = @", ЛР. ";
    if(_subjectType == eClassType_Lecture) type = @", ЛК. ";
    if(_subjectType == eClassType_Practical) type = @", ПЗ. ";
    if([_subject isEqualToString:@"ФК-ЗОЖ СПИДиН"])
    {
        return [@"Следующая пара: Физ-ра. Начало в " stringByAppendingString:startTime];
    }
    
    
    string = [[[[string stringByAppendingString:subject] stringByAppendingString:type]stringByAppendingString:@"Аудитория "]stringByAppendingString:_auditorium];
    string = [[[string stringByAppendingString:@", начало в "] stringByAppendingString:startTime] stringByAppendingString:@"."];
    return string;
}
@end
