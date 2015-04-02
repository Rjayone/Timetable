//
//  TodayViewController.m
//  Timetable Widget
//
//  Created by Andrew Medvedev on 31.03.15.
//  Copyright (c) 2015 Andrew Medvedev. All rights reserved.
//

#import "TodayViewController.h"


@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.updateResult = NCUpdateResultNewData;
}


- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler
{
    completionHandler(_updateResult);
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;//[[AMTableClasses defaultTable] GetCurrentDayClasses].count;
}

@end
