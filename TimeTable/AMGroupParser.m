//
//  AMGroupParser.m
//  TimeTable
//
//  Created by Andrew Medvedev on 03.09.15.
//  Copyright (c) 2015 Andrew Medvedev. All rights reserved.
//

#import "AMGroupParser.h"
#import "Group.h"

@interface AMGroupParser ()
@property (assign, nonatomic) NSInteger status;
@property (strong, nonatomic) NSMutableArray* groups;
@property (strong, nonatomic) Group* group;
@end


@implementation AMGroupParser

- (instancetype)init
{
    self = [super init];
    if (self) {
        _groups = [[NSMutableArray alloc] init];
    }
    return self;
}

//---------------------------------------------------------------------------------------------------------------------
- (void) parserDidStartDocument:(NSXMLParser *)parser {
    _status = GroupXMLParserReadFileStatusNULL;
    NSLog(@"[AMXMLParser]: START PARSE");
}

//---------------------------------------------------------------------------------------------------------------------
- (void) parserDidEndDocument:(NSXMLParser *)parser {
    if([self.deleage respondsToSelector:@selector(parserFinishedWithGroups:)])
        [self.deleage parserFinishedWithGroups:self.groups];
    NSLog(@"[AMXMLParser]: PARSE DONE");
}

//---------------------------------------------------------------------------------------------------------------------
-(void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if([self.deleage respondsToSelector:@selector(parserFinishedWithFail)])
        [self.deleage parserFinishedWithFail];
    NSLog(@"%@", [parseError userInfo]);
}

//---------------------------------------------------------------------------------------------------------------------
- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if([elementName  isEqualToString:kId]) {
        self.status = (NSInteger)GroupXMLParserId;
        return;
    }
    if([elementName isEqualToString:kGroup]) {
        self.status = (NSInteger)GroupXMLParserGroup;
        return;
    }
    
    self.status = GroupXMLParserReadFileStatusNULL;
    
    if([elementName isEqualToString: kBeginGroup]) {
        self.group = [[Group alloc]init];
    }
}

//--------------------------------------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if([elementName isEqualToString:@"studentGroup"])
        [self.groups addObject:self.group];
}


//--------------------------------------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if(_status == GroupXMLParserId)
        self.group.groupId = [string integerValue];
    if(_status == GroupXMLParserGroup)
        self.group.groupNumber = string;
}

@end
