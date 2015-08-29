//
//  ViewController.m
//  TimeTable
//
//  Created by Admin on 18.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import "ViewController.h"
#import "CustomCells.h"
#import "AMTableClasses.h"
#import "AMXMLParserDelegate.h"
#import "AMSettingsView.h"
#import "Utils.h"
#import "ClassesNotification.h"
#import "TimeTableEditView.h"
#import "AppDesciptionViewController.h"
#import "UIImageEffects.h"

#define is ==

@implementation ViewController

- (void)dealloc
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}


//------------------------------------------------------------------------------------------------------------------
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    Utils* utils = [[Utils alloc] init];
    _settings = [AMSettings currentSettings];
    _CurrentDay.selectedSegmentIndex = [_settings currentWeekDay]-1;
    _weekDayDidChanged = false;
    _isDownloading = false;
    
    
    [[AMTableClasses defaultTable] ReadUserData:_settings.currentGroup];
    
    //Слушатель, который при необходимости должен обновить таблицу с расписанием
    NSNotificationCenter* notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(shouldUpdateTableView) name:@"TimeTableShouldUpdate" object:nil];
    [notification addObserver:self selector:@selector(downloadingTimetable) name:@"TimeTableDownloading" object:nil];
    [notification addObserver:self selector:@selector(downloadingTimetableDone) name:@"TimeTableDownloadingDone" object:nil];
    [notification addObserver:self selector:@selector(applicationBecameActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [notification addObserver:self selector:@selector(UpdateNotification) name:@"TimeTableUpdateNotification" object:nil];
    
    
    //Прячем окно с сообщением, если же воскр. то показываем сообщение.
    [_Message setHidden:YES];
    if(_settings.currentWeekDay is eSunday || [utils nowAreHoliday] == eMessageTypeSunday)
    {
        [self showAuxMessage:[NSNumber numberWithInteger:eMessageTypeSunday]];
    }
    
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
    
    [self updateTimeMessage];
    
    //Устанавливаем таймер
    [self setTimeUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    [self setTabBarVisible:NO animated:YES];
}


//-------------------------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
 
//    
//    //PopUP
//    AppDesciptionViewController *rootView = [[[NSBundle mainBundle] loadNibNamed:@"AppDesciptionViewController" owner:self options:nil] objectAtIndex:0];
//    UIGraphicsBeginImageContext(CGSizeMake(self.view.frame.size.width, self.view.frame.size.height));
//    [self.view drawViewHierarchyInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) afterScreenUpdates:YES];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    UIImage* blured = [UIImageEffects imageByApplyingBlurToImage:image withRadius:10 tintColor:[UIColor colorWithWhite:0.2 alpha:0.4] saturationDeltaFactor:1.5 maskImage:nil];
//    UIImageView* imgView = [[UIImageView alloc]initWithImage:blured];
//    [rootView.view addSubview:imgView];
//    [rootView.view sendSubviewToBack:imgView];
//    rootView.parent = self;
//    
//    [self.view addSubview:rootView.view];
//    //~

    
    if(_settings.extramural && self.CurrentDay.numberOfSegments == 6) {
        [self.CurrentDay insertSegmentWithTitle:@"ВС" atIndex:6 animated:YES];
    } else if(self.CurrentDay.numberOfSegments == 7 && !_settings.extramural){
        if(self.CurrentDay.selectedSegmentIndex == 6) {
            self.CurrentDay.selectedSegmentIndex -= 1;
            [self actionWeekDayDidChanged:_CurrentDay];
        }
        [self.CurrentDay removeSegmentAtIndex:6 animated:YES];
        
    }
    [self shouldUpdateTableView];
}

- (void)dismissPopUp {
    for(UIView* view in self.view.subviews)
        if([view isKindOfClass:[AppDesciptionViewController class]])
            [view removeFromSuperview];
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
    
    //Обновляем время
    [self updateTimeMessage];
    
    //Устанавливаем таймер
    [self setTimeUpdate];
}

//-------------------------------------------------------------------------------------------------------------------
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



#pragma mark - UITableView DataSource
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
        [_Message  setHidden:NO];
        [self showAuxMessage:@(eMessageTypeNoClasses)];
    } else if(counter == 0 && settings.weekDay == eSunday && _settings.extramural) {
        [tableView setHidden:YES];
        [_Message setHidden:NO];
        [self showAuxMessage:@(eMessageTypeNoClasses)];
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
    AMClasses* classes;
    if(classesArray.count > 0)
        classes = [classesArray objectAtIndex: [indexPath row]];
    
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
        classes.subject   = @"Физика";
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
    
    switch (classes.subgroup) {
        case 0: cell.imgSubgroup.image = [UIImage imageNamed:@"subgroup3_@2.png"]; break;
        case 1: cell.imgSubgroup.image = [UIImage imageNamed:@"subgroup1_@2.png"]; break;
        case 2: cell.imgSubgroup.image = [UIImage imageNamed:@"subgroup2_@2.png"]; break;
        default:
            break;
    }
    
    //скрываем иконки если был произведен переход с др дней
    if(_tableView.isEditing)
    {
        cell.imgTime.hidden = true;
        cell.imgAuditory.hidden = true;
    }
    else
    {
        cell.imgTime.hidden = false;
        cell.imgAuditory.hidden = false;
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


//-----------------------------------------------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ///Todo: здесь указывается последняя ячейка, которая дает возможность
    ///добавить новую запись
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
    NSString* message = kWarningMessageDeleteRow;
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Предупреждение" message:message delegate:nil cancelButtonTitle:@"Продолжить" otherButtonTitles: @"Отмена",nil];
    alert.delegate = self;
    [alert show];
    
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        _indexPathOfDeletingCell = indexPath;
    }
}


- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1) //no
        return;
    else
    {
        AMTableClasses* classes = [AMTableClasses defaultTable];
        [classes.classes removeObject: [[classes GetClassesByDay:_CurrentDay.selectedSegmentIndex + 1]objectAtIndex:_indexPathOfDeletingCell.row]];
        NSArray* ar = [NSArray arrayWithObject:_indexPathOfDeletingCell];
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:ar withRowAnimation:UITableViewRowAnimationRight];
        [_tableView endUpdates];
        [classes SaveUserData: _settings.currentGroup];
        [self UpdateNotification];
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
    [self showAuxMessage:[NSNumber numberWithInteger:-1]];
    if(_settings.weekDay == eSunday && !_settings.extramural)
        [self showAuxMessage:[NSNumber numberWithInteger:eMessageTypeSunday]];
    if(_isDownloading)
        [self showAuxMessage:[NSNumber numberWithInt:eMessageTypeDownloading]];
    [_tableView reloadData];
}

//-------------------------------------------------------------------------------------------------------------------
- (void) downloadingTimetable
{
    [self performSelectorOnMainThread:@selector(showAuxMessage:) withObject:[NSNumber numberWithInteger:eMessageTypeDownloading] waitUntilDone:NO];
    [_spinner performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:NO];
    _isDownloading = YES;
}


