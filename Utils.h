//
//  Utils.h
//  TimeTable
//
//  Created by Admin on 26.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UIViewController;

static NSString* kAlertMessageSiteNotAvailabel = @"Сайт БГУИР недоуступен. Повторите попытку позже.";
static NSString* kAlarmMessageNetworkNotAvailabel = @"Отсутствует подключение к интернету.";
static NSString* kAlertMessageSiteOrNetworkNotAvailabel = @"Отсутствует подключение к интернету или сайт БГУИР недоступен.";
static NSString* kAlarmMessageIncorrectGroup = @"Некорректный номер группы. Введите 6-знычный номер группы.";
static NSString* kAlarmMessageFieldsDoesntFilled = @"Пожалуйста, заполните все поля.";

static NSString* kWarningMessageDeleteRow = @"Занятие будет удалено со всех недель. При необходимости измените неделю для предмета в меню редактирования.";

NS_ENUM(NSInteger, EAlertErroeCode)
{
    eAlertMessageSiteNotAvailabel,
    eAlarmMessageNetworkNotAvailabel,
    eAlertMessageSiteOrNetworkNotAvailabel,
    eAlarmMessageIncorrectGroup,
    eAlarmMessageFieldsDoesntFilled
};

NS_ENUM(NSInteger, EWarnings)
{
    eWarningMessageDeleteRow
};


@interface Utils : NSObject <UIAlertViewDelegate>

- (NSString*) timePeriodStart:(NSString*) time;
- (NSString*) timePeriodEnd:  (NSString*) time;
- (NSString*) minuteFromTime: (NSString*) time;
- (NSString*) hourFromTime:   (NSString*) time;

- (NSDate*)           dateWithTime:(NSString*) time;
- (NSDate*)           deltaDate:(NSDate*) first;
- (NSDateComponents*) dateComponentsWithTime:(NSString*) time;
- (NSDateComponents*) dateComponentsWithDate:(NSDate*) date;

- (NSInteger) nowAreHoliday;


//Методы возвращают строку соответствующую в цифровом виде дню недели. Второй метод возвращает строку в Винительнмо падеже
- (NSString*) weekDayToString:(NSInteger) weekDay WithUppercase:(BOOL) uppercase;
- (NSString*) weekDayToString:(NSInteger) weekDay WithUppercase:(BOOL) uppercase AndCase:(BOOL) case_;

//Метод перевод однозначное значение времени - "2" минуты в строку "02", аналогично с часом
- (NSString*) integerClockValueToString:(NSInteger) value;

//Методы для перевода битовых масок в список недель и обратно
- (NSString*) weekListToString:(NSInteger) weekList;
- (NSInteger) integerWeekBField: (NSString*) day;

- (void) intToBin:(int)theNumber;

- (void) showAlertWithCode:(NSInteger) code;
- (BOOL) showWarningWithCode:(NSInteger) code;

- (BOOL) isNetworkReachable;
@end