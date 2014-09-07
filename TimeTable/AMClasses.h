//
//  AMClasses.h
//  TimeTable
//
//  Created by Admin on 20.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMClasses : NSObject

//Поля, необходимые для управления и вывода расписания
@property (strong, nonatomic) NSString* subject;
@property (strong, nonatomic) NSString* teacher;
@property (strong, nonatomic) NSString* timePeriod;
@property (strong, nonatomic) NSString* auditorium;
@property (assign, nonatomic) NSInteger subjectType;
@property (assign, nonatomic) NSInteger subgroup;
@property (assign, nonatomic) NSInteger weekDay;
@property (assign, nonatomic) NSInteger weekList;

- (instancetype) initWithDictionary:(NSDictionary*) dict;
- (NSString*) stringForNotification;
@end
