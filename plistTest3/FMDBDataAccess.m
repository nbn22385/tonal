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
    
    while([results next])
    {
        NSString *category = [[NSString alloc] init];
        
        category = [results stringForColumn:@"group_name"];
        
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

    results = [db executeQuery:@"SELECT exercise_name FROM exercises WHERE group_name = ? ORDER BY exercise_name", forGroup];
    
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

    results = [db executeQuery:
               @"select unit_name from units where id = (select unit_id from exercises where exercise_name = ?)", forExercise];
    
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
    
    results = [db executeQuery:
               @"select sets from units where id = (select unit_id from exercises where exercise_name = ?)", forExercise];
    
    while([results next])
    {
        hsr = [results stringForColumn:@"sets"];
    }
    
    [db close];
    
    return [hsr boolValue];
    
}

-(NSInteger) getCurrentTrainingPlanId
{
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [db open];
    
    NSInteger id = 0, numResults = 0;
    FMResultSet *results;
    
    // should return one record
    results = [db executeQuery:@"select id from training_plan where is_open = 1"];
    
    while([results next])
    {
        id = [results intForColumn:@"id"];
        numResults ++;
    }
    
    NSLog(@"FMDBDataAccess : getCurrentTrainingPlanId returned ID: %d", id);
    
    [db close];
    
    return id;
}

-(NSDate *) getCurrentTrainingPlanStartDate
{
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [db open];
    
    NSInteger numResults = 0;
    NSString* start_date_string = nil;
    NSDate * start_date;
    
    FMResultSet *results;
    
    // should return one record
    results = [db executeQuery:@"select start_date from training_plan where is_open = 1"];
    
    while([results next])
    {
        start_date_string = [results stringForColumn:@"start_date"];
        numResults ++;
    }
    
    if (start_date_string == nil) {
        NSLog(@"getCurrentTrainingPlanStartDate: Start date is null");
    }
    
    [db close];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    start_date = [dateFormat dateFromString:start_date_string];
        
    return start_date;
}

-(BOOL) closeCurrentTrainingPlan
{
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [db open];

    NSDate *today=[NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString=[dateFormat stringFromDate:today];
    
    BOOL result = [db executeUpdate:@"update training_plan set end_date = ?, is_open = 0 where is_open = 1", dateString];
    
    [db close];
    
    return result;
}

-(NSInteger) createNewTrainingPlan
{
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [db open];
    
    NSInteger id = 0;
    BOOL result = false;
    
    result = [db executeUpdateWithFormat:
               @"insert into training_plan (start_date, end_date, is_open) values (datetime('now'), NULL, 1)"];
        
    [db close];
    
    return id;
}

-(NSInteger) getCurrentExerciseRecordId:(NSInteger)forActivityId
{
    // Get the exercise_record id for the open TP if it exists
    
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [db open];
    
    NSInteger id = 0, numResults = 0;
    FMResultSet *results;
    
    // should return one record
    results = [db executeQueryWithFormat:
               @"select id from exercise_record where exercise_id = %d and tp_parent_id = (select id from training_plan where is_open = 1)", forActivityId]; // try using open_exercise_records view
    
    while([results next])
    {
        id = [results intForColumn:@"id"];
        numResults ++;
    }
    
    NSLog(@"FMDBDataAccess : getCurrentExerciseRecordId returned ID: %d", id);
    
    [db close];
    
    return id;
}

-(NSInteger)getIdForExerciseName:(NSString*)exerciseName
{
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [db open];
    
    NSInteger id = 0, numResults = 0;
    FMResultSet *results;
    
    // should return one record
    results = [db executeQuery:@"select id from exercises where exercise_name = ?", exerciseName];

    while([results next])
    {
        id = [results intForColumn:@"id"];
        numResults ++;
    }
    
    NSLog(@"FMDBDataAccess : getIdForExerciseName returned ID: %d for exercise: %@", id, exerciseName);

    [db close];
    return id;
}

-(BOOL)addSetToExerciseRecord:(NSInteger)erId :(NSInteger)numReps :(NSInteger)value
{
    //NSInteger currTpId = [self getCurrentTrainingPlanId];
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [db open];
    BOOL result = false;
    
    result = [db executeUpdateWithFormat:
              @"insert into set_records (er_parent_id, num_reps, value, timestamp) values (%d, %d, %d, datetime('now'))",
              erId, numReps, value];
    [db close];
    return result;
}

-(NSInteger)exerciseExistsInTrainingPlan:(NSInteger)activityId
{
    NSInteger erId = 0, numResults = 0;
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [db open];    
    FMResultSet *results;
    
    // should return one record
    results = [db executeQuery:@"select id from exercise_record where exercise_id = %d and tp_parent_id = (select id from training_plan where is_open = 1)", activityId];
    
    while([results next])
    {
        erId = [results intForColumn:@"id"];
        numResults ++;
    }
    
    [db close];
    // return the exercise_record id if found, otherwise return 0
    return erId;
    
}

-(BOOL)createExerciseRecord:(NSInteger)activityId
{
    NSInteger currTpId = [self getCurrentTrainingPlanId];

    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [db open];
    
    BOOL result = false;
    
    result = [db executeUpdateWithFormat:
              @"insert into exercise_record (tp_parent_id, exercise_id) values (%d, %d)", currTpId, activityId];
    
    [db close];
    
    return result;
}

@end
