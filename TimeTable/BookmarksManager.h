//
//  BookmarksManager.h
//  TimeTable
//
//  Created by Admin on 07.09.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Bookmarks;


static NSString* kBMDescription = @"Description";
static NSString* kBMSubject = @"Subject";
static NSString* kBMDate = @"Date";

@interface BookmarksManager : NSObject

@property (strong, nonatomic, readonly) NSMutableArray* bookmarks;

+ (instancetype) currentBookmarks;
- (void) addBookmark:(Bookmarks*) bookmark;
- (void) deleteBookmark:(Bookmarks*) bookmark;

- (void) saveBookmarks;
- (void) readBookmarks;


- (NSInteger) bookmarksCount;

@end
