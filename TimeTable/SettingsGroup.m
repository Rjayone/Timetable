//
//  SettingsGroup.m
//  TimeTable
//
//  Created by Andrew Medvedev on 27.03.15.
//  Copyright (c) 2015 Andrew Medvedev. All rights reserved.
//

#import "SettingsGroup.h"
#import "AMSettings.h"
#import "AMSettingsView.h"
#import "CustomCells.h"
#import "AMTableClasses.h"

@interface SettingsGroup()
@property (strong, nonatomic) UITextField* lastEnditingTextField;
@property (strong, nonatomic) UIToolbar* phoneKeyboardDoneButtonView;
@end

@implementation SettingsGroup

//-------------------------------------------------------------------------------------------------
- (void) viewDidLoad
{
    [super viewDidLoad];
    if(_settings == NULL)
        self.settings = [AMSettings currentSettings];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self.view
//                                   action:@selector(endEditing:)];
    //'Done' btn for TF
    self.phoneKeyboardDoneButtonView = [[UIToolbar alloc] init];
    [self.phoneKeyboardDoneButtonView sizeToFit];
    UIBarButtonItem *flexiblSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Ок"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self.view
                                                                  action:@selector(endEditing:)];
    [self.phoneKeyboardDoneButtonView setItems:@[flexiblSpace, doneButton]];
    
}

//-------------------------------------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    ///Код ниже выбирает ячейку в соответствии с группой
    BOOL isFriendGroup = NO;
    for(int i = 0; i < _settings.groupSet.count; i++)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:1];
        CustomCellGroups* cell = (CustomCellGroups*)[_tableView cellForRowAtIndexPath:indexPath];
        if([cell.group.text isEqualToString:_settings.friendGroup])
        {
            isFriendGroup = YES;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            _selectedGroup = i;
        }
    }
    if(isFriendGroup == NO)
    {
        [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        _selectedGroup = -1;
    }
}

//-------------------------------------------------------------------------------------------------
- (void) viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound)
    {
        UIViewController* amView = self.navigationController.topViewController;
        [[(AMSettingsView*)amView tableView]reloadData];
        
        NSIndexPath* indexPath = NULL;
        _settings.currentGroup = [[(CustomCellGroups*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] group]text];
        
        NSInteger size = _settings.groupSet.count;
        [_settings.groupSet removeAllObjects];
        for(int i = 0; i < size; i++)
        {
            indexPath = [NSIndexPath indexPathForRow:i inSection:1];
            CustomCellGroups* cell = (CustomCellGroups*)[_tableView cellForRowAtIndexPath:indexPath];
            if(cell.group.text.length != 6)
                continue;
            else
                [_settings.groupSet addObject:cell.group.text];
        }
        [_settings saveSettings];
    }
}

//-------------------------------------------------------------------------------------------------
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_settings.groupSet.count > 0)
        return 2;
    return 1;
}

//-------------------------------------------------------------------------------------------------
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    if(section == 1)
        return _settings.groupSet.count;
    return 0;
}

//-------------------------------------------------------------------------------------------------
- (CustomCellGroups*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ///Дописать метод внутри кастом целл для сохранения данных
    CustomCellGroups* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if(indexPath.row == 0 && indexPath.section == 0)
    {
        cell.group.text = _settings.currentGroup;
        cell.group.delegate = self;
        cell.group.inputAccessoryView = self.phoneKeyboardDoneButtonView;
        return cell;
    }
    if(indexPath.section == 1)
        cell.group.text = (NSString*)_settings.groupSet[indexPath.row];
    cell.group.delegate = self;
    cell.group.inputAccessoryView = self.phoneKeyboardDoneButtonView;
    return cell;
}

//-------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"Мое расписание";
    if(section == 1 && _settings.groupSet.count >= 1)
        return @"Расписание друзей";
    return  NULL;
}

//-------------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for(int i = 0; i <= 1; i++)
    {
        for(int j = 0; j < _settings.groupSet.count; j++)
        {
            NSIndexPath* path = [NSIndexPath indexPathForRow:j inSection:i];
            CustomCellGroups* cell = (CustomCellGroups*)[tableView cellForRowAtIndexPath:path];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return indexPath;
}


//-------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCellGroups* cell = (CustomCellGroups*)[tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    _selectedGroup = [indexPath section] == 0 ? -1 : [indexPath row];
    if(_selectedGroup == -1)
        _settings.friendGroup = @"";
    else
        _settings.friendGroup = cell.group.text;
    
    //Заставляем вращаться спинер
    NSNotificationCenter* notification = [NSNotificationCenter defaultCenter];
    NSNotification* n = [NSNotification notificationWithName:@"TimeTableDownloading" object:nil];
    [notification postNotification:n];
    
    AMTableClasses* classes = [AMTableClasses defaultTable];
    if([classes ReadUserData:cell.group.text] == false) //Проверяем, есть ли уже загруженное расписание
        [classes performSelectorInBackground:@selector(parse:) withObject:cell.group.text];
    else
    {
        NSNotificationCenter* notification = [NSNotificationCenter defaultCenter];
        [notification postNotificationName:@"TimeTableShouldUpdate" object:nil];
        [notification postNotificationName:@"TimeTableDownloadingDone" object:nil];
    }
}


//-------------------------------------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section >= 1)
        return UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleNone;
}


//-------------------------------------------------------------------------------------------------------------
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete && indexPath.section >= 1)
    {
        [tableView beginUpdates];
        [_settings.groupSet removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if(_settings.groupSet.count == 0) {
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        }
        [tableView endUpdates];
            
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Удалить";
}

//-------------------------------------------------------------------------------------------------
- (IBAction)addNewGroup:(UIBarButtonItem *)sender
{
    NSString* group = @"";
    NSIndexPath *path = NULL;
    
    path = [NSIndexPath indexPathForRow:_settings.groupSet.count inSection:1];
    
    
    [_tableView beginUpdates];
    if(_settings.groupSet.count == 0)
        [_tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_settings.groupSet addObject:group];
    [_tableView insertRowsAtIndexPaths: [NSArray arrayWithObject:path] withRowAnimation: UITableViewRowAnimationLeft];
    [_tableView endUpdates];
        
    
    CustomCellGroups* cell = (CustomCellGroups*)[_tableView cellForRowAtIndexPath:path];
    cell.group.delegate = self;
    cell.group.text = _lastEnditingTextField.text;
    cell.group.inputAccessoryView = self.phoneKeyboardDoneButtonView;
    [cell.group becomeFirstResponder];
}


#pragma mark - UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.lastEnditingTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

@end
