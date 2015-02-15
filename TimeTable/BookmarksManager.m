//
//  BookmarksManager.m
//  TimeTable
//
//  Created by Admin on 07.09.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import "BookmarksManager.h"
#import "Bookmarks.h"

#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

static BookmarksManager* sBookmarkManager;

@implementation BookmarksManager

+ (instancetype) currentBookmarks
{
    if(sBookmarkManager == nil)
        sBookmarkManager = [[BookmarksManager alloc] init];
    return sBookmarkManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _bookmarks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) addBookmark:(Bookmarks*) bookmark
{
    [_bookmarks addObject:bookmark];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"BookmarksShouldUpdate" object:nil];
    
    [self saveBookmarks];
}

- (void) deleteBookmark:(Bookmarks*) bookmark
{
}

- (NSInteger) bookmarksCount
{
    return _bookmarks.count;
}

- (void) saveBookmarks
{
    NSString *docPath  = [DOCUMENTS stringByAppendingPathComponent:@"UserBookmarks.plist"];
    NSMutableArray* items = [[NSMutableArray alloc] init];
    for(Bookmarks* i in _bookmarks)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject: i.bookmarkDescription forKey:kBMDescription];
        [dict setObject: i.bookmarkSubject     forKey:kBMSubject];
        [dict setObject: i.bookmarkDate        forKey:kBMDate];
        [items addObject: dict];
    }
    [items writeToFile:docPath atomically:YES];
}

- (void) readBookmarks
{
    NSString *filePath = [DOCUMENTS stringByAppendingPathComponent:@"UserBookmarks.plist"];
    NSMutableArray* userDataArray = [[NSMutableArray alloc] initWithContentsOfFile: filePath];
    
    [_bookmarks removeAllObjects];
    for(int i = 0; i < userDataArray.count; i++)
    {
        Bookmarks* bookmark = [[Bookmarks alloc] init];
        bookmark.bookmarkDescription = [[userDataArray objectAtIndex:i] valueForKey:kBMDescription];
        bookmark.bookmarkSubject = [[userDataArray objectAtIndex:i] valueForKey:kBMSubject];
        bookmark.bookmarkDate = [[userDataArray objectAtIndex:i] valueForKey:kBMDate];
        [self addBookmark:bookmark];
    }
}

@end
