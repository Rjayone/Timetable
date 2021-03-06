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
#import "TimeTableEditView.h"

#define is ==

@implementation ViewController

- (void)dealloc
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
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
    [notification addObserver:self selector:@selector(applicationBecameActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [notification addObserver:self selector:@selector(UpdateNotification) name:@"TimeTableUpdateNotification" object:nil];
    //[notification addObserver:self selector:@selector(shouldUpdateTableView) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    
    //Прячем окно с сообщением, если же воскр. то показываем сообщение.
    [_Message setHidden:YES];
    if(_settings.currentWeekDay is eSunday || [utils nowAreHoliday] == eMessageTypeSunday)
    {
        [self showAuxMessage:eMessageTypeSunday];
    }
//    if([utils nowAreHoliday] == eMessageTypeHoliday)
//    {
//        [self showAuxMessage:eMessageTypeHoliday];
//    }
    
    ///iOs8
    UIDevice *device = [UIDevice currentDevice];
    if([device.systemVersion integerValue] >= 8)
    {
        //Если настройки оповещания были выключены то предлагаем включить
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }

    //Регестрируем напоминания
    if(_settings.pushNotification is true)
    {
        ClassesNotification* classesNotif = [[ClassesNotification alloc] init];
        NSArray* currentDayClasses =[[AMTableClasses defaultTable] GetCurrentDayClasses];
        [classesNotif registerNotificationForToday: currentDayClasses];
    }
    
    //swipe
    UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionSwipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer* swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionSwipeLeft:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeRight];
    [self.view addGestureRecognizer:swipeLeft];
    
    //Перезагружаем таблицу
    [_tableView reloadData];
    _tableView.allowsSelectionDuringEditing = YES;
}


//-------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    [self shouldUpdateTableView];
}


//-------------------------------------------------------------------------------------------------------------------
///Метод вызывается в момент активации приложения
- (void) applicationBecameActive
{
    [_tableView reloadData];
    
    ///iOs8
    UIDevice *device = [UIDevice currentDevice];
    if([device.systemVersion integerValue] >= 8)
    {
        //Если настройки оповещания были выключены то предлагаем включить
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
    
    //Регестрируем напоминания
    if(_settings.pushNotification is true)
    {
        ClassesNotification* classesNotif = [[ClassesNotification alloc] init];
        [classesNotif registerNotificationForToday: [[AMTableClasses defaultTable] GetCurrentDayClasses]];
    }
}

- (void) UpdateNotification
{
    //Регестрируем напоминания
    if(_settings.pushNotification is true)
    {
        ClassesNotification* classesNotif = [[ClassesNotification alloc] init];
        NSArray* currentDayClasses =[[AMTableClasses defaultTable] GetCurrentDayClasses];
        [classesNotif registerNotificationForToday: currentDayClasses];
    }
}

//-------------------------------------------------------------------------------------------------------------------
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AMTableClasses *tableClasses = [AMTableClasses defaultTable];
    AMSettings *settings = [AMSettings currentSettings];
    NSInteger counter = 0;// Количество пар
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

//--------------------------------------------------------------------------------------------------------------------
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
    if([classes.subject isEqualToString:@"ФизК (вкл. СПИДиН)"])
    {
        cell.Subject.text = @"Физ-ра";
        cell.Teacher.text = cell.ClassRoom.text = @"...";
    }
    if([classes.subject isEqualToString:@"Физ"])
    {
        classes.subject = @"Физика";
        cell.Subject.text = @"Физика";
    }
    
    //Если включена колоризация, то отрисовываем элементы
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

//-----------------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Utils* utils = [[Utils alloc] init];
    NSString* header = [NSString stringWithFormat:@"Расписание на "];
    NSString* news= [header stringByAppendingString:[utils weekDayToString:_settings.weekDay WithUppercase:NO AndCase:YES]];
    return news;
}


#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    static CGFloat kTargetOffset = 82.0f;
    
    if(scrollView.contentOffset.x >= kTargetOffset){
        scrollView.contentOffset = CGPointMake(kTargetOffset, 0.0f);
    }
}


//-----------------------------------------------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if(indexPath.row == 2)
    //    return UITableViewCellEditingStyleInsert;
    
    if(_tableView.isEditing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    else
    {
        return UITableViewCellEditingStyleNone;
    }
}

