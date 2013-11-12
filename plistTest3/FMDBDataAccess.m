//
//  FMDBDataAccess.m
//  plistTest3
//
//  Created by Jeremy Ayala on 11/3/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import "FMDBDataAccess.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@implementation FMDBDataAccess
{}
@synthesize db;

-(NSString *) getDatabasePath
{
    self.databaseName = @"test.db";
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSLog(@"Documents dir: %@", documentDir);
    self.databasePath = [documentDir stringByAppendingPathComponent:self.databaseName];
    return self.databasePath;
}

#pragma mark - SELECT queries

-(NSMutableArray *) getCategories:(NSInteger)withId
{
    NSMutableArray *categories = [[NSMutableArray alloc] init];
    
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    
    [db open];
    
    FMResultSet *results;
    
    switch (withId) {
        case 1: // Strength Training
            results = [db executeQuery:@"SELECT DISTINCT group_name FROM exercises WHERE unit_id = 1 ORDER BY group_name"];
            break;
        case 2: // Cardio
            results = [db executeQuery:@"SELECT DISTINCT group_name FROM exercises WHERE unit_id <> 1 ORDER BY group_name"];
            break;
        default:
            break;
    }
    //FMResultSet *results = [db executeQuery:@"SELECT DISTINCT group_name FROM exercises"];
    
    while([results next])
    {
        NSString *category = [[NSString alloc] init];
        
        category = [results stringForColumn:@"group_name"];
        //customer.firstName = [results stringForColumn:@"firstname"];
        //customer.lastName = [results stringForColumn:@"lastname"];
        
        [categories addObject:category];
        
    }
    
    [db close];
    
    return categories;
    
}

-(NSMutableArray *) getExercises:(NSString *)forGroup
{
    NSMutableArray *exercises = [[NSMutableArray alloc] init];
    
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    
    [db open];
    
    FMResultSet *results;

    results = [db executeQueryWithFormat:@"SELECT exercise_name FROM exercises WHERE group_name = %@ ORDER BY exercise_name", forGroup];
    
    while([results next])
    {
        NSString *exercise = [[NSString alloc] init];
        exercise = [results stringForColumn:@"exercise_name"];
        [exercises addObject:exercise];
    }
    
    [db close];
    
    return exercises;
    
}

-(NSString *) getUnitName:(NSString *)forExercise
{
    
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    
    [db open];
    
    FMResultSet *results;
    NSString *units = [[NSString alloc] init];

    results = [db executeQueryWithFormat:
               @"select unit_name from units where id = (select unit_id from exercises where exercise_name = %@)", forExercise];
    
    while([results next])
    {
        units = [results stringForColumn:@"unit_name"];
    }
    
    [db close];
    
    return units;
    
}

-(BOOL) hasSetsReps:(NSString *)forExercise
{
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    NSString* hsr;
    [db open];
    
    FMResultSet *results;
    
    results = [db executeQueryWithFormat:
               @"select sets from units where id = (select unit_id from exercises where exercise_name = %@)", forExercise];
    
    while([results next])
    {
        hsr = [results stringForColumn:@"sets"];
    }
    
    [db close];
    
    return [hsr boolValue];
    
}

@end
