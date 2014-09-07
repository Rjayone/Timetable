//
//  AMViewController.m
//  TimeTable
//
//  Created by Admin on 23.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import "AMSettingsView.h"
#import "AMTableClasses.h"
#import "AMSettings.h"
#import "CustomCells.h"
#import "ViewController.h"

@implementation AMSettingsView

- (void) viewDidDisappear:(BOOL)animated
{
    AMSettings* settings = [AMSettings currentSettings];
    [settings saveSettings];
}

- (void) viewDidLoad
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard
{
    
}

//------------------------------------------------------------------------------------------------------------------------
//Скрываем клавиатуру по нажатию Done
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Actions block

//------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionSubgroupDidChanged:(UISegmentedControl *)sender
{
    AMSettings* settings = [AMSettings currentSettings];
    settings.subgroup = sender.selectedSegmentIndex;
    [self notificationTimeTableShouldUpdate];

}

//------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionGroupDidChanged:(UITextField *)sender
{
    AMSettings* settings = [AMSettings currentSettings];
    settings.currentGroup = sender.text;
    [self notificationTimeTableShouldUpdate];
}

//------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionHolidayDidChanged:(UISwitch *)sender
{
    AMSettings* settings = [AMSettings currentSettings];
    settings.holiday = sender.on;
    [self notificationTimeTableShouldUpdate];
}

//------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionWeekDidChanged:(UISegmentedControl*)sender
{
    AMSettings* settings = [AMSettings currentSettings];
    settings.currentWeek = sender.selectedSegmentIndex;
    [self notificationTimeTableShouldUpdate];
}

- (IBAction)actionColorizeDidChanged:(UISwitch *)sender
{
    AMSettings* settings = [AMSettings currentSettings];
    settings.colorize = sender.on;
    [self notificationTimeTableShouldUpdate];
}

- (IBAction)actionPushNotificationDidChanged:(UISwitch *)sender
{
    AMSettings* settings = [AMSettings currentSettings];
    settings.pushNotification = sender.on;
    [self notificationTimeTableShouldUpdate];
}

- (IBAction)actionAlarmDidChanged:(UISwitch *)sender
{
    AMSettings* settings = [AMSettings currentSettings];
    settings.alarm = sender.on;
    [self notificationTimeTableShouldUpdate];
}

- (IBAction)actionUpdateTimeTable:(UIButton *)sender
{
    AMTableClasses* classes = [AMTableClasses defaultTable];
    AMSettings* settings = [AMSettings currentSettings];
    //[classes performSelectorInBackground:@selector(parse:) withObject:settings.currentGroup];
    NSLog(@"Current group %@", settings.currentGroup);
    [classes parse: settings.currentGroup];
}


//------------------------------------------------------------------------------------------------------------------------
- (void) notificationTimeTableShouldUpdate
{
    NSNotificationCenter* notification = [NSNotificationCenter defaultCenter];
    [notification postNotificationName:@"TimeTableShouldUpdate" object:nil];
}

#pragma mark - TableView Delegate

//-------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

//---------------------------------------------------------------------------------------------------------------------------
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0 || section == 2)
        return 2;
    if(section == 1)
        return 3;
    if(section == 3)
        return 1;
    return 0;
}

//---------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Параметры группы
    if([indexPath section] == 0 )
    {
        if([indexPath row] == 0)
        {
            CustomCellGroup* cell = (CustomCellGroup*)[tableView dequeueReusableCellWithIdentifier:@"Group" forIndexPath:indexPath];
            [cell readUserData];
            return cell;
        }
        if([indexPath row] == 1)
        {
            CustomCellSubgroup* cell = [tableView dequeueReusableCellWithIdentifier:@"Subgroup" forIndexPath:indexPath];
            [cell readUserData];
            return cell;
        }
    }
    
    //Параметры отображения
    if([indexPath section] == 1 )
    {
        if([indexPath row] == 0)
        {
            CustomCellSWeek* cell = [tableView dequeueReusableCellWithIdentifier:@"Week" forIndexPath:indexPath];
            [cell readUserData];
            return cell;
        }
        if([indexPath row] == 1)
        {
            CustomCellColorize* cell = [tableView dequeueReusableCellWithIdentifier:@"Colorize" forIndexPath:indexPath];
            [cell readUserData];
            return cell;
        }
        if([indexPath row] == 2)
        {
            CustomCellHoliday* cell = [tableView dequeueReusableCellWithIdentifier:@"Holiday" forIndexPath:indexPath];
            [cell readUserData];
            return cell;
        }
    }
    
    //Уведомления
    if([indexPath section] == 2 )
    {
        if([indexPath row] == 0)
        {
            CustomCellNotification* cell = [tableView dequeueReusableCellWithIdentifier:@"Notification" forIndexPath:
                                             indexPath];
            [cell readUserData];
            return cell;
        }
        if([indexPath row] == 1)
        {
            CustomCellAlarm* cell = [tableView dequeueReusableCellWithIdentifier:@"Alarm" forIndexPath:indexPath];
            [cell readUserData];
            return cell;
        }
    }
    
    //Update
    if([indexPath section] == 3)
    {
        
        CustomCellUpdate* cell = [tableView dequeueReusableCellWithIdentifier:@"Update" forIndexPath:
                                        indexPath];
        return cell;

    }
    return nil;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) return @"Параметры группы";
    if(section == 1) return @"Параметры отображения";
    if(section == 2) return @"Уведомления";
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == 0) return @"После выбора подгруппы будет изменено отображаемое раписание.";
    if(section == 1) return @"Расписание не отображается на каникулах и во время сессии.";
    if(section == 2) return @"Будильник сработает за полтара часа до начала пар.";
    if(section == 3) return @"Расписание будет обновлено на ту группу, которую вы указали в настройках выше.";
    return nil;
}

@end
