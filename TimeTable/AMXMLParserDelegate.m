//
//  AMXMLParserDelegate.m
//  TimeTable
//
//  Created by Admin on 19.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import "AMXMLParserDelegate.h"
#import "AMTableClasses.h"

@implementation AMXMLParserDelegate

//---------------------------------------------------------------------------------------------------------------------
- (void) parserDidStartDocument:(NSXMLParser *)parser {
    _done = NO;
    NSLog(@"[AMXMLParser]: START PARSE");
}

//---------------------------------------------------------------------------------------------------------------------
- (void) parserDidEndDocument:(NSXMLParser *)parser {
    _done = YES;
    NSLog(@"[AMXMLParser]: PARSE DONE");
}

//---------------------------------------------------------------------------------------------------------------------
-(void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    _done = YES;
    NSLog(@"%@",[parseError userInfo]);
}


//---------------------------------------------------------------------------------------------------------------------
- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    AMTableClasses* classesTable = [AMTableClasses defaultTable];
    AMClasses* classes = [[AMClasses alloc] init];
    
    if([attributeDict  valueForKey:kSubject] == nil)
        return;
    
    classes.subject     = [attributeDict  valueForKey:kSubject];
    classes.auditorium  = [attributeDict  valueForKey:kAuditorium];
    classes.teacher     = [attributeDict  valueForKey:kTeacher];
    classes.timePeriod  = [attributeDict  valueForKey:kTimePeriod];
    classes.subjectType = [self integerSubjectType:[attributeDict valueForKey:kSubjectType]];
    classes.weekDay     = [self integerWeekDay:[attributeDict valueForKey:kWeekDay]];
    classes.weekList    = [self integerWeekBField:[attributeDict valueForKey:kWeekList]];
    classes.subgroup    = [[attributeDict valueForKey:kSubgroup] integerValue];
    [classesTable AddClasses:classes];
}

//---------------------------------------------------------------------------------------------------------------------
- (NSInteger) integerSubjectType: (NSString*) type
{
    if([[type lowercaseString] isEqualToString:@"лк"])
    {
        return eClassType_Lecture;
    }
    else if([[type lowercaseString] isEqualToString:@"пз"])
    {
        return eClassType_Practical;
    }
    else
    {
        return eClassType_Lab;
    }
}

//---------------------------------------------------------------------------------------------------------------------
- (NSInteger) integerWeekDay: (NSString*) day
{
    if([[day lowercaseString] isEqualToString:@"пн"])
        return eMonday;
    if([[day lowercaseString] isEqualToString:@"вт"])
        return eTuesday;
    if([[day lowercaseString] isEqualToString:@"ср"])
        return eWednesday;
    if([[day lowercaseString] isEqualToString:@"чт"])
        return eThursday;
    if([[day lowercaseString] isEqualToString:@"пт"])
        return eFriday;
    if([[day lowercaseString] isEqualToString:@"сб"])
        return eSaturday;
    return 0;
}

//---------------------------------------------------------------------------------------------------------------------
- (NSInteger) integerWeekBField: (NSString*) day
{
    NSInteger flags = 0;
    ///iOS8
//    if([day containsString:@"1"])
//        flags |= eFirstWeek;
//    if([day containsString:@"2"])
//        flags |= eSecondWeek;
//    if([day containsString:@"3"])
//        flags |= eThirdWeek;
//    if([day containsString:@"4"])
//        flags |= eFourthWeek;
    
    if([day rangeOfString:@"1"].location != NSNotFound)
        flags |= eFirstWeek;
    if([day rangeOfString:@"2"].location != NSNotFound)
            flags |= eSecondWeek;
    if([day rangeOfString:@"3"].location != NSNotFound)
         flags |= eThirdWeek;
    if([day rangeOfString:@"4"].location != NSNotFound)
        flags |= eFourthWeek;
    
    if ([day isEqualToString:@""])
        flags = eEveryWeek;
    return flags;
}
@end
