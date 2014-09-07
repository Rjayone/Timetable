//
//  AMXMLParserDelegate.h
//  TimeTable
//
//  Created by Admin on 19.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//
#pragma once
#import <Foundation/Foundation.h>

static NSString* kSubject       = @"subject";
static NSString* kSubjectType   = @"subjectType";
static NSString* kAuditorium    = @"auditorium";
static NSString* kTeacher       = @"teacher";
static NSString* kTimePeriod    = @"timePeriod";
static NSString* kWeekDay       = @"weekDay";
static NSString* kWeekList      = @"weekList";
static NSString* kSubgroup      = @"subgroup";



@interface AMXMLParserDelegate : NSObject<NSXMLParserDelegate>
@property (readonly, nonatomic, assign) BOOL done;
@end
