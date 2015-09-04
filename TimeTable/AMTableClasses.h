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
- (void) SaveUserData: (NSString*) group;
- (BOOL) ReadUserData: (NSString*) group;


//Метод возвращает количество занятий текущего дня. Исп. при создании таблицы
- (NSInteger) currentWeekDayClassesCount:(NSInteger) weekDay;


//Метод возвращает цвет по типу предмета
- (UIColor*) colorByClassType:(NSInteger) classType;


#pragma marc - Parsing
//Метод парсирования по группе
- (BOOL) parse:(NSString*) group;
- (BOOL) parseWithData:(NSData*)data;


//Метод оконания парсинга
- (void) didParseFinished;

#pragma marc - Other
//Отчистка массива
- (void) clear;


@end
