//
//  NewBookmarkView.h
//  TimeTable
//
//  Created by Admin on 07.09.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BookmarksViewController;

@interface NewBookmarkView : UIViewController <UITextFieldDelegate>


//Окно добавления заметки
@property (weak, nonatomic) IBOutlet UITextField *description;
@property (weak, nonatomic) IBOutlet UITextField *subject;
@property (weak, nonatomic) IBOutlet UITextField *date;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *BookmarkNavigationItem;

- (IBAction)actionAddBookmark:(UIButton*)sender;

- (void) recive:(NSArray*) array fromView:(BookmarksViewController*) view;
@end
