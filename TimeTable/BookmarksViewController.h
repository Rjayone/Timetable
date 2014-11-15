//
//  BookmarksViewController.h
//  TimeTable
//
//  Created by Admin on 07.09.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Bookmarks;
@class BookmarksManager;

@interface BookmarksViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *message;
@property (strong, nonatomic) BookmarksManager* manager;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionAddBookmark;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) NSInteger selectedRow;
@end



//=====================================================================================================================
@interface BookmarkTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* description;
@property (weak, nonatomic) IBOutlet UILabel *subject;
@property (weak, nonatomic) IBOutlet UILabel *date;

@end