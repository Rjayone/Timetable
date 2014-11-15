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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    if(_classes)
    {
        _subject.text = _classes.subject;
        _time.text    = _classes.timePeriod;
        _auditory.text = _classes.auditorium;
        _subgroup.selectedSegmentIndex = _classes.subgroup;
        _subjectType.selectedSegmentIndex = _classes.subjectType;
    }
}

- (IBAction)onSave:(UIButton *)sender
{
    _classes.subject = _subject.text;
    _classes.timePeriod = _time.text;
    _classes.auditorium = _auditory.text;
    _classes.subgroup = _subgroup.selectedSegmentIndex;
    _classes.subjectType = _subjectType.selectedSegmentIndex;
    
    [self dismissKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) reciveArray:(NSArray *)array
{
    _classes = [array objectAtIndex:0];
}


//----------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
{
    [_week resignFirstResponder];
    [_time resignFirstResponder];
    [_auditory resignFirstResponder];
    [_subject resignFirstResponder];
}
@end
