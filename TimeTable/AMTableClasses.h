//
//  AMTableClasses.h
//  TimeTable
//
//  Created by Admin on 19.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//
#pragma once

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AMClasses.h"



#define COLOR_Lab  [[UIColor alloc] initWithRed:255.f/255 green:50.f/255 blue:90.f/255 alpha:1];
#define COLOR_Prac [[UIColor alloc] initWithRed:20.f/255  green:130.f/255 blue:230.f/255 alpha:1];
#define COLOR_Lec  [[UIColor alloc] initWithRed:26.f/255  green:180.f/255 blue:100.f/255 alpha:1];
#define COLOR_Default  [[UIColor alloc] initWithRed:30.f/255  green:130.f/255 blue:230.f/255 alpha:1];

#define COLOR_CurrentClass [[UIColor alloc] initWithRed:20.f/255  green:130.f/255 blue:230.f/255 alpha:1];


@class UIColor;
@class TableViewCell;
#pragma  mark - AMTableClasses Defenitions

NS_ENUM(NSInteger, EDays)
{
    eMonday = 1,
    eTuesday,
    eWednesday,
    eThursday,
    eFriday,
    eSaturday,
    eSunday = 0
};

NS_ENUM(NSInteger, EClassType)
{
    eClassType_Lab,
    eClassType_Lecture,
    eClassType_Practical
};

NS_ENUM(NSInteger, EWeeks)
{
    eFirstWeek  = 1,
    eSecondWeek = 1 << 1,
    eThirdWeek  = 1 << 2,
    eFourthWeek = 1 << 3,
    eEveryWeek = eFirstWeek & eSecondWeek & eThirdWeek & eFourthWeek
};



#pragma mark AMTableClasses
//===================================
@interface AMTableClasses : NSObject
//===================================

//Массив занятий. Заполняется при парсинге файла с расписанием.
@property (strong, nonatomic) NSMutableArray* classes;
//Множество предметов. Хранит уникальные названия предметов с определенным id
@property (strong, nonatomic) NSMutableSet* classesSet;
//Множество звонков на пары
@property (strong, nonatomic) NSMutableArray* timesArray;
@property (strong) UIActivityIndicatorView *mySpinner;

//Реализация синглтона
+ (instancetype) defaultTable;


//Метод добавления нового предмета в массив
- (void) AddClasses:(AMClasses*) subject;


//Возврашает массив занятий
- (NSArray*) GetCurrentDayClasses;
- (NSMutableArray*) GetClassesByDay:(NSInteger) day;


//Возвращает текузее занятие
- (AMClasses*) getCurrentClass;

#pragma marc - Utils

//Метод сохраняет/считывает массив занятий в/из .plist файл
- (void) SaveUserData;
- (BOOL) ReadUserData;


//Метод возвращает количество занятий текущего дня. Исп. при создании таблицы
- (NSInteger) currentWeekDayClassesCount:(NSInteger) weekDay;


//Метод возвращает цвет по типу предмета
- (UIColor*) colorByClassType:(NSInteger) classType;


#pragma marc - Parsing
//Метод парсирования по группе
- (BOOL) parse:(NSString*) group;


//Метод оконания парсинга
- (void) didParseFinished;

#pragma marc - Other
//Отчистка массива
- (void) clear;


@end
