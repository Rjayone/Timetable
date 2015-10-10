//
//  SettingsGroup.h
//  TimeTable
//
//  Created by Andrew Medvedev on 27.03.15.
//  Copyright (c) 2015 Andrew Medvedev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AMSettings;

//Контроллер для вьюхи с выбором других гурпп
@interface SettingsGroup : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (assign, nonatomic) NSInteger selectedGroup;
@property (strong, nonatomic) AMSettings* settings;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


- (IBAction)addNewGroup:(UIBarButtonItem *)sender;

@end
