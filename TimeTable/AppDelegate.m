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
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    return YES;
}

- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
//    NSLog(@"Fetch");
   AMTableClasses* classes = [AMTableClasses defaultTable];
//    Utils* utils = [[Utils alloc] init];
//    if(!classes)
//        return;
//    
    [classes ReadUserData];
    if(classes.classes.count < 1)
        return;
//    
    NSArray* currentClasse = [classes GetCurrentDayClasses];
//    for(AMClasses* i in currentClasse)
//    {
//        NSString* endTime = [utils timePeriodEnd:i.timePeriod];
//        NSDateComponents* endTimeDate = [utils dateComponentsWithTime:endTime];
//        NSCalendar* calendar =[[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
//        NSDateComponents* dateComp = [calendar components:(NSCalendarUnitWeekday | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:[NSDate date]];
//        
//        
//        if(dateComp.hour == endTimeDate.hour && dateComp.minute == endTimeDate.minute - 5)
//        {
//            UILocalNotification* notif = [[UILocalNotification alloc] init];
//            notif.fireDate = [NSDate date];
//            notif.alertBody = [i stringForNotification];
//            [[UIApplication sharedApplication] scheduleLocalNotification:notif];
//         }
//    }
    
    ClassesNotification* notif = [[ClassesNotification alloc] init];
    [notif registerNotificationForToday:currentClasse];
}

- (void) askAlertPermissions;
{
    //iOS 8
//    [[UIApplication sharedApplication] ]
//    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
//    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
}

@end
