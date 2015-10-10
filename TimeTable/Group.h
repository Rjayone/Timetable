//
//  Group.h
//  TimeTable
//
//  Created by Andrew Medvedev on 03.09.15.
//  Copyright (c) 2015 Andrew Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject <NSCoding>

@property (assign, nonatomic) NSInteger groupId;
@property (copy, nonatomic)   NSString* groupNumber;

@end
