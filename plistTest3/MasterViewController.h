//
//  MasterViewController.h
//  plistTest3
//
//  Created by Jeremy Ayala on 9/18/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDBDataAccess.h"

@interface MasterViewController : UITableViewController
{}

@property (strong, nonatomic) NSArray *myItems;

//@property (strong, nonatomic) FMDBDataAccess *db;
@property (strong, nonatomic) NSMutableArray* categories;
@property (strong, nonatomic) NSMutableArray* categoryArray1;
@property (strong, nonatomic) NSMutableArray* categoryArray2;


@end
