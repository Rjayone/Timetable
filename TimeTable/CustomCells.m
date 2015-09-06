//
//  CustomCells.m
//  TimeTable
//
//  Created by Admin on 27.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import "CustomCells.h"
#import "AMSettings.h"
#import "AMTableClasses.h"
#import "Utils.h"
#import "CommonTransportLayer.h"

@implementation TableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void) colorize
{
    AMSettings* settings = [AMSettings currentSettings];
    Utils* utils = [[Utils alloc] init];
    if(settings.colorize == NO)
        return;
    
    NSString* timePeriodEnd   = [utils timePeriodEnd:_ClassTime.text];
    NSString* timePeroidStart = [utils timePeriodStart:_ClassTime.text];
    NSDate* classEndTimeDate = [utils dateWithTime:timePeriodEnd];
    NSDate* classStartTimeDate = [utils dateWithTime:timePeroidStart];
    
    //Если время окончания пары меньше чем текущая дата
    if([classEndTimeDate compare:[NSDate date]] == -1)
    {
        _Subject.textColor =   [UIColor grayColor];
        _ClassTime.textColor = [UIColor grayColor];
    }
    
    if([[NSDate date] compare:classStartTimeDate] && [[NSDate date] compare: classEndTimeDate] == -1)
    {
        //self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    }
}
@end



@implementation CustomCellGroup
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setSelected:YES];
    }
    return self;
}

- (void)readUserData
{
    AMSettings* settings = [AMSettings currentSettings];
    if([settings.friendGroup isEqualToString:@"unselected"] || [settings.friendGroup isEqualToString:@""] )
        _GroupField.text = settings.currentGroup;
    else
        _GroupField.text = settings.friendGroup;
}
@end

@implementation CustomCellSWeek
- (void)readUserData
{
    AMSettings* settings = [AMSettings currentSettings];
    _WeekControl.selectedSegmentIndex = settings.weekOfMonth;
}
@end

@implementation CustomCellSubgroup
- (void)readUserData
{
    AMSettings* settings = [AMSettings currentSettings];
    _SubgroupControl.selectedSegmentIndex = settings.subgroup -1;
}
@end

@implementation CustomCellHoliday
- (void)readUserData
{
    AMSettings* settings = [AMSettings currentSettings];
    _HolidaySwitch.on = settings.holiday;
}
@end

@implementation CustomCellColorize
- (void)readUserData
{
    AMSettings* settings = [AMSettings currentSettings];
    _Colorize.on = settings.colorize;
}
@end

@implementation CustomCellExtramural
- (void)readUserData
{
    AMSettings* settings = [AMSettings currentSettings];
    self.extramural.on = settings.extramural;
}
@end

@implementation CustomCellNotification
- (void)readUserData
{
    AMSettings* settings = [AMSettings currentSettings];
    _PushNotificationSwitch.on = settings.pushNotification;
}
@end

@implementation CustomCellAlarm
- (void)readUserData
{
    AMSettings* settings = [AMSettings currentSettings];
    _AlarmSwitch.on = settings.alarm;
}
@end

@implementation CustomCellUpdate
- (IBAction)actionUpdate:(UIButton *)sender
{
    sender.enabled = NO;
    [self.activityIndicator startAnimating];
    NSInteger groupId = 0;
    AMSettings* settings = [AMSettings currentSettings];
    if([settings.friendGroup isEqualToString:@"unselected"] || [settings.friendGroup isEqualToString:@""] )
        groupId = settings.currentGroupId;
    else
        groupId = settings.friendGroupId;
    
    [[CommonTransportLayer alloc] timetableForGroupId:groupId
        success:^(NSData *xml) {
            [[AMTableClasses defaultTable]parseWithData:xml];
            [self.activityIndicator stopAnimating];
        } failure:^(NSInteger statusCode) {
            NSLog(@"Failed to load timetable");
            [self.activityIndicator stopAnimating];
        }];
}
@end


@implementation CustomCellGroups
@end