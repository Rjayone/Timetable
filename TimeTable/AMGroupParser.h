//
//  AMGroupParser.h
//  TimeTable
//
//  Created by Andrew Medvedev on 03.09.15.
//  Copyright (c) 2015 Andrew Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMGroupParserDelegate <NSObject>
- (void)parserFinishedWithGroups:(NSArray*) groups;
- (void)parserFinishedWithFail;
@end


/*
 
 <studentGroup>
 <id>21411</id>
 <name>560801</name>
 <course>1</course>
 <facultyId>20040</facultyId>
 <specialityDepartmentEducationFormId>20103</specialityDepartmentEducationFormId>
 </studentGroup>
 
 */

static NSString* kId             = @"id";
static NSString* kGroup          = @"name";
static NSString* kBeginGroup     = @"studentGroup";


typedef NS_ENUM(NSUInteger, EGroupXMLParser){
    GroupXMLParserReadFileStatusNULL,
    GroupXMLParserId,
    GroupXMLParserGroup
};


@interface AMGroupParser : NSObject <NSXMLParserDelegate>

@property (weak, nonatomic) id<AMGroupParserDelegate> deleage;

@end
