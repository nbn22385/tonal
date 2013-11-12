//
//  ExerciseViewController.h
//  plistTest3
//
//  Created by Jeremy Ayala on 9/18/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDBDataAccess.h"

@interface ExerciseViewController : UITableViewController
{}
@property (strong, nonatomic) NSDictionary *groupDict;
@property (strong, nonatomic) NSArray *exerciseArray;

@property (strong, nonatomic) NSString *groupName;


@end
