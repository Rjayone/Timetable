//
//  TimeTableEditView.h
//  TimeTable
//
//  Created by Admin on 10.09.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMClasses.h"

@interface TimeTableEditView : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *subject;
@property (weak, nonatomic) IBOutlet UITextField *time;
@property (weak, nonatomic) IBOutlet UITextField *auditory;
@property (weak, nonatomic) IBOutlet UITextField *week;
@property (weak, nonatomic) IBOutlet UISegmentedControl *subgroup;
@property (weak, nonatomic) IBOutlet UISegmentedControl *subjectType;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property(strong, nonatomic) AMClasses* classes;

- (IBAction)onSave:(UIButton *)sender;
- (IBAction)textFieldDidBeginEditing:(UITextField *)textField;

- (void) reciveArray:(NSArray*) array;
@end
