//
//  AppDelegate.m
//  RutasDeTenerife2
//
//  Created by javi on 12/11/15.
//  Copyright © 2015 JAVI. All rights reserved.
//

#import "AppDelegate.h"
#import "iRate.h"
#import <Google/Analytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)initialize
{
    //set the bundle ID. normally you wouldn't need to do this
    //as it is picked up automatically from your Info.plist file
    //but we want to test with an app that's actually on the store
    [iRate sharedInstance].applicationBundleID = @"com.charcoaldesign.rainbowblocks-free";
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO; //***TODO change to YES
    [iRate sharedInstance].daysUntilPrompt = 3;
    [iRate sharedInstance].usesUntilPrompt = 7;
    [iRate sharedInstance].remindPeriod = 7;
    //enable preview mode
    [iRate sharedInstance].previewMode = YES;   //***TODO change to NO
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //GOOGLE ANALYTICS
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    [gai setDryRun:YES];
    gai.logger.logLevel = kGAILogLevelVerbose;  // ***TODO remove before app release
    
    [self createCopyOfDatabaseIfNeeded];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:@"distance"];
    [defaults setInteger:0 forKey:@"dific"];
    [defaults setInteger:0 forKey:@"durac"];
    [defaults synchronize];
}

-(void)createCopyOfDatabaseIfNeeded{
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appDBPath = [documentsDirectory stringByAppendingString:@"/BDRutas"];
    success = [fileManager fileExistsAtPath:appDBPath];
    if (!success){
        //database doesn`t exist
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"BDRutas"];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:appDBPath error:&error];
        if (!success)
            NSAssert1(0, @"Failed to create database file: %@", [error localizedDescription]);
        else
            NSLog(@"Database created %@", defaultDBPath);
    }else
        NSLog(@"Database %@ does exist",appDBPath);
}

@end
