//
//  AppDelegate.m
//  plistTest3
//
//  Created by Jeremy Ayala on 9/18/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import "AppDelegate.h"
#import "FirstViewController.h"

@implementation AppDelegate
@synthesize databaseName, databasePath;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.databaseName = @"test.db";
   
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];

    databasePath = [documentDir stringByAppendingPathComponent:self.databaseName];
    
    self.database = [FMDatabase databaseWithPath:databasePath];
    
    //[self deleteDatabaseFromDocuments];
    [self copyDatabaseToDocuments];
    
    // Override point for customization after application launch.
    
    return YES;
}

-(void) copyDatabaseToDocuments
{
    BOOL exists;
   
    NSFileManager *fileManager = [NSFileManager defaultManager];
    exists = [fileManager fileExistsAtPath:databasePath];
    
    if(exists)
    {
        NSLog(@"DB already exists in documents directory");
    }
    else
    {
        NSLog(@"DB not found in documents directory!");
        
        NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseName];
        
        BOOL copySuccess = [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
        if (copySuccess)
        {
            NSLog(@"DB copied to documents directory");
        }
        else
        {
            NSLog(@"DB not copied to documents directory!");
        }
    }
    
}

-(void) deleteDatabaseFromDocuments
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:databasePath];
    
    if (fileExists)
    {
        NSError *error = nil;
        BOOL removeSuccess = [fileManager removeItemAtPath:databasePath error:&error];
        if (removeSuccess)
        {
            NSLog(@"Deleted db from documents directory");
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [self.database close];
    NSLog(@"Database closed");
}

@end