- (void) downloadingTimetableDone
{
    _isDownloading = NO;
    [_spinner stopAnimating];
    [self shouldUpdateTableView];
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
- (void) showAuxMessage:(NSNumber*) type
{
    if([_Message isHidden])
        [_Message setHidden:NO];
    [_tableView setHidden:YES];
    switch (type.integerValue) {
        case eMessageTypeSunday:
            _Message.text = @"Сегодня выходной. Вы можете просмотреть расписание на другой день недели используя переключатель выше."; break;
        case eMessageTypeNoClasses:
            _Message.text = @"На сегодня занятия отсутствуют. Выберите другую подгруппу, день недели либо измените учебную неделю."; break;
        case eMessageTypeHoliday:
            _Message.text = @"Сейчас каникулы, занятия не проводятся."; break;
        case eMessageTypeDownloading:
            _Message.text = @"Идет загрузка расписания."; break;
        default:{
            _Message.hidden = YES;
            _tableView.hidden = NO;
        }break;
    }
}

//------------------------------------------------------------------------------------------------------------------
- (void) updateTimeMessage
{
    Utils* utils = [Utils new];
    NSDate* date = [NSDate date];
    NSArray* classes = [[AMTableClasses defaultTable] GetCurrentDayClasses];
    if([classes count] < 1)
    {
        _timeValue.hidden = true;
        _timeMessage.hidden = true;
        _clockImage.hidden  = true;
        return;
    }
    
    _timeValue.hidden = false;
    _timeMessage.hidden = false;
    _clockImage.hidden  = false;
    AMClasses* firstClass = [classes objectAtIndex:0];
    AMClasses* lastClass  = [classes objectAtIndex:[classes count]-1];
    NSDate* firstClassDate = [utils dateWithTime:firstClass.timePeriod];
    NSDate* lastClassDate  = [utils dateWithTime:[utils timePeriodEnd:lastClass.timePeriod]];
    if([date compare:lastClassDate] == NSOrderedDescending)
    {
        _timeValue.hidden = true;
        _timeMessage.hidden = true;
        //_timeMessage.text = @"На сегодня пары закончились";
        _clockImage.hidden  = true;
        
        return;
    }
    
    if([date compare:firstClassDate] == NSOrderedAscending)
    {
        //Если текущее вермя меньше начала занятия, то "время до начала пары"
        _timeMessage.text = @"До начала пары";
        NSDateComponents* firstComps = [utils dateComponentsWithTime:firstClass.timePeriod];
        NSDateComponents* current    = [utils dateComponentsWithDate:date];
        
        NSInteger hour = firstComps.hour - current.hour;
        NSInteger min  = firstComps.minute - current.minute;
        if(min < 0)
        {
            if(hour > 0) hour--; else hour = 0;
            min += 60;
        }

        _timeValue.text = [NSString stringWithFormat:@"%@:%@", [utils integerClockValueToString:hour], [utils integerClockValueToString:min]];
        NSLog(@"%ld:%ld", (long)hour, (long) min);
    }
    else
    {
        _timeMessage.text = @"До конца пары";
        AMClasses* currentClass = [[AMTableClasses defaultTable] getCurrentClass];
        if(currentClass == NULL)
        {
            _timeValue.hidden = true;
            _timeMessage.hidden = true;
            _clockImage.hidden  = true;
            return;
        }
        NSString* endTime = [utils timePeriodEnd:currentClass.timePeriod];
        NSDateComponents* endComps = [utils dateComponentsWithTime:endTime];
        NSDateComponents* current    = [utils dateComponentsWithDate:date];
        
        NSInteger hour = endComps.hour - current.hour;
        NSInteger min  = endComps.minute - current.minute;
        if(min < 0)
        {
            if(hour > 0) hour--; else hour = 0;
            min += 60;
        }
        
        _timeValue.text = [NSString stringWithFormat:@"%@:%@", [utils integerClockValueToString:hour], [utils integerClockValueToString:min]];
    }
    
}

- (void) setTimeUpdate
{
    Utils* utils = [Utils new];
    NSDateComponents* comp = [utils dateComponentsWithDate:[NSDate date]];
    NSInteger deltaSecond = 60 - comp.second;
    
    if(deltaSecond < 0)
        return;
    
    [self performSelector:@selector(setTimeUpdate) withObject:NULL afterDelay:deltaSecond];
    [self updateTimeMessage];
    NSLog(@"Time Updated");
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
    if(_CurrentDay.selectedSegmentIndex > _CurrentDay.numberOfSegments - 1)
        _CurrentDay.selectedSegmentIndex = _CurrentDay.numberOfSegments - 1;
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
                              duration: 0.4f
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
                              duration: 0.4f
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


- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated {
    
    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) return;
    
    // get a frame calculation ready
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    
    // zero duration means no animation
    CGFloat duration = (animated)? 0.25 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    }];
}

// know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}
@end
