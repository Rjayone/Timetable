//
//  NewBookmarkView.m
//  TimeTable
//
//  Created by Admin on 07.09.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewBookmarkView.h"
#import "BookmarksViewController.h"
#import "Bookmarks.h"
#import "BookmarksManager.h"
#import "Utils.h"
#import "AMTableClasses.h"

static bool moved = false;

@implementation NewBookmarkView

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.layer.borderColor = [[UIColor colorWithWhite:0 alpha:0.10]CGColor];
    _pickerView.layer.borderWidth = 1.0f;
    _pickerView.showsSelectionIndicator = YES;
    [self.view addSubview:_pickerView];
    
    _bookmark.layer.borderColor = [[UIColor colorWithWhite:0 alpha:0.10]CGColor];
    _bookmark.layer.borderWidth = 1.0f;
    _bookmark.layer.cornerRadius = 7;
    _bookmark.delegate = self;
    
    _keyboardScreenRect = (CGRect){0,352,320,216};

    
    if(_segueType == e_SegueTypeNew)
    {
        [self setTitle:@"Новая заметка"];
    }
    if(_segueType == e_SegueTypeEdit)
    {
        [self setTitle:@"Редактирование"];
    }
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
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
    
    if(_bookmarks)
    {
        _bookmark.text = _bookmarks.bookmarkDescription;
        ///Здесь нужно по названию предмета получить его ид для пикер вью
        NSInteger index = [self subjectIndexInSetByString:_bookmarks.bookmarkSubject];
        [_pickerView selectRow:index inComponent:0 animated:false];
        _date.text     = _bookmarks.bookmarkDate;
    }
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [_scrollView setScrollEnabled:YES];
    _scrollView.contentSize = CGSizeMake(0, 320);
    _scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 200, 0.0);
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    _contentDefaultYPos = _contentView.center.y;
    _pickerDefaultYPos = _pickerView.center.y;
}

//--------------------------------------------------------------------------------------------------
- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}



//--------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
{
    [_bookmark resignFirstResponder];
    [_date resignFirstResponder];
}


//--------------------------------------------------------------------------------------------------
-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound)
    {
        BookmarksManager* manager = [BookmarksManager currentBookmarks];
        if(_segueType == e_SegueTypeNew)
        {
            Bookmarks* bookmark = [[Bookmarks alloc] init];
            if(self.bookmark.text.length == 0  || _date.text.length == 0)
            {
                Utils* utils = [[Utils alloc] init];
                [utils showAlertWithCode:eAlarmMessageFieldsDoesntFilled];
                
                if(self.bookmark.text.length == 0) bookmark.bookmarkDescription = @"Новая заметка";
                else bookmark.bookmarkDescription = self.bookmark.text;
                NSInteger rowIndex = [_pickerView selectedRowInComponent:0];
                bookmark.bookmarkSubject = [self subjectTitleAtIndex:rowIndex];
                if(_date.text.length == 0) bookmark.bookmarkDate = @"...";
                else bookmark.bookmarkDate = _date.text;
            }
            else
            {
                bookmark.bookmarkDescription = self.bookmark.text;
                NSInteger rowIndex = [_pickerView selectedRowInComponent:0];
                bookmark.bookmarkSubject = [self subjectTitleAtIndex:rowIndex];
                bookmark.bookmarkDate = _date.text;
            }
            [manager addBookmark:bookmark];
        }
        else if(_segueType == e_SegueTypeEdit)
        {
            if(self.bookmark.text.length == 0  || _date.text.length == 0)
            {
                Utils* utils = [[Utils alloc] init];
                [utils showAlertWithCode:eAlarmMessageFieldsDoesntFilled];
                if(self.bookmark.text.length == 0) _bookmarks.bookmarkDescription = @"Новая заметка";
                else _bookmarks.bookmarkDescription = self.bookmark.text;
                NSInteger rowIndex = [_pickerView selectedRowInComponent:0];
                _bookmarks.bookmarkSubject = [self subjectTitleAtIndex:rowIndex];
                if(_date.text.length == 0) _bookmarks.bookmarkDate = @"...";
                else _bookmarks.bookmarkDate = _date.text;
            }
            else
            {
                _bookmarks.bookmarkDescription = _bookmark.text;
                NSInteger rowIndex = [_pickerView selectedRowInComponent:0];
                _bookmarks.bookmarkSubject = [self subjectTitleAtIndex:rowIndex];
                _bookmarks.bookmarkDate = _date.text;
            }
            [manager saveBookmarks];
        }
        [self dismissKeyboard];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void) setSelectedRow:(NSInteger)selectedRow
{
    _selectedRow = selectedRow;
}

