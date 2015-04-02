//
//  TodayViewController.h
//  Timetable Widget
//
//  Created by Andrew Medvedev on 31.03.15.
//  Copyright (c) 2015 Andrew Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NotificationCenter/NotificationCenter.h>
#import "AMClasses.h"
#import "AMTableClasses.h"
#import "AMSettings.h"

@interface TodayViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (assign, nonatomic) NCUpdateResult updateResult;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
