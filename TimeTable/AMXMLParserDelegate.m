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
    _day = eMonday;
    _status = e_ReadFileStatusNULL;
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
    NSLog(@"%@", [parseError userInfo]);
}


//---------------------------------------------------------------------------------------------------------------------
- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
   /* AMTableClasses* classesTable = [AMTableClasses defaultTable];
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
    */
    
    ///Если встречаем такой тег, то знаит нужно начать записать в объекь
    if([elementName isEqualToString: kBegin])
    {
        _shdClass = [[AMClasses alloc] init];
        [_shdClass Reset];
    }
    
    if([elementName isEqualToString: kAuditorium])
        {_status = e_ReadFieldStatusAuditory; return;}
    if([elementName isEqualToString: kFirstName])
        {_status = e_ReadFieldStatusEmployeeFN; return;}
    if([elementName isEqualToString: kMiddleName])
        {_status = e_ReadFieldStatusEmployeeMN; return;}
    if([elementName isEqualToString: kLastName])
        {_status = e_ReadFieldStatusEmployeeLN; return;}
    if([elementName isEqualToString: kTimePeriod])
        {_status = e_ReadFieldStatusLessonTime; return;}
    if([elementName isEqualToString: kSubjectType])
        {_status = e_ReadFieldStatusLessonType; return;}
    if([elementName isEqualToString: kSubgroup])
        {_status = e_ReadFieldStatusSubgroup; return;}
    if([elementName isEqualToString: kSubject])
        {_status = e_ReadFieldStatusSubject; return;}
    if([elementName isEqualToString: kWeekList])
        {_status = e_ReadFieldStatusWeekNumber; return;}
    if([elementName isEqualToString: kWeekDay])
        {_status = e_ReadFieldStatusWeekDay; return;}
    _status = e_ReadFileStatusNULL;
}

//--------------------------------------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString: kBegin])
    {
        AMTableClasses* classesTable = [AMTableClasses defaultTable];
        _shdClass.weekDay = _day;
        [classesTable AddClasses:_shdClass];
    }
    if([elementName isEqualToString: @"scheduleModel"])
    {
        _day++;
    }
}

//--------------------------------------------------------------------------------------------------------
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(_shdClass == NULL)
        return;
    
    if(_status == e_ReadFieldStatusAuditory)
    {
        _shdClass.auditorium = [_shdClass.auditorium stringByAppendingString:string];
    }
    
    ///Здесь можно скопировать то что было в строке - имя, вставить туда фамилию, затем имя и потом очтество
    if(_status == e_ReadFieldStatusEmployeeLN)
    {
        NSString* name = [[NSString alloc] initWithString:_shdClass.teacher];
        
        _shdClass.teacher = string;
        _shdClass.teacher = [_shdClass.teacher stringByAppendingString:@" "];
        _shdClass.teacher = [_shdClass.teacher stringByAppendingString:name];
    }

    if(_status == e_ReadFieldStatusEmployeeFN)
    {
        _shdClass.teacher = string;
        _shdClass.teacher = [_shdClass.teacher stringByAppendingString:@" "];
    }
    
    if(_status == e_ReadFieldStatusEmployeeMN)
    {
       _shdClass.teacher = [_shdClass.teacher stringByAppendingString:string];
    }
    
    
    if(_status == e_ReadFieldStatusLessonTime)
    {
        _shdClass.timePeriod = [_shdClass.timePeriod stringByAppendingString:string];
    }
    
    if(_status == e_ReadFieldStatusLessonType)
    {
        _shdClass.subjectType = [self integerSubjectType:string];
    }
    
    if(_status == e_ReadFieldStatusSubgroup)
    {
        //0 - общая
        //1 - первая
        //2 - вторая
        _shdClass.subgroup = [string integerValue];
    }
    
    if(_status == e_ReadFieldStatusSubject)
    {
        _shdClass.subject = string;
    }
    
    if(_status == e_ReadFieldStatusWeekNumber)
    {
        _shdClass.weekList += [self integerWeekBField:string];
    }
}

//--------------------------------------------------------------------------------------------------------
- (NSInteger) integerSubjectType: (NSString*) type
{
    if([type isEqualToString:@"ЛК"])
    {
        return eClassType_Lecture;
    }
    else if([type isEqualToString:@"ПЗ"])
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
