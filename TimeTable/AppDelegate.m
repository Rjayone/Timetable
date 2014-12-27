//
//  AppDelegate.m
//  TimeTable
//
//  Created by Admin on 18.08.14.
//  Copyright (c) 2014 Andrew Medvedev. All rights reserved.
//

#import "AppDelegate.h"
#import "AMTableClasses.h"
#import "Utils.h"
#import "ClassesNotification.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{  
    [self askAlertPermissions];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    return YES;
}

- (void) askAlertPermissions;
{
    ///iOS 8
    UIDevice *device = [UIDevice currentDevice];
    if([device.systemVersion integerValue] >= 8)
    {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
}

@end
