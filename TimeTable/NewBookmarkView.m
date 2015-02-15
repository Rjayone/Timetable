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

@implementation NewBookmarkView

- (void) viewDidLoad
{
    [super viewDidLoad];
    //устанавливаем закругленные края у кнопки
    _addButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    _addButton.layer.borderWidth = 1.0f;
    _addButton.layer.cornerRadius = 7;
    
    //_bookmark.frame = CGRectMake(0, 0, 200, 200);
    
    if(_segueType == e_SegueTypeNew)
    {
        [_addButton setTitle:@"Добавить" forState: UIControlStateNormal];
    }
    if(_segueType == e_SegueTypeEdit)
    {
        [_addButton setTitle:@"Сохранить" forState: UIControlStateNormal];
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
        _subject.text  = _bookmarks.bookmarkSubject;
        _date.text     = _bookmarks.bookmarkDate;
    }
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [_scrollView setScrollEnabled:YES];
    _scrollView.contentSize = CGSizeMake(320.0f, 200.0f);
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 300, 0.0);
    _scrollView.contentInset = contentInsets;
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
    [_date resignFirstResponder];
    [_bookmark resignFirstResponder];
    [_subject resignFirstResponder];
}

//--------------------------------------------------------------------------------------------------
- (IBAction)beginEdit:(UITextField *)sender
{
    
}

//--------------------------------------------------------------------------------------------------
- (IBAction)actionAddBookmark:(UIButton*)sender
{
    if(_segueType == e_SegueTypeNew)
    {
        if(self.bookmark.text.length == 0 || _subject.text.length == 0 || _date.text.length == 0)
        {
            Utils* utils = [[Utils alloc] init];
            [utils showAlertWithCode:eAlarmMessageFieldsDoesntFilled];
            return;
        }
        
        Bookmarks* bookmark = [[Bookmarks alloc] init];
        bookmark.bookmarkDescription = self.bookmark.text;
        bookmark.bookmarkSubject = _subject.text;
        bookmark.bookmarkDate = _date.text;
        
        BookmarksManager* manager = [BookmarksManager currentBookmarks];
        [manager addBookmark:bookmark];
    }
    if(_segueType == e_SegueTypeEdit)
    {
        if(self.bookmark.text.length == 0 || _subject.text.length == 0 || _date.text.length == 0)
        {
            Utils* utils = [[Utils alloc] init];
            [utils showAlertWithCode:eAlarmMessageFieldsDoesntFilled];
            return;
        }
        
        _bookmarks.bookmarkDescription = _bookmark.text;
        _bookmarks.bookmarkSubject = _subject.text;
        _bookmarks.bookmarkDate = _date.text;
    }
    [self dismissKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
}

//--------------------------------------------------------------------------------------------------
- (void) recive:(NSArray*) array fromView:(BookmarksViewController*) view
{
    _bookmarks = [array objectAtIndex:0];
    _segueType = e_SegueTypeEdit;
}

#pragma mark Scrolling defenitions

- (void)scrollToTextField:(UIView *)ui
{
    [_scrollView setContentOffset:(CGPoint){0, 60} animated:YES];
}

//--------------------------------------------------------------------------------------------------
- (void)resetScrollView {
    [_scrollView setContentOffset:(CGPoint){0, 0}animated:YES];
}

//--------------------------------------------------------------------------------------------------
- (void)keyboardWillShowNotification:(NSNotification *)aNotification
{
    _scrollView.scrollEnabled = true;
    CGRect keyboardScreenRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height += CGRectGetHeight(keyboardScreenRect);
    self.scrollView.contentSize = contentSize;
    
    //[self scrollToTextField:_date];
}

//--------------------------------------------------------------------------------------------------
-(void)keyboardWillHideNotification:(NSNotification *)aNotification
{
    _scrollView.scrollEnabled = false;
    
    UIDevice* device = [UIDevice currentDevice];
    if([device.model isEqualToString:@"iPhone"])
    {
        
    }
    
    CGRect keyboardScreenRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height -= CGRectGetHeight(keyboardScreenRect);
    self.scrollView.contentSize = contentSize;
    [self resetScrollView];
}

@end
