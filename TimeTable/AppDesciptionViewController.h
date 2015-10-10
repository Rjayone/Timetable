//
//  AppDesciptionViewController.h
//  TimeTable
//
//  Created by Andrew Medvedev on 29.08.15.
//  Copyright (c) 2015 Andrew Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface AppDesciptionViewController : UIViewController
- (IBAction)actionClosePopUp:(UIButton *)sender;

@property (strong, nonatomic) ViewController* parent;

@end
