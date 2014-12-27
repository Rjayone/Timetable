//
//  StartupView.h
//  TimeTable
//
//  Created by Admin on 23.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartupView : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *GroupNumberField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SubgroupControl;
@property (weak, nonatomic) IBOutlet UIButton *ContinueButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)actionContinue:(UIButton *)sender;
- (IBAction)actionDidTouchInside:(UITextField* )sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSThread* thread;
@end
