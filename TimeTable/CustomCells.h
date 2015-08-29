//
//  CustomCells.h
//  TimeTable
//
//  Created by Admin on 27.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>

//===============================================================================================================
@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *Subject;
@property (weak, nonatomic) IBOutlet UILabel *Teacher;
@property (weak, nonatomic) IBOutlet UILabel *ClassTime;
@property (weak, nonatomic) IBOutlet UILabel *ClassRoom;
@property (weak, nonatomic) IBOutlet UILabel *SubjectType;

@property (weak, nonatomic) IBOutlet UIImageView *imgTime;
@property (weak, nonatomic) IBOutlet UIImageView *imgAuditory;
@property (weak, nonatomic) IBOutlet UIImageView *imgSubgroup;

- (void) colorize;

@end

///Ячейки для таблицы в настройках
//================================================================================================================
@interface CustomCellGroup : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *GroupField;
- (void)readUserData;
@end

//================================================================================================================
@interface CustomCellSWeek : UITableViewCell
@property (weak, nonatomic) IBOutlet UISegmentedControl *WeekControl;
- (void)readUserData;
@end

//================================================================================================================
@interface CustomCellSubgroup : UITableViewCell
@property (weak, nonatomic) IBOutlet UISegmentedControl *SubgroupControl;
- (void)readUserData;
@end

//================================================================================================================
@interface CustomCellHoliday : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *HolidaySwitch;
- (void)readUserData;
@end

//================================================================================================================
@interface CustomCellColorize : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *Colorize;
- (void)readUserData;
@end


//================================================================================================================
@interface CustomCellExtramural : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *extramural;
- (void)readUserData;
@end

//===============================================================================================================
@interface CustomCellNotification : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *PushNotificationSwitch;
- (void)readUserData;
@end

//===============================================================================================================
@interface CustomCellAlarm : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *AlarmSwitch;
- (void)readUserData;
@end

//================================================================================================================
@interface CustomCellUpdate : UITableViewCell
- (IBAction)actionUpdate:(UIButton *)sender;
@end

@interface CustomCellGroups : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField* group;
@end

