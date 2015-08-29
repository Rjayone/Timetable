//
//  AppDesciptionViewController.m
//  TimeTable
//
//  Created by Andrew Medvedev on 29.08.15.
//  Copyright (c) 2015 Andrew Medvedev. All rights reserved.
//

#import "AppDesciptionViewController.h"

@interface AppDesciptionViewController ()

@end

@implementation AppDesciptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (IBAction)actionClosePopUp:(UIButton *)sender {
    [self.parent dismissPopUp];
}
@end
