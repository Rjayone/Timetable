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
#import "AMClasses.h"
#import "AMXMLParserDelegate.h"
#import "AMSettingsView.h"
#import "Utils.h"

#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@interface AMTableClasses () <AMTimetableParserDelegate>

@end


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
        _classesSet = [[NSMutableSet alloc] init];
        _timesArray = [[NSMutableArray alloc]init];
    }
    return self;
}

#pragma  mark - Classes implementation

//---------------------------------------------------------------------------------------------------------
- (void) AddClasses:(AMClasses*) subject;
{
    [_classes addObject:subject];
    [_classesSet addObject:subject.subject];
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
                if(class.subgroup == settings.subgroup || class.subgroup == 0)
                    [currentDayClasses addObject:class];
            }
        }
    }
    return currentDayClasses;
}


- (AMClasses*) getCurrentClass
{
    ///todo: Во время перерыва вывести время до начала пары
    Utils* utils = [Utils new];
    NSDate* date = [NSDate date];
    AMSettings* settings = [AMSettings currentSettings];
    NSInteger day = [settings currentWeekDay];
    
    for(AMClasses* class in _classes)
    {
        NSDate* classDateBegin = [utils dateWithTime:[utils timePeriodStart:class.timePeriod]];
        NSDate* classDateEnd   = [utils dateWithTime:[utils timePeriodEnd:class.timePeriod]];
        if(class.weekDay == day)
        {
            if(class.weekList & [self weekToBitField:settings.currentWeek+1] || (class.weekList == 0))
            {

                if(([date compare:classDateBegin] == NSOrderedSame || [date compare:classDateBegin] == NSOrderedDescending) &&
                   [date compare:classDateEnd] == NSOrderedAscending)
                {
                    return class;
                }
            }
        }
    }
    return NULL;
}


#pragma mark - Save/Read User Data

//---------------------------------------------------------------------------------------------------------
- (void) SaveUserData: (NSString*) group
{
    NSString *docPath  = [DOCUMENTS stringByAppendingPathComponent:[NSString stringWithFormat:@"UserClasses%@.plist", group]];
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
- (BOOL) ReadUserData: (NSString*) group
{
    NSString *filePath = [DOCUMENTS stringByAppendingPathComponent:[NSString stringWithFormat:@"UserClasses%@.plist", group]];
    NSMutableArray* userDataArray = [[NSMutableArray alloc] initWithContentsOfFile: filePath];
    if(userDataArray == NULL)
        return false;
    
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
    if(week > 4) week = 1;
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


#pragma mark - Parser
//----------------------------------------------------------------------------------------------------
- (BOOL) parse:(NSString*) group
{    
    Utils* utils = [[Utils alloc] init];
    if(![utils isNetworkReachable])
    {
        int code = eAlertMessageSiteOrNetworkNotAvailabel;
        [utils performSelectorOnMainThread:@selector(showAlertWithCode:) withObject:[NSNumber numberWithInt:code] waitUntilDone:YES];
        return false;
    }
    
    
    [_classes removeAllObjects];
    dispatch_queue_t reentrantAvoidanceQueue = dispatch_queue_create("reentrantAvoidanceQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(reentrantAvoidanceQueue, ^{
        static const NSString* url = @"http://www.bsuir.by/schedule/rest/schedule/";
        NSURL* tableURL     = [NSURL URLWithString:[url stringByAppendingString:group]];
        NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:tableURL];
        
        AMXMLParserDelegate* delegate = [[AMXMLParserDelegate alloc] init];
        parser.delegate = delegate;
        delegate.delegate = self;
        [parser parse];
    });
    dispatch_sync(reentrantAvoidanceQueue, ^{ });
    return NO;
}

//-----------------------------------------------------------------
- (BOOL)parseWithData:(NSData *)data {
    [_classes removeAllObjects];
    dispatch_queue_t reentrantAvoidanceQueue = dispatch_queue_create("reentrantAvoidanceQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(reentrantAvoidanceQueue, ^{
        NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
        AMXMLParserDelegate* delegate = [[AMXMLParserDelegate alloc] init];
        parser.delegate = delegate;
        delegate.delegate = self;
        [parser parse];
    });
    dispatch_sync(reentrantAvoidanceQueue, ^{ });
    return NO;
}


//----------------------------------------------------------------------------------------------------
- (void) didParseFinished
{
    Utils* utils = [Utils new];
    NSMutableSet* set = [NSMutableSet new];
    for(int i = 0; i < _classes.count; i++)
    {
        AMClasses* temp = [_classes objectAtIndex:i];
        [set addObject:temp.timePeriod];
    }
    
    [_timesArray removeAllObjects];
    NSMutableArray* array = [NSMutableArray arrayWithArray:set.allObjects];
    NSInteger count = array.count;
    for(int i = 0 ; i < count; i++)
    {
        for(int j = 0; j < count - 1; j++)
        {
            NSInteger first =  [utils dateComponentsWithTime:[utils timePeriodStart:[array objectAtIndex:j]]].hour;
            NSInteger second = [utils dateComponentsWithTime:[utils timePeriodStart:[array objectAtIndex:j+1]]].hour;
            if(first >= second)
            {
                [array exchangeObjectAtIndex:j withObjectAtIndex:j+1];
            }
        }
    }
    _timesArray = array;
}


#pragma mark - TimetableDelegate
- (void)parserDidSuccessfullFinished {
    [self didParseFinished];
    NSNotificationCenter* notification = [NSNotificationCenter defaultCenter];
    [notification postNotificationName:@"TimeTableShouldUpdate" object:nil];
    [notification postNotificationName:@"TimeTableDownloadingDone" object:nil];
}

- (void)parserDidFinishedWithError {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Неверный номер группы. Расписание не обновлено." delegate:nil cancelButtonTitle:@"Продолжить" otherButtonTitles: nil];
    [alert show];
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
                if(class.subgroup == settings.subgroup || class.subgroup == 0)
                {
                    counter++;
                }
            }
        }
    }
    return counter;
}


- (void) clear
{
    [_classes removeAllObjects];
}

@end
