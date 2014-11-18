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

static NSString* kAlertMessageSiteNotAvailabel = @"Сайт БГУИР не доуступен. Повторите попытку позже.";
static NSString* kAlarmMessageNetworkNotAvailabel = @"Отсутствует подключение к интернету.";
static NSString* kAlarmMessageIncorrectGroup = @"Некорректный номер группы. Введите 6-знычный номер группы.";
static NSString* kAlarmMessageFieldsDoesntFilled = @"Пожалуйста, заполните все поля.";

static NSString* kWarningMessageDeleteRow = @"Вы собираетесь внести изменение в расписание.";

NS_ENUM(NSInteger, EAlertErroeCode)
{
    eAlertMessageSiteNotAvailabel,
    eAlarmMessageNetworkNotAvailabel,
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
- (NSDateComponents*) dateComponentsWithTime:(NSString*) time;

- (NSInteger) nowAreHoliday;

//Методы возвращают строку соответствующую в цифровом виде дню недели. Второй метод возвращает строку в Винительнмо падеже
- (NSString*) weekDayToString:(NSInteger) weekDay WithUppercase:(BOOL) uppercase;
- (NSString*) weekDayToString:(NSInteger) weekDay WithUppercase:(BOOL) uppercase AndCase:(BOOL) case_;

- (void) intToBin:(int)theNumber;

- (void) showAlertWithCode:(NSInteger) code;
- (BOOL) showWarningWithCode:(NSInteger) code;
@end