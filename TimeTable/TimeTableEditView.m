//
//  TimeTableEditView.m
//  TimeTable
//
//  Created by Admin on 10.09.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import "TimeTableEditView.h"
#import "Utils.h"
#import "AMTableClasses.h"

@implementation TimeTableEditView

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self setTitle:@"Редактирование"];
    [self.navigationItem.backBarButtonItem setTitle:@""];
    
    //Закругление кнопки
    _saveButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    _saveButton.layer.borderWidth = 1.0f;
    _saveButton.layer.cornerRadius = 7;
    
    
    //Регистрация жестов
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    //Заполнение полей вьюхи
    Utils* utils = [[Utils alloc] init];
    if(_classes)
    {
        _subject.text = _classes.subject;
        _time.text    = _classes.timePeriod;
        _auditory.text = _classes.auditorium;
        _subgroup.selectedSegmentIndex = _classes.subgroup;
        _subjectType.selectedSegmentIndex = _classes.subjectType;
        _week.text = [utils weekListToString:_classes.weekList];
        _teacher.text = _classes.teacher;
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
    
    //Включаем скролинг
    [_scrollView setScrollEnabled:YES];
    [_scrollView setContentSize:CGSizeMake(320, 500)];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 100, 0.0);
    _scrollView.contentInset = contentInsets;
}

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

//-------------------------------------------------------------------------------------------------------------------
-(void)dismissKeyboard {
    [_auditory resignFirstResponder];
    [_time resignFirstResponder];
    [_subject resignFirstResponder];
    [_week resignFirstResponder];
    [_teacher resignFirstResponder];
}

- (void)viewDidLayoutSubviews {
    [_scrollView setContentSize:CGSizeMake(320, 500)];
}

- (IBAction)onSave:(UIButton *)sender
{
    Utils* u = [[Utils alloc] init];
    _classes.subject = _subject.text;
    _classes.timePeriod = _time.text;
    _classes.auditorium = _auditory.text;
    _classes.subgroup = _subgroup.selectedSegmentIndex;
    _classes.subjectType = _subjectType.selectedSegmentIndex;
    _classes.weekList = [u integerWeekBField:_week.text];
    _classes.teacher = _teacher.text;
    
    [self dismissKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
    AMTableClasses* classes = [AMTableClasses defaultTable];
    [classes SaveUserData];
}

- (void) reciveArray:(NSArray *)array
{
    _classes = [array objectAtIndex:0];
}


#pragma mark ScrollView defenitions below

- (void)resetScrollView
{
    //[_scrollView setContentOffset:(CGPoint){0, 0}animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    _week = textField;
    [self scrollToTextField:_week];
}

- (void)scrollToTextField:(UITextField *)textField {
    [_scrollView setContentOffset:(CGPoint){0,
        CGRectGetHeight(textField.frame)
    } animated:YES];
}

#define scrollHeight 230

- (void)keyboardWillShowNotification:(NSNotification *)aNotification
{
    _scrollView.scrollEnabled = true;
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height += scrollHeight;
    self.scrollView.contentSize = contentSize;
}

-(void)keyboardWillHideNotification:(NSNotification *)aNotification
{
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height -= scrollHeight;//CGRectGetHeight(keyboardScreenRect);
    self.scrollView.contentSize = contentSize;
    [self resetScrollView];
}

@end
