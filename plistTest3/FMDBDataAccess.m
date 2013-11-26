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

#import "SetRecord.h"
#import "TrainingPlanRecord.h"

@implementation FMDBDataAccess
{}
@synthesize db;

-(NSString *) getDatabasePath
{
    self.databaseName = @"test.db";
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    //NSLog(@"Documents dir: %@", documentDir);
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
    
    NSLog(@"getCurrentTrainingPlanId: returned ID: %d", id);
    
    [db close];
    
    return id;
}

-(NSDate *) getCurrentTrainingPlanStartDate
{
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [db open];
    
    NSInteger numResults = 0;
    NSString* startDateStr = nil;
    NSDate * startDate;
    
    FMResultSet *results;
    
    // should return one record
    results = [db executeQuery:@"select start_date from training_plan where is_open = 1"];
    
    while([results next])
    {
        startDateStr = [results stringForColumn:@"start_date"];
        numResults ++;
    }
    
    if (startDateStr == nil) {
        NSLog(@"getCurrentTrainingPlanStartDate: Start date is null");
    }
    
    [db close];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    dateFormat.timeZone = [NSTimeZone systemTimeZone];
    startDate = [dateFormat dateFromString:startDateStr];
    
    return startDate;
}

-(BOOL) closeCurrentTrainingPlan
{
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [db open];

    NSDate *today=[NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    dateFormat.timeZone = [NSTimeZone systemTimeZone];
    NSString *dateString=[dateFormat stringFromDate:today];
    
    BOOL result = [db executeUpdate:@"update training_plan set end_date = ?, is_open = 0 where is_open = 1", dateString];
    if (result) {
        NSLog(@"closeCurrentTrainingPlan: closed training plan");
    }
    [db close];
    
    return result;
}

-(NSInteger) createNewTrainingPlan
{
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [db open];
    
    NSDate *today=[NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    dateFormat.timeZone = [NSTimeZone systemTimeZone];
    NSString *dateString=[dateFormat stringFromDate:today];
    
    NSInteger id = 0;
    BOOL result = false;
    
    result = [db executeUpdate:
               @"insert into training_plan (start_date, end_date, is_open) values (?, NULL, 1)", dateString];
    
    [db close];
    
    if (result) {
        NSLog(@"createNewTrainingPlan: created training plan");
    }
    
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
    
    NSLog(@"getCurrentExerciseRecordId: returned ID: %d", id);
    
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
    
    NSLog(@"getIdForExerciseName: returned id %d for exercise: %@", id, exerciseName);

    [db close];
    return id;
}

-(NSInteger)exerciseExistsInTrainingPlan:(NSInteger)activityId
{
    NSInteger erId = 0;
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [db open];    
    FMResultSet *results;
    
    // should return one record
    results = [db executeQuery:@"select id from exercise_record where exercise_id = %d and tp_parent_id = (select id from training_plan where is_open = 1)", activityId];
    
    while([results next])
    {
        erId = [results intForColumn:@"id"];
        NSLog(@"exerciseExistsInTrainingPlan: exercise id %d exists in training plan", activityId);
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
    
    result = [db executeUpdateWithFormat:@"insert into exercise_record (tp_parent_id, exercise_id) values (%d, %d)", currTpId, activityId];
    
    [db close];
    
    if (result) {
        NSLog(@"createExerciseRecord: created exercise record for exercise id %d", activityId);
    }
    
    return result;
}

-(BOOL)addSetToExerciseRecord:(NSInteger)erId :(NSInteger)numReps :(NSInteger)value
{
    //NSInteger currTpId = [self getCurrentTrainingPlanId];
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [db open];
    BOOL result = false;
    
    NSDate *today=[NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    dateFormat.timeZone = [NSTimeZone systemTimeZone];
    NSString *dateString=[dateFormat stringFromDate:today];
    
    result = [db executeUpdateWithFormat:
              @"insert into set_records (er_parent_id, num_reps, value, timestamp) values (%d, %d, %d, %@)",
              erId, numReps, value, dateString];
    [db close];
    
    if (result) {
        NSLog(@"addSetToExerciseRecord: created set (%d/%d) for exercise record %d", numReps, value, erId);
    }
    
    return result;
}

-(NSArray*)getSetRecords:(NSInteger)forErId
{
    NSArray* srArray = [NSArray array];
    
    NSInteger numReps, value;
    NSString* dateStr;
    NSDate* date;
    
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [db open];
    FMResultSet *results;
    
    //results = [db executeQuery:@"select num_reps, value, timestamp from set_records where er_parent_id = %d", forErId];
    results = [db executeQuery:[NSString stringWithFormat:@"select num_reps, value, timestamp from set_records where er_parent_id = %d",forErId]];

    while([results next])
    {
        SetRecord* sr = [SetRecord alloc];

        numReps = [results intForColumn:@"num_reps"];
        value = [results intForColumn:@"value"];
        dateStr = [results stringForColumn:@"timestamp"];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        dateFormat.timeZone = [NSTimeZone systemTimeZone];
        date = [dateFormat dateFromString:dateStr];
        
        // Fill the SetRecord object
        sr.numReps = numReps;
        sr.value = value;
        sr.date = date;
        
        // Insert into array
        srArray = [srArray arrayByAddingObject:sr];
    }
    
    NSLog(@"getSetRecords: returned %d sets for exercise id %d", srArray.count, forErId);
    
    [db close];
    
    return srArray;
}

-(NSArray*)getClosedTrainingPlanRecords
{
    NSArray* tpArray = [NSArray array];

    NSString *startDateStr, *endDateStr, *name;
    NSDate *startDate, *endDate;
    
    db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    [db open];
    FMResultSet *results;
    
    results = [db executeQuery:[NSString stringWithFormat:@"select name, start_date, end_date from training_plan where is_open = 0"]];
    
    while([results next])
    {
        TrainingPlanRecord* tp = [TrainingPlanRecord alloc];
        
        name = [results stringForColumn:@"name"];
        startDateStr = [results stringForColumn:@"start_date"];
        endDateStr = [results stringForColumn:@"end_date"];

        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        dateFormat.timeZone = [NSTimeZone systemTimeZone];
        startDate = [dateFormat dateFromString:startDateStr];
        endDate = [dateFormat dateFromString:endDateStr];

        // Fill the SetRecord object
        tp.name = name;
        tp.startDate = startDate;
        tp.endDate = endDate;
        
        // Insert into array
        tpArray = [tpArray arrayByAddingObject:tp];
    }
    
    NSLog(@"getClosedTrainingPlanRecords: returned %d training plans", tpArray.count);
    
    [db close];
    
    return tpArray;
}

-(NSArray*)getAllExerciseNames
{
  db = [FMDatabase databaseWithPath:[self getDatabasePath]];
  [db open];
  FMResultSet *results;
  
  NSInteger myId;
  NSString* myName; 
  
  NSMutableArray *stocks = [[NSMutableArray alloc] init];
  NSMutableDictionary *stock;
  
  results = [db executeQuery:[NSString stringWithFormat:@"select id, exercise_name from exercises"]];
  
  while([results next])
  {
    myId = [results intForColumn:@"id"];
    myName = [results stringForColumn:@"exercise_name"];
    
    stock = [NSMutableDictionary dictionary];
    
    [stock setObject:[NSNumber numberWithInt: myId]
                      forKey:@"id"];
    [stock setObject:myName
              forKey:@"exercise_name"];
    
    [stocks addObject:stock];
    
  }
  [db close];
  return stocks;
}
@end
