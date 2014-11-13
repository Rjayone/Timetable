//
//  TimeTableEditView.m
//  TimeTable
//
//  Created by Admin on 10.09.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import "TimeTableEditView.h"

@implementation TimeTableEditView

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //self.navigationController.navigationBar.topItem.title = @"Редактирование";
    
    _saveButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    _saveButton.layer.borderWidth = 1.0f;
    _saveButton.layer.cornerRadius = 7;
}

@end
