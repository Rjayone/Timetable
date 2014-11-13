//
//  NewBookmarkView.m
//  TimeTable
//
//  Created by Admin on 07.09.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

//----------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
{
    [_date resignFirstResponder];
    [self.description resignFirstResponder];
    [_subject resignFirstResponder];
}

//----------------------------------------------------------------------------------------------------------------------
- (IBAction)actionAddBookmark:(UIButton*)sender
{
    if(self.description.text.length == 0 || _subject.text.length == 0 || _date.text.length == 0)
    {
        Utils* utils = [[Utils alloc] init];
        [utils showAlertWithCode:eAlarmMessageFieldsDoesntFilled];
        return;
    }
    
    Bookmarks* bookmark = [[Bookmarks alloc] init];
    bookmark.bookmarkDescription = self.description.text;
    bookmark.bookmarkSubject = _subject.text;
    bookmark.bookmarkDate = _date.text;
    
    BookmarksManager* manager = [BookmarksManager currentBookmarks];
    [manager addBookmark:bookmark];
    [self dismissKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
    
    self.title = @"Добавить";
}

//----------------------------------------------------------------------------------------------------------------------
- (void) recive:(NSArray*) array fromView:(BookmarksViewController*) view
{
    self.description.text = (NSString*)[array objectAtIndex:0];
    _subject.text = (NSString*)[array objectAtIndex:1];
    _date.text = (NSString*)[array objectAtIndex:2];
}


@end