//--------------------------------------------------------------------------------------------------
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 320, 0.0);
    _selectedField = textView;
    NSInteger fieldY = _selectedField.frame.origin.y;
    NSInteger filedH = _selectedField.frame.size.height;
    NSInteger kbY = _keyboardScreenRect.origin.y;
    NSInteger kbH = _keyboardScreenRect.size.height/2;
    NSInteger delta = abs(fieldY - filedH - kbY - kbH)/2;

    if(_contentView.center.y == _contentDefaultYPos)
        [self moveView:_contentView toPoint:(CGPoint){_contentView.center.x, _contentView.center.y - delta + 30} withDuration:0.3 andDelay:0];
    if(_pickerView.center.y == _pickerDefaultYPos)
        [self moveView:_pickerView toPoint:(CGPoint){_pickerView.center.x, _pickerView.center.y - delta} withDuration:0.3 andDelay:0];
    moved = true;
}


- (IBAction)editingBegin:(UITextField *)sender {
    _scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 320, 0.0);
    _selectedField = sender;
    
    NSInteger fieldY = _selectedField.frame.origin.y;
    NSInteger filedH = _selectedField.frame.size.height;
    NSInteger kbY = _keyboardScreenRect.origin.y;
    NSInteger kbH = _keyboardScreenRect.size.height/2;
    NSInteger delta = abs(fieldY - filedH - kbY - kbH);

    if(_contentView.center.y == _contentDefaultYPos)
        [self moveView:_contentView toPoint:(CGPoint){_contentView.center.x, _contentView.center.y - delta - 45} withDuration:0.3 andDelay:0];
    if(_pickerView.center.y == _pickerDefaultYPos)
        [self moveView:_pickerView toPoint:(CGPoint){_pickerView.center.x, _pickerView.center.y - _keyboardScreenRect.size.height} withDuration:0.3 andDelay:0];
    moved = true;

}

- (void) recive:(NSArray*) array fromView:(BookmarksViewController*) view
{
    _bookmarks = [array objectAtIndex:0];
    _segueType = e_SegueTypeEdit;
}

#pragma mark Scrolling defenitions
//--------------------------------------------------------------------------------------------------
- (void)keyboardWillShowNotification:(NSNotification *)aNotification
{
    _scrollView.scrollEnabled = true;
    _keyboardScreenRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

//--------------------------------------------------------------------------------------------------
-(void)keyboardWillHideNotification:(NSNotification *)aNotification
{
    [self moveView:_contentView toPoint:(CGPoint){self.view.center.x, _contentDefaultYPos} withDuration:0.3 andDelay:0];
    [self moveView:_pickerView  toPoint:(CGPoint){self.view.center.x, _pickerDefaultYPos} withDuration:0.3 andDelay:0];
    moved = false;
}


#pragma marc PickerView delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    AMTableClasses* classes = [AMTableClasses defaultTable];
    return [classes.classesSet.allObjects objectAtIndex:row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    AMTableClasses* classes = [AMTableClasses defaultTable];
    return classes.classesSet.count;
}

#pragma marc Utils

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

#pragma mark Animations

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
