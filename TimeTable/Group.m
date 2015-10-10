//
//  Group.m
//  TimeTable
//
//  Created by Andrew Medvedev on 03.09.15.
//  Copyright (c) 2015 Andrew Medvedev. All rights reserved.
//

#import "Group.h"

@implementation Group
- (instancetype)init
{
    self = [super init];
    if (self) {
        _groupId = 0;
        _groupNumber = @"";
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _groupNumber = [coder decodeObjectForKey:@"kGroupNumber"];
        _groupId     = [[coder decodeObjectForKey:@"kGroupId"]integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.groupId) forKey:@"kGroupId"];
    [aCoder encodeObject:self.groupNumber forKey:@"kGroupNumber"];
}

@end
