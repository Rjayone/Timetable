//
//  BookmarksViewController.m
//  TimeTable
//
//  Created by Admin on 07.09.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import "BookmarksViewController.h"
#import "CustomCells.h"
#import "Bookmarks.h"
#import "BookmarksManager.h"
#import "NewBookmarkView.h"

@implementation BookmarkTableViewCell
@synthesize description, subject, date;
@end


@implementation BookmarksViewController

- (void) dealloc
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

//-----------------------------------------------------------------------------------------------------------
- (void) viewDidLoad
{
    [super  viewDidLoad];
    _manager = [BookmarksManager currentBookmarks];
    [_manager readBookmarks];
    
    NSNotificationCenter* notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(shouldUpdateTableView) name:@"BookmarkCell" object:nil];
    
    [self updateBackgroundColor];
}

//-------------------------------------------------------------------------------------------------------------------
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([_manager bookmarksCount] == 0)
        [_message setHidden:NO];
    else [_message setHidden:YES];
    
    [_tableView reloadData];
    [self updateBackgroundColor];
}

//-------------------------------------------------------------------------------------------------------------
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_manager bookmarksCount];
}

//-------------------------------------------------------------------------------------------------------------
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Bookmarks* bookmark =  [_manager.bookmarks objectAtIndex: [indexPath row]];
    BookmarkTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkCell" forIndexPath:indexPath];
    
    cell.description.text = bookmark.bookmarkDescription;
    cell.subject.text = bookmark.bookmarkSubject;
    cell.date.text = bookmark.bookmarkDate;
    return cell;
}

//-------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = indexPath.row;
}

//-------------------------------------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

//-------------------------------------------------------------------------------------------------------------
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSArray* ar = [NSArray arrayWithObject:indexPath];
        [_manager.bookmarks removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:ar withRowAnimation:UITableViewRowAnimationFade];
        
        [_manager saveBookmarks];
        [self updateBackgroundColor];
        
        if([_manager bookmarksCount] == 0)
        {
            [_message setHidden:NO];
        }
        else
        {
            [_message setHidden:YES];
        }
        [self updateBackgroundColor];
    }
}

//-------------------------------------------------------------------------------------------------------------
- (void) shouldUpdateTableView
{
    [_tableView reloadData];
}

//-------------------------------------------------------------------------------------------------------------
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NewBookmarkView* BookmarkView = segue.destinationViewController;
    BookmarksManager* bm = [BookmarksManager currentBookmarks];
    BookmarkTableViewCell* cell = (BookmarkTableViewCell*)sender;
    NSIndexPath* pathOfTheCell = [_tableView indexPathForCell:cell];
    _selectedRow = pathOfTheCell.row;
    
	if ([segue.identifier isEqualToString:@"CellShowDefinedInfo"])
	{
        Bookmarks* bookmark = [bm.bookmarks objectAtIndex:_selectedRow];
        NSArray* array = [[NSArray alloc] initWithObjects:
                          bookmark,
                          nil];
        
        [BookmarkView recive:array fromView:self];
        [BookmarkView setSelectedRow: _selectedRow];
	}
    //При создании новой заметки
    if ([segue.identifier isEqualToString:@"AddNewBookmark"])
    {
        [BookmarkView setSegueType:e_SegueTypeNew];
    }
}

//------------------------------------------------------------------------------------------------------
- (void) updateBackgroundColor
{
    if(_manager.bookmarksCount == 0)
    {
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        _tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Удалить";
}

@end
