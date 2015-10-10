//
//  CommonTransportLayer.h
//  TimeTable
//
//  Created by Andrew Medvedev on 03.09.15.
//  Copyright (c) 2015 Andrew Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@interface CommonTransportLayer : NSObject

typedef void(^SuccessWithDictionary)(NSDictionary*);
typedef void(^SuccessWithData)(NSData* xml);
typedef void(^FailureBlock)(NSInteger statusCode);

- (void)groupsListWithSuccess:(SuccessWithData) success
                   AndFailure:(FailureBlock) failure;

- (void)timetableForGroupId:(NSInteger) groupId
                    success:(SuccessWithData) success
                    failure:(FailureBlock) failure;
@end
