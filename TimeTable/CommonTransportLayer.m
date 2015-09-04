//
//  CommonTransportLayer.m
//  TimeTable
//
//  Created by Andrew Medvedev on 03.09.15.
//  Copyright (c) 2015 Andrew Medvedev. All rights reserved.
//

#import "CommonTransportLayer.h"

@interface CommonTransportLayer()
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@end

@implementation CommonTransportLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.manager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[NSURL URLWithString:kBSUIRURLSchedule]];
    }
    return self;
}

//-----------------------------------------------------------------
- (void)groupsListWithSuccess:(SuccessWithData) success
                   AndFailure:(FailureBlock) failure {

    NSString* url = [NSString stringWithFormat:@"%@studentGroup", kBSUIRURLSchedule];
    NSOperation* queue = [NSBlockOperation blockOperationWithBlock:^(void){
        NSData* groups = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        success(groups);
    }];
    queue.completionBlock = ^(void){
        NSLog(@"group load done");
    };
    //[[NSOperationQueue currentQueue] addOperation:queue];
    [queue start];
}

//-----------------------------------------------------------------
- (void)timetableForGroupId:(NSInteger) groupId
                    success:(SuccessWithData) success
                    failure:(FailureBlock) failure {
    
    NSString* url = [NSString stringWithFormat:@"%@schedule/%@",kBSUIRURLSchedule, @(groupId)];
    NSOperation* queue = [NSBlockOperation blockOperationWithBlock:^(void){
        NSData* groups = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        success(groups);
    }];
    //[[NSOperationQueue currentQueue] addOperation:queue];
    [queue start];
}

@end
