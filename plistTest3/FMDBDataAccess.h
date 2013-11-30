//
//  FMDBDataAccess.h
//  plistTest3
//
//  Created by Jeremy Ayala on 11/3/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMResultSet.h"

@interface FMDBDataAccess : NSObject

@property(strong,nonatomic) FMDatabase *db;
@property(strong, nonatomic) NSString *databaseName;
@property(strong, nonatomic) NSString *databasePath;

-(NSMutableArray *) getCategories:(NSInteger)withId;
-(NSMutableArray *) getExercises:(NSString*)forGroup;
-(NSString *) getUnitName:(NSString *)forExercise;
-(BOOL) hasSetsReps:(NSString *)forExercise;
-(NSInteger) getCurrentTrainingPlanId;
-(NSDate *) getCurrentTrainingPlanStartDate;
-(BOOL) closeCurrentTrainingPlan;
-(NSInteger) createNewTrainingPlan;
-(NSInteger) getCurrentExerciseRecordId:(NSInteger)forActivityId;

-(NSInteger)getIdForExerciseName:(NSString*)exerciseName;
-(BOOL)addSetToExerciseRecord:(NSInteger)erId :(NSInteger)numReps :(NSInteger)value;
-(NSInteger)exerciseExistsInTrainingPlan:(NSInteger)erId;
-(BOOL)createExerciseRecord:(NSInteger)activityId;

-(NSArray*)getSetRecords:(NSInteger)forErId;
-(NSArray*)getClosedTrainingPlanRecords;
-(NSArray*)getAllExerciseNames;

@end
