//
//  Common.m
//  TimeTable
//
//  Created by Andrew Medvedev on 03.09.15.
//  Copyright (c) 2015 Andrew Medvedev. All rights reserved.
//

#import "Common.h"
#import "AMSettings.h"
#import "Group.h"

@implementation Common

- (Group*)groupByGroupId:(NSInteger)groupId {
    for(Group* group in [[AMSettings currentSettings]groupsId])
        if(group.groupId == groupId)
            return group;
    return nil;
}

- (Group*)groupByGroupNumber:(NSString*)groupNumber {
    for(Group* group in [[AMSettings currentSettings]groupsId])
        if([group.groupNumber isEqualToString:groupNumber])
            return group;
    return nil;
}

@end
