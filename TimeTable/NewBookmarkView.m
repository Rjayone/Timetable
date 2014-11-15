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
    //устанавливаем закругленные края у кнопки
    _addButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    _addButton.layer.borderWidth = 1.0f;
    _addButton.layer.cornerRadius = 7;
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
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    if(_bookmarks)
    {
        _bookmark.text = _bookmarks.bookmarkDescription;
        _subject.text  = _bookmarks.bookmarkSubject;
        _date.text     = _bookmarks.bookmarkDate;
    }
}

//----------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
{
    [_date resignFirstResponder];
    [self.bookmark resignFirstResponder];
    [_subject resignFirstResponder];
}

//----------------------------------------------------------------------------------------------------------------------
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

//----------------------------------------------------------------------------------------------------------------------
- (void) recive:(NSArray*) array fromView:(BookmarksViewController*) view
{
    _bookmarks = [array objectAtIndex:0];
    _segueType = e_SegueTypeEdit;
}


@end
