//
//  AMViewController.h
//  TimeTable
//
//  Created by Admin on 23.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMSettingsView : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)actionSubgroupDidChanged:(UISegmentedControl *)sender;
- (IBAction)actionGroupDidChanged:(UITextField *)sender;
- (IBAction)actionHolidayDidChanged:(UISwitch *)sender;
- (IBAction)actionWeekDidChanged:(UISegmentedControl*)sender;
- (IBAction)actionColorizeDidChanged:(UISwitch *)sender;
- (IBAction)actionPushNotificationDidChanged:(UISwitch *)sender;
- (IBAction)actionAlarmDidChanged:(UISwitch *)sender;
- (IBAction)actionUpdateTimeTable:(UIButton *)sender;
@end