//
//  StartupView.h
//  TimeTable
//
//  Created by Admin on 23.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartupView : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *content;
@property (weak, nonatomic) IBOutlet UITextField *GroupNumberField;

- (void) actionContinue;
- (IBAction)didEditingEnd:(UITextField *)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSThread* thread;

//images
@property (strong,nonatomic) UIImage* logoImage;

//Animated images
@property (weak, nonatomic) IBOutlet UILabel *subgroup1;
@property (weak, nonatomic) IBOutlet UILabel *subgroup2;
@property (weak, nonatomic) IBOutlet UIImageView* logoView;
@property (weak, nonatomic) IBOutlet UIImageView* sliderBackground;
@property (weak, nonatomic) IBOutlet UIImageView* sliderSharp;
@property (weak, nonatomic) IBOutlet UIImageView* sliderSubgroup;
@property (weak, nonatomic) IBOutlet UILabel *subgroupMessage;

@end
