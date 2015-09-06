//
//  Common.h
//  TimeTable
//
//  Created by Andrew Medvedev on 03.09.15.
//  Copyright (c) 2015 Andrew Medvedev. All rights reserved.
//

#import <Foundation/Foundation.h>

#define COLOR_Lab  [[UIColor alloc] initWithRed:255.f/255 green:50.f/255 blue:90.f/255 alpha:1];
#define COLOR_Prac [[UIColor alloc] initWithRed:20.f/255  green:130.f/255 blue:230.f/255 alpha:1];
#define COLOR_Lec  [[UIColor alloc] initWithRed:26.f/255  green:180.f/255 blue:100.f/255 alpha:1];
#define COLOR_Default  [[UIColor alloc] initWithRed:30.f/255  green:130.f/255 blue:230.f/255 alpha:1];

#define COLOR_CurrentClass [[UIColor alloc] initWithRed:20.f/255  green:130.f/255 blue:230.f/255 alpha:1];

#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

static NSString* const kBSUIRURLSchedule = @"http://www.bsuir.by/schedule/rest/";

@class UIColor;
@class TableViewCell;
@class Group;

#pragma  mark - AMTableClasses Defenitions

NS_ENUM(NSInteger, EDays)
{
    eMonday = 1,
    eTuesday,
    eWednesday,
    eThursday,
    eFriday,
    eSaturday,
    eSunday
};

NS_ENUM(NSInteger, EClassType)
{
    eClassType_Lab,
    eClassType_Lecture,
    eClassType_Practical
};

NS_ENUM(NSInteger, EWeeks)
{
    eFirstWeek  = 1,
    eSecondWeek = 1 << 1,
    eThirdWeek  = 1 << 2,
    eFourthWeek = 1 << 3,
    eEveryWeek = eFirstWeek & eSecondWeek & eThirdWeek & eFourthWeek
};




@interface Common : NSObject
- (Group*)groupByGroupId:(NSInteger)groupId;
- (Group*)groupByGroupNumber:(NSString*)groupNumber;
@end
