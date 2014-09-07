//
//  AMTableClasses.m
//  TimeTable
//
//  Created by Admin on 19.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "CustomCells.h"
#import "AMTableClasses.h"
#import "AMXMLParserDelegate.h"
#import "AMSettingsView.h"
#import "Utils.h"

#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]


@implementation AMTableClasses

#pragma mark - Singleton implementation

//Основная переменная для хранения расписания
static AMTableClasses* sDefaultTable = nil;

+ (instancetype) defaultTable;
{
    @synchronized(self)
    {
        if (sDefaultTable == nil)
        {
            sDefaultTable = [[self alloc ]init];
        }
    }
    return sDefaultTable;
}

//---------------------------------------------------------------------------------------------------------
- (instancetype)init
{
    self = [super init];
    if (self) {
        _classes = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma  mark - Classes implementation

//---------------------------------------------------------------------------------------------------------
- (void) AddClasses:(AMClasses*) subject;
{
    [_classes addObject:subject];
}

//---------------------------------------------------------------------------------------------------------
- (NSArray*) GetCurrentDayClasses
{
    AMSettings* settings = [AMSettings currentSettings];
    NSInteger weekDay = [settings currentWeekDay];
    NSMutableArray* currentClasses = [[NSMutableArray alloc] init];
    for(AMClasses* i in _classes)
    {
        //1. Если день недели предмета == текущему дню недели
        //2. Список недели содержит текущую неделю
        if(i.weekList & [self weekToBitField:settings.currentWeek+1] || (i.weekList == 0 && i.weekDay == weekDay))
        {
            if((i.subgroup == settings.subgroup || i.subgroup == 0) && i.weekDay == weekDay)
                [currentClasses addObject:i];
        }
    }
    return currentClasses;
}

//day - значения из EDays
//---------------------------------------------------------------------------------------------------------
- (NSMutableArray*) GetClassesByDay:(NSInteger) day
{
    AMSettings* settings = [AMSettings currentSettings];
    NSMutableArray* currentDayClasses = [[NSMutableArray alloc]init];
    for(AMClasses* class in _classes)
    {
        if(class.weekDay == day)
        {
            if(class.weekList & [self weekToBitField:settings.currentWeek+1] || (class.weekList == 0))
            {
                //NSLog(@"subgroup %ld", settings.subgroup);
                if(class.subgroup == settings.subgroup+1 || class.subgroup == 0)
                    [currentDayClasses addObject:class];
            }
        }
    }
    return currentDayClasses;
}

//---------------------------------------------------------------------------------------------------------
- (void) SaveUserData
{
    NSString *docPath  = [DOCUMENTS stringByAppendingPathComponent:@"UserClasses.plist"];
    NSMutableArray* items = [[NSMutableArray alloc] init];
    for(AMClasses* classes in _classes)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSNumber* subjectType = [[NSNumber alloc] initWithInteger:classes.subjectType];
        NSNumber* subgroup = [[NSNumber alloc]    initWithInteger:classes.subgroup];
        NSNumber* weekDay = [[NSNumber alloc]     initWithInteger:classes.weekDay];
        NSNumber* weekList = [[NSNumber alloc]    initWithInteger:classes.weekList];
        
        [dict setObject: classes.subject     forKey:kSubject];
        [dict setObject: classes.teacher     forKey:kTeacher];
        [dict setObject: classes.timePeriod  forKey:kTimePeriod];
        [dict setObject: classes.auditorium  forKey:kAuditorium];
        [dict setObject: subjectType         forKey:kSubjectType];
        [dict setObject: subgroup            forKey:kSubgroup];
        [dict setObject: weekDay             forKey:kWeekDay];
        [dict setObject: weekList            forKey:kWeekList];
        [items addObject: dict];
    }
    [items writeToFile:docPath atomically:YES];
}

//---------------------------------------------------------------------------------------------------------
- (BOOL) ReadUserData
{
    NSString *filePath = [DOCUMENTS stringByAppendingPathComponent:@"UserClasses.plist"];
    NSMutableArray* userDataArray = [[NSMutableArray alloc] initWithContentsOfFile: filePath];
    
    [_classes removeAllObjects];
    for(int i = 0; i < userDataArray.count; i++)
    {
        AMClasses* class = [[AMClasses alloc] initWithDictionary:[userDataArray objectAtIndex: i]];
        [self AddClasses:class];
    }
    return true;
}

//---------------------------------------------------------------------------------------------------------
- (NSInteger) weekToBitField:(NSInteger) week
{
    NSInteger flag = 0;
    switch (week) {
        case 1: flag = eFirstWeek;  break;
        case 2: flag = eSecondWeek; break;
        case 3: flag = eThirdWeek;  break;
        case 4: flag = eFourthWeek; break;
        default: break;
    }
    return flag;
}

//Возврашает цвет по типу предмета
- (UIColor*) colorByClassType:(NSInteger) classType
{
    if(classType == eClassType_Lab)
        return COLOR_Lab;
    if(classType == eClassType_Practical)
        return COLOR_Prac;
    if(classType == eClassType_Lecture)
        return COLOR_Lec;
    return COLOR_Lab;
}

//------------------------------------------------------------------------------------------------------------------------
- (void) parse:(NSString*) group
{  
    [_classes removeAllObjects];
    NSURL* tableURL     = [NSURL URLWithString:[@"http://www.bsuir.by/psched/rest/" stringByAppendingString:group]];
//    if(![tableURL checkResourceIsReachableAndReturnError:nil])
//    {
//        [utils showAlertWithCode: eAlarmMessageNetworkNotAvailabel];
//        return;
//    }
    NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:tableURL];
    AMXMLParserDelegate* delegate = [[AMXMLParserDelegate alloc] init];
    parser.delegate = delegate;
    [parser parse];
    while (!delegate.done)
        sleep(1);
    
    [self SaveUserData];
    NSNotificationCenter* notification = [NSNotificationCenter defaultCenter];
    [notification postNotificationName:@"TimeTableShouldUpdate" object:nil];
}

//Возвращает количество занятий в текущий день с учетом подгруппы и недели
- (NSInteger) currentWeekDayClassesCount:(NSInteger) weekDay
{
    NSInteger counter = 0;
    AMSettings* settings = [AMSettings currentSettings];
    for(AMClasses* class in _classes)
    {
        if(class.weekDay == weekDay) //пн - 1, вт - 2
        {
            if(class.weekList & [self weekToBitField:settings.currentWeek+1] || class.weekList == 0)
            {
                if(class.subgroup == settings.subgroup+1 || class.subgroup == 0)
                {
                    counter++;
                }
            }
        }
    }
    return counter;
}

@end
