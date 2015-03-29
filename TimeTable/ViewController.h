//
//  ViewController.h
//  TimeTable
//
//  Created by Admin on 18.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMSettings.h"


NS_ENUM(NSInteger, EParamsViewStatus)
{
    eViewStatus_StudyWeek,
    eViewStatus_GroupParams
};

//Перечисление типов сообщений.
NS_ENUM(NSInteger, EAuxMessageType)
{
    eMessageTypeSunday,
    eMessageTypeNoClasses,
    eMessageTypeHoliday,
    eMessageTypeDownloading
};

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,UIScrollViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) AMSettings* settings;
@property (assign, nonatomic) BOOL weekDayDidChanged;
@property (assign, nonatomic) BOOL performDelete;

//UI
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *CurrentDay;
@property (weak, nonatomic) IBOutlet UINavigationItem *NavigationBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//messages
@property (weak, nonatomic) IBOutlet UILabel *timeMessage;
@property (weak, nonatomic) IBOutlet UILabel *timeValue;
@property (weak, nonatomic) IBOutlet UILabel *Message;
@property (weak, nonatomic) IBOutlet UIImageView *clockImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (assign, nonatomic) BOOL isDownloading;

- (IBAction)actionWeekDayDidChanged:(UISegmentedControl *)sender;
- (void) actionSwipeLeft:(UISwipeGestureRecognizer*) swipe;
- (void) actionSwipeRight:(UISwipeGestureRecognizer*) swipe;
- (IBAction)actionEditTimeTable:(UIBarButtonItem *)sender;
@end

