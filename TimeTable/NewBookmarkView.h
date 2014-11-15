//
//  NewBookmarkView.h
//  TimeTable
//
//  Created by Admin on 07.09.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookmarksViewController.h"

//Определяет статус перехода
NS_ENUM(NSInteger, ESegueType)
{
    e_SegueTypeNULL,
    e_SegueTypeNew,
    e_SegueTypeEdit
};

@interface NewBookmarkView : UIViewController <UITextFieldDelegate>
//Окно добавления заметки
@property (weak, nonatomic) IBOutlet UITextField *bookmark;
@property (weak, nonatomic) IBOutlet UITextField *subject;
@property (weak, nonatomic) IBOutlet UITextField *date;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *BookmarkNavigationItem;
@property (strong, nonatomic) Bookmarks* bookmarks;

@property (assign, nonatomic) NSInteger segueType;
@property (assign, nonatomic) NSInteger selectedRow;

- (IBAction)actionAddBookmark:(UIButton*)sender;
- (void) recive:(NSArray*) array fromView:(BookmarksViewController*) view;
@end
