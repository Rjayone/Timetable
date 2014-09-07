//
//  ViewController.m
//  TimeTable
//
//  Created by Admin on 18.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

///ToDO:
//Ввести учет времени для определения времени до конца пары, прошедших предметов и текущего
#import "ViewController.h"
#import "CustomCells.h"
#import "AMTableClasses.h"
#import "AMXMLParserDelegate.h"
#import "AMSettingsView.h"
#import "Utils.h"
#import "ClassesNotification.h"

#define is ==

@implementation ViewController

- (void)dealloc
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_tableView reloadData];
}

//----------------------------------------------------------------------------------------------------------------------
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [[AMTableClasses defaultTable] ReadUserData];
    Utils* utils = [[Utils alloc] init];
    _settings = [AMSettings currentSettings];
    _CurrentDay.selectedSegmentIndex = [_settings currentWeekDay]-1;
    _weekDayDidChanged = false;
    
    //Слушатель, который при необходимости должен обновить таблицу с расписанием
    NSNotificationCenter* notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(shouldUpdateTableView) name:@"TimeTableShouldUpdate" object:nil];
    
    //Прячем окно с сообщением, если же воскр. то показываем сообщение.
    [_Message setHidden:YES];
    if(_settings.currentWeekDay is eSunday || [utils nowAreHoliday] == eMessageTypeSunday)
    {
        [self showAuxMessage:eMessageTypeSunday];
    }
    if([utils nowAreHoliday] == eMessageTypeHoliday)
    {
        [self showAuxMessage:eMessageTypeHoliday];
    }
    
    ///iOs8
    //Если настройки оповещания были выключены то предлагаем включить
    //UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    //[[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];

    //Регестрируем напоминания
    if(_settings.pushNotification is true)
    {
        ClassesNotification* classesNotif = [[ClassesNotification alloc] init];
        [classesNotif registerNotificationForToday: [[AMTableClasses defaultTable] GetCurrentDayClasses]];
    }
    
    //swipe
    UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionSwipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer* swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionSwipeLeft:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeRight];
    [self.view addGestureRecognizer:swipeLeft];
}


//-----------------------------------------------------------------------------------------------------------------------
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AMTableClasses *tableClasses = [AMTableClasses defaultTable];
    AMSettings *settings = [AMSettings currentSettings];
    NSInteger counter = 0;
    if(_weekDayDidChanged == YES)
         counter = [tableClasses currentWeekDayClassesCount:settings.weekDay];
    else counter = [tableClasses currentWeekDayClassesCount:settings.currentWeekDay];
    
    if(counter == 0 && settings.weekDay != eSunday)
    {
        [tableView setHidden:YES];
        [_Message setHidden:NO];
        [self showAuxMessage:eMessageTypeNoClasses];
    }
    return counter;
}

//-----------------------------------------------------------------------------------------------------------------------
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell" forIndexPath:indexPath];
    AMTableClasses *tableClasses = [AMTableClasses defaultTable];
    AMSettings* settings = [AMSettings currentSettings];
    
    NSArray* classesArray = [tableClasses GetClassesByDay:settings.weekDay];
    AMClasses* classes = [classesArray objectAtIndex: [indexPath row]];
    
    cell.Subject.text       = classes.subject;
    cell.Teacher.text       = classes.teacher;
    cell.ClassRoom.text     = classes.auditorium;
    cell.ClassTime.text     = classes.timePeriod;
    if([classes.subject isEqualToString:@"ФК-ЗОЖ СПИДиН"])
    {
        cell.Subject.text = @"Физ-ра";
        cell.Teacher.text = cell.ClassRoom.text = @"...";
    }
    if([classes.subject isEqualToString:@"Физ"])
    {
        classes.subject = @"Физика";
        cell.Subject.text = @"Физика";
    }
    
    if(settings.colorize is true)
    {
        cell.Subject.textColor  = [tableClasses colorByClassType: classes.subjectType];
        cell.ClassTime.textColor = COLOR_Default
        if(settings.currentWeekDay == classes.weekDay)
            [cell colorize];
    }
    else
    {
        cell.Subject.textColor  = COLOR_Default;
    }

    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Utils* utils = [[Utils alloc] init];
    NSString* header = [NSString stringWithFormat:@"Расписание на "];
    NSString* news = [header stringByAppendingString:[utils weekDayToString:_settings.weekDay WithUppercase:NO AndCase:YES]];
    return news;
}

