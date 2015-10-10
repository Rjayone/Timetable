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
#import "AMSettings.h"

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
    
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.layer.borderColor = [[UIColor colorWithWhite:0 alpha:0.10]CGColor];
    _pickerView.layer.borderWidth = 1.0f;
    _pickerView.showsSelectionIndicator = YES;
    
    //Регистрация жестов
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    //Сортируем время
    [[AMTableClasses defaultTable] didParseFinished];
    
    //Заполнение полей вьюхи
    Utils* utils = [[Utils alloc] init];
    if(_classes)
    {
        NSInteger index = [self subjectIndexInSetByString:_classes.subject];
        [_pickerView selectRow:index inComponent:0 animated:false];
        index = [self timePeriodIndexByString:_classes.timePeriod];
        [_pickerView selectRow:index inComponent:1 animated:false];
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
    [_scrollView setContentSize:CGSizeMake(320, 320)];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 50, 0.0);
    _scrollView.contentInset = contentInsets;
}

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}


-(void) viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound)
    {
        Utils* u = [[Utils alloc] init];
        //_classes.subject = _subject.text;
        NSInteger rowIndex = [_pickerView selectedRowInComponent:0];
        _classes.subject = [self subjectTitleAtIndex:rowIndex];
        rowIndex = [_pickerView selectedRowInComponent:1];
        _classes.timePeriod = [self timePeriodAtIndex:rowIndex];
        _classes.auditorium = _auditory.text;
        _classes.subgroup = _subgroup.selectedSegmentIndex;
        _classes.subjectType = _subjectType.selectedSegmentIndex;
        _classes.weekList = [u integerWeekBField:_week.text];
        _classes.teacher = _teacher.text;
        
        [self dismissKeyboard];
        [self.navigationController popViewControllerAnimated:YES];
        AMTableClasses* classes = [AMTableClasses defaultTable];
        [classes SaveUserData: [AMSettings currentSettings].currentGroup];
    }
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


- (void) reciveArray:(NSArray *)array
{
    _classes = [array objectAtIndex:0];
}


#pragma mark - ScrollView defenitions below

- (void)resetScrollView
{
    [_scrollView setContentOffset:(CGPoint){0, _pickerView.frame.size.height}animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_scrollView setContentOffset:CGPointMake(0, _pickerView.frame.size.height) animated:YES];
}

- (void)keyboardWillShowNotification:(NSNotification *)aNotification
{
    _scrollView.scrollEnabled = true;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 230, 0.0);
    _scrollView.contentInset = contentInsets;
}

-(void)keyboardWillHideNotification:(NSNotification *)aNotification
{
    [self resetScrollView];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 70, 0.0);
    _scrollView.contentInset = contentInsets;
}


#pragma marc - Picker View Delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    AMTableClasses* classes = [AMTableClasses defaultTable];
    if(component == 0)
    {
        return [classes.classesSet.allObjects objectAtIndex:row];
    }
    if(component == 1)
    {
        return [classes.timesArray objectAtIndex:row];
    }
    return NULL;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0/*Classes*/)
        return [AMTableClasses defaultTable].classesSet.count;
    if(component == 1/*Time*/)
        return [AMTableClasses defaultTable].timesArray.count;
    return 0;
}


#pragma marc - Utils

- (NSString*) subjectTitleAtIndex:(NSInteger) index
{
    AMTableClasses* classes = [AMTableClasses defaultTable];
    return [classes.classesSet.allObjects objectAtIndex:index];
}

- (NSInteger) subjectIndexInSetByString:(NSString*) title
{
    AMTableClasses* classes = [AMTableClasses defaultTable];
    return [classes.classesSet.allObjects indexOfObject:title];
}

- (NSString*) timePeriodAtIndex:(NSInteger) index
{
    AMTableClasses* classes = [AMTableClasses defaultTable];
    return [classes.timesArray objectAtIndex:index];
}

- (NSInteger) timePeriodIndexByString:(NSString*) time
{
    AMTableClasses* classes = [AMTableClasses defaultTable];
    return [classes.timesArray indexOfObject:time];
}
#pragma mark - Animations

- (void) moveView:(UIView*) view toPoint:(CGPoint) to withDuration:(CGFloat) duration andDelay:(CGFloat) delay
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelay:delay];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    view.center = to;
    [UIView commitAnimations];
}

@end
