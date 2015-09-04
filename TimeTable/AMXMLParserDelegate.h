//
//  AMXMLParserDelegate.h
//  TimeTable
//
//  Created by Admin on 19.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//
#pragma once
#import <Foundation/Foundation.h>

static NSString* kAuditorium    = @"auditory";
static NSString* kSubject       = @"subject";
static NSString* kSubjectType   = @"lessonType";
static NSString* kTeacher       = @"teacher";

static NSString* kTimePeriod    = @"lessonTime";

static NSString* kWeekDay       = @"weekDay";
static NSString* kWeekList      = @"weekNumber";
static NSString* kSubgroup      = @"numSubgroup";
static NSString* kFirstName     = @"firstName";
static NSString* kMiddleName    = @"middleName";
static NSString* kLastName      = @"lastName";

static NSString* kBegin          = @"schedule";


/*
 <employee>
 <academicDepartment>ЭИ</academicDepartment>
 <firstName>Валентина</firstName>
 <id>504515</id>
 <lastName>Ярмольчик</lastName>
 <middleName>Викторовна</middleName>
 </employee>
 <lessonTime>11:40-13:15</lessonTime>
 <lessonType>ЛР</lessonType>
 <note/>
 <numSubgroup>0</numSubgroup>
 <studentGroup>272302</studentGroup>
 <subject>СИТ</subject>
 <weekNumber>2</weekNumber>
 <weekNumber>4</weekNumber>
 */

typedef NS_ENUM(NSUInteger, EXMLReadFieldStatus) {
    e_ReadFileStatusNULL,
    e_ReadFieldStatusAuditory,
    e_ReadFieldStatusEmployee,
    e_ReadFieldStatusEmployeeFN,
    e_ReadFieldStatusEmployeeMN,
    e_ReadFieldStatusEmployeeLN,
    e_ReadFieldStatusLessonTime,
    e_ReadFieldStatusLessonType,
    e_ReadFieldStatusSubgroup,
    e_ReadFieldStatusSubject,
    e_ReadFieldStatusWeekNumber,
    e_ReadFieldStatusWeekDay
};


@protocol AMTimetableParserDelegate <NSObject>
- (void)parserDidSuccessfullFinished;
- (void)parserDidFinishedWithError;
@end


@interface AMXMLParserDelegate : NSObject<NSXMLParserDelegate>
@property (weak, nonatomic) id<AMTimetableParserDelegate> delegate;

@end
