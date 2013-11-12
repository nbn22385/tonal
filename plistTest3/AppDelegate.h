//
//  AppDelegate.h
//  plistTest3
//
//  Created by Jeremy Ayala on 9/18/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(strong, nonatomic) NSString *databaseName;
@property(strong, nonatomic) NSString *databasePath;

@property(strong,nonatomic) FMDatabase *database;

@end
