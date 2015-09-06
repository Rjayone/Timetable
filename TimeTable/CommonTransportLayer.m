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

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^{
        NSString* url = [NSString stringWithFormat:@"%@studentGroup", kBSUIRURLSchedule];
        NSLog(@"[Group list]: %@", url);
        NSData* groups = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        if(!groups)
            failure(-1);
        success(groups);
    });
}

//-----------------------------------------------------------------
- (void)timetableForGroupId:(NSInteger) groupId
                    success:(SuccessWithData) success
                    failure:(FailureBlock) failure {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^{
        NSString* url = [NSString stringWithFormat:@"%@schedule/%@",kBSUIRURLSchedule, @(groupId)];
        NSLog(@"[Timetable]: %@", url);
        NSData* groups = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        if(!groups)
            failure(-1);
        
        success(groups);
    });
}

@end