//-----------------------------------------------------------------------------------------------------------------------
//Скрываем клавиатуру по нажатию Done
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
//-----------------------------------------------------------------------------------------------------------------------
- (IBAction)actionWeekDayDidChanged:(UISegmentedControl *)sender
{
    if([_tableView isHidden])
        [_tableView setHidden:NO];
    
    AMSettings* settings = [AMSettings currentSettings];
    settings.weekDay = sender.selectedSegmentIndex + 1;
    _weekDayDidChanged = true;
    [self shouldUpdateTableView];
}

//-----------------------------------------------------------------------------------------------------------------------
- (void) shouldUpdateTableView
{
    Utils* utils = [[Utils alloc] init];
    if([utils nowAreHoliday] == eMessageTypeSunday)
    {
        [self showAuxMessage:eMessageTypeSunday];
    }
    if([utils nowAreHoliday] == eMessageTypeHoliday)
    {
        [self showAuxMessage:eMessageTypeHoliday];
    }
    
    if(_settings.weekDay != eSunday)
        [_tableView setHidden:false];
    [_tableView reloadData];
}

- (IBAction)actionEditTimeTable:(UIBarButtonItem *)sender
{
    BOOL isEditing = [_tableView isEditing];
    if(isEditing)
        [_tableView setEditing:NO animated:YES];
    else [_tableView setEditing:YES animated:YES];
}

//-----------------------------------------------------------------------------------------------------------------------
- (void) showAuxMessage:(NSInteger) type
{
    if([_Message isHidden])
        [_Message setHidden:NO];
    [_tableView setHidden:YES];
    switch (type) {
        case eMessageTypeSunday:
            _Message.text = @"Сегодня выходной. Вы можете просмотреть расписание на другой день недели используя переключатель выше."; break;
        case eMessageTypeNoClasses:
            _Message.text = @"На сегодня занятия отсутствуют. Выберите другую подгруппу, день недели либо измените учебную неделю."; break;
        case eMessageTypeHoliday:
            _Message.text = @"Сейчас каникулы, занятия не проводятся.";
        default:
            break;
    }
}

#pragma mark - Gesture

- (void) actionSwipeLeft:(UISwipeGestureRecognizer*) swipe
{
    // 0 - назад, 1 - вперед
    [self animation:UIViewAnimationOptionTransitionCurlDown playForDirection:0];
    _CurrentDay.selectedSegmentIndex -= 1;
    if(_CurrentDay.selectedSegmentIndex < 0)
        _CurrentDay.selectedSegmentIndex = 0;
    [self actionWeekDayDidChanged:_CurrentDay];
}

- (void) actionSwipeRight:(UISwipeGestureRecognizer*) swipe
{
    [self animation:UIViewAnimationOptionTransitionCurlUp playForDirection:1];
    _CurrentDay.selectedSegmentIndex += 1;
    if(_CurrentDay.selectedSegmentIndex > 5)
        _CurrentDay.selectedSegmentIndex = 5;
    [self actionWeekDayDidChanged:_CurrentDay];
}


// 0 - назад, 1 - вперед
- (void) animation:(NSInteger) animationType playForDirection:(NSInteger) dir
{
    if(dir <= 0)
    {
        if( _CurrentDay.selectedSegmentIndex != 0)
        {
            [UIView transitionWithView: _tableView
                              duration: 0.7f
                               options: animationType
                            animations: ^(void)
             {
                 [self.tableView reloadData];
                 [self actionWeekDayDidChanged:_CurrentDay];
                 [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
             }
                            completion: ^(BOOL isFinished)
             {
                 [[UIApplication sharedApplication] endIgnoringInteractionEvents];
             }];
        }
    }
    else if( dir >= 1)
    {
        if( _CurrentDay.selectedSegmentIndex != 5)
        {
            [UIView transitionWithView: _tableView
                              duration: 0.7f
                               options: animationType
                            animations: ^(void)
             {
                 [self.tableView reloadData];
                 [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
             }
                            completion: ^(BOOL isFinished)
             {
                 [[UIApplication sharedApplication] endIgnoringInteractionEvents];
             }];
        }
    }
}


#pragma mark - Bookmark View

@end
