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
    
    // Подписываемся на события клавиатуры
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(keyboardWillShowNotification:)
               name:UIKeyboardWillShowNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(keyboardWillHideNotification:)
               name:UIKeyboardWillHideNotification
             object:nil];

    _scrollView.contentSize = CGSizeMake(320.0f, 380.0f);
}

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
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

#pragma mark ScrollView defenitions below

- (void)scrollToTextField:(UITextField *)textField {
    [_scrollView setContentOffset:(CGPoint){0,
        CGRectGetHeight(textField.frame) + 17
    } animated:YES];
}

- (void)resetScrollView {
    [_scrollView setContentOffset:(CGPoint){0, 0}animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    _week = textField;
    [self scrollToTextField:_week];
}

- (void)keyboardWillShowNotification:(NSNotification *)aNotification
{
    _scrollView.scrollEnabled = true;
    CGRect keyboardScreenRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height += CGRectGetHeight(keyboardScreenRect);
    self.scrollView.contentSize = contentSize;
    
    //[self scrollToTextField:_week];
     
}

-(void)keyboardWillHideNotification:(NSNotification *)aNotification
{
    _scrollView.scrollEnabled = false;
    CGRect keyboardScreenRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height -= CGRectGetHeight(keyboardScreenRect);
    self.scrollView.contentSize = contentSize;
    [self resetScrollView];
     
}

@end