//-------------------------------------------------------------------------------------------------------------------
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)// && ! [utils showWarningWithCode:eWarningMessageDeleteRow])
    {
        AMTableClasses* classes = [AMTableClasses defaultTable];
        [classes.classes removeObject: [[classes GetClassesByDay:_CurrentDay.selectedSegmentIndex + 1]objectAtIndex:indexPath.row]];
        NSArray* ar = [NSArray arrayWithObject:indexPath];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:ar withRowAnimation:UITableViewRowAnimationRight];
        [tableView endUpdates];
        [classes SaveUserData];
    }
    
    if(editingStyle == UITableViewCellEditingStyleInsert)
    {
        //NSArray* ar = [NSArray arrayWithObject:indexPath];
        //[tableView insertRowsAtIndexPaths:ar withRowAnimation:UITableViewRowAnimationLeft];
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Удалить";
}

//-----------------------------------------------------------------------------------------------------------------------
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimeTableEditView *NewS = [self.storyboard instantiateViewControllerWithIdentifier:@"TimeTableEditView"];
    [self.navigationController pushViewController:NewS animated:YES];
    AMTableClasses* tableClasses = [AMTableClasses defaultTable];
    NSMutableArray* classes = [tableClasses GetClassesByDay:_CurrentDay.selectedSegmentIndex +1];
    NSInteger row = indexPath.row;
    AMClasses* selectedClass = [classes objectAtIndex:row];
    
    [NewS reciveArray: [NSArray arrayWithObjects:selectedClass, nil]];
    [_tableView deselectRowAtIndexPath: indexPath animated:YES];
}

#pragma mark - Other

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

//-------------------------------------------------------------------------------------------------------------------
- (void) shouldUpdateTableView
{
    Utils* utils = [[Utils alloc] init];
    if([utils nowAreHoliday] == eMessageTypeSunday)
    {
        [self showAuxMessage:eMessageTypeSunday];
    }
//    if([utils nowAreHoliday] == eMessageTypeHoliday)
//    {
//        [self showAuxMessage:eMessageTypeHoliday];
//        return;
//    }
    
    if(_settings.weekDay != eSunday)
        [_tableView setHidden:false];
    [_tableView reloadData];
}

//------------------------------------------------------------------------------------------------------------------
- (IBAction)actionEditTimeTable:(UIBarButtonItem *)sender
{
    BOOL isEditing = [_tableView isEditing];
    AMTableClasses* classes = [AMTableClasses defaultTable];
    NSInteger count = [classes GetClassesByDay:_CurrentDay.selectedSegmentIndex+1].count;
    
    if(isEditing)
    {
        [_tableView setEditing:NO animated:YES];
        for(int i = 0; i < count; i++)
        {
            NSIndexPath* tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0] ;
            TableViewCell* cell = (TableViewCell*)[_tableView cellForRowAtIndexPath:tempIndexPath];
            if(cell)
            {
                cell.imgTime.hidden = false;
                cell.imgAuditory.hidden = false;
            }
        }
        
        //[_tableView beginUpdates];
        //NSIndexPath* tempIndexPath = [NSIndexPath indexPathForRow:count inSection:0] ;
        //NSArray *ar = [NSArray arrayWithObject:tempIndexPath];
        //[_tableView insertRowsAtIndexPaths:ar withRowAnimation:UITableViewRowAnimationLeft];
        //[_tableView endUpdates];
    }
    else
    {
        [_tableView setEditing:YES animated:YES];
        for(int i = 0; i < count; i++)
        {
            NSIndexPath* tempIndexPath = [NSIndexPath indexPathForRow:i inSection:0] ;
            TableViewCell* cell = (TableViewCell*)[_tableView cellForRowAtIndexPath:tempIndexPath];
            if(cell)
            {
                cell.imgTime.hidden = true;
                cell.imgAuditory.hidden = true;
            }
        }
    }
}

//------------------------------------------------------------------------------------------------------------------
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
    if([_tableView isEditing])
        return;
    
    // 0 - назад, 1 - вперед
    [self animation:UIViewAnimationOptionTransitionCurlDown playForDirection:0];
    _CurrentDay.selectedSegmentIndex -= 1;
    if(_CurrentDay.selectedSegmentIndex < 0)
        _CurrentDay.selectedSegmentIndex = 0;
    [self actionWeekDayDidChanged:_CurrentDay];
}

- (void) actionSwipeRight:(UISwipeGestureRecognizer*) swipe
{
    if([_tableView isEditing])
        return;
    
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

@end
