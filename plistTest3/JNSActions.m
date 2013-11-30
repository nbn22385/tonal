//
//  JNSActions.m
//  JNSPattern
//
//  Created by JEREMY AYALA on 11/29/13.
//  Copyright (c) 2013 Jeremy Ayala. All rights reserved.
//

#import "JNSActions.h"
#import "JNSTemplateMatch.h"
#import "FMDBDataAccess.h"
@implementation JNSActions
@synthesize _templateMatcher, _isStrengthTraining, _exerciseID, _exerciseRecordID;


-(id)initWithSentenceNumber:(NSUInteger)index
{
  self = [super init];
  
  if(self)
  {
    [self set_templateMatcher: [[JNSTemplateMatch alloc] initDemoWithSentence:index]];
    
    [self getExerciseIDFromSentence:[[self _templateMatcher] _sentence]];
    
    NSString *tagSentence = [_templateMatcher createPOSWithSentence:[ [self _templateMatcher] _sentence]];
    
    [_templateMatcher set_sentence:tagSentence];
    
    [_templateMatcher setFirstLevelPatternsFromSentence:[[self _templateMatcher]_sentence ]];
  }
  return self;
}


-(id)initWithSentence:(NSString *)sentence
{
  self = [super init];
  
  if(self)
  {
    [self set_templateMatcher: [[JNSTemplateMatch alloc] initWithSentence:sentence]];
    
    [self getExerciseIDFromSentence:[[self _templateMatcher] _sentence]];

    NSString *tagSentence = [_templateMatcher createPOSWithSentence:[ [self _templateMatcher] _sentence]];
    
    [_templateMatcher set_sentence:tagSentence];
    
    [_templateMatcher setFirstLevelPatternsFromSentence:[[self _templateMatcher]_sentence ]];
  }
  return self;
}

-(void)getExerciseIDFromSentence:(NSString *)sentence
{
  if (DEBUG_PATTERN) { NSLog(@"Looking for ID"); }

  [self set_exerciseID:0];
  NSArray *excerisePatterns = [NSArray arrayWithObjects:
                                 @"(cr|l)unch",
                                 @"(lateral ){0,1}(situp|sit up)( lateral){0,1}",
                                 @"(dumbbell(s)? |dumb bell(s)? ){0,1}(roll|row)",
                                 @"(pull|pool |pull )(down)",
                                 @"(barbell ){0,1}(deadlift|dead lift|did left)",
                                 @"(chin up|chinup|chin-up)",
                                 @"(bench |bench)press",
                                 @"(dumbbell(s)? |dumb bell(s)? )press",
                                 @"push.up",
                                 @"(seated |seeded ){0,1}shoulder press",
                                 @"(upright|right ) (dumbbell(s)?){0,1}",
                                 @"(seated |seeded ){0,1}military press",
                                 @"(seated |seeded ){0,1}(lateral ){0,1}deltoid (raise|race)",
                                 @"(dumbbell(s)? |dumb bell(s)? ){0,1}push press",
                                 @"(dumbbell(s)? |dumb bell(s)? ){0,1}shurg",
                                 @"leg extension",
                                 @"leg press",
                                 @"squat",
                                 @"hip adduction",
                                 @"(ball ){0,1}leg curl",
                                 @"(seated |seeded ){0,1}calf (raise|race)",
                                 @"standing calf (raise|race)",
                                 @"(standing ){0,1}(dumbbell(s)? |dumb bell(s)? ){0,1}bicep(s)? curl",
                                 @"(standing ){0,1}(barbell(s)? |bar bell(s)? ){0,1}bicep(s)? curl",
                                 @"preacher curl",
                                 @"(dumbbell(s)? |dumb bell(s)? ){0,1}tricep(s)? (kickback|kick back)",
                                 @"tricep(s)? (pushdown|push down)",
                                 @"(barbell(s)? |bar bell(s)? ){0,1}reverse (bench |bench)press",
                                 @"tricep(s)? dip",
                                 @"wrist(s)? curl",
                                 @"sprint",
                                 @"jo(g|hn)",
                                 @"free(style| style)",
                                 @"back(stroke| stroke)",nil];
  
  NSUInteger count = [excerisePatterns count];
  for (unsigned int i = 0; i < count; i++)
  {
    NSString *pattern = [excerisePatterns objectAtIndex:i];
    NSArray *matches  = [[self _templateMatcher] findPattern:pattern inSentence: sentence];

    if([matches count] > 0)
    {
      if (DEBUG_PATTERN) { NSLog(@"Found a Match for the Exercise ID: %i !!!", i+1); }
      [self set_exerciseID:i+1];
      continue;
    }
  }
  
//  TODO:  What to do if an exercise was not found?
//  if([self _exerciseID] == 0)
//  {
//    if (DEBUG_PATTERN) { NSLog(@"Found a Match for the Exercise ID!!!"); }
//    [self set_exerciseID: 1];
//  }
}


//    _brain =[NSArray arrayWithObjects:_sets,_reps, _pounds, _laps, _miles, nil];
-(void)decideExerciseCategory
{
  NSUInteger stregthCount = [[self get_reps] count] + [[self get_sets ] count] + [[self get_pounds] count];
  NSUInteger cardioCount  = [[self get_laps] count] + [[self get_miles] count];
  
  if(stregthCount > cardioCount)
  {
    [self set_isStrengthTraining:YES];
    if (DEBUG_PATTERN) { NSLog(@"Strength Training"); }
  }
  else
  {
    [self set_isStrengthTraining:NO];
    if (DEBUG_PATTERN) { NSLog(@"Cardio Training"); }

  }
}

-(void)doThis
{
  [self decideExerciseCategory];
  
  if ([self rule_01]) {
    [self actions_01];
  }
  else if ([self rule_02]) {
      [self actions_02];
  }
  else if ([self rule_03]) {
    [self actions_03];
  }
}

-(BOOL)isThereASetHint
{
  NSArray *wordNumList = [NSArray arrayWithObjects:@"one", @"two", @"three", @"for", @"five", @"six", @"seven", @"eight", @"nine", @"ten", @"eleven", nil];
  
  NSArray *NumLust     = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:2], [NSNumber numberWithInt:3], [NSNumber numberWithInt:4],
                                                   [NSNumber numberWithInt:5],[NSNumber numberWithInt:1], [NSNumber numberWithInt:6], [NSNumber numberWithInt:7],
                                                   [NSNumber numberWithInt:8],[NSNumber numberWithInt:9], [NSNumber numberWithInt:10],[NSNumber numberWithInt:11], nil];
  
  NSString *pattern = @"<[a-zA-Z]+/Number> <[a-zA-Z]+/Noun>";
  
  NSArray *matches  = [[self _templateMatcher] findPattern:pattern inSentence:[self get_sentence]];
  
  
  [[self _templateMatcher] printMatches:matches inSentence:[self get_sentence]];
  
  return YES;
}

-(BOOL)isEqualLengthArray:(NSArray *)array_1
                    array:(NSArray *)array_2
{
  NSUInteger count1 = [array_1 count];
  NSUInteger count2 = [array_2 count];
  
  if (count1 == count2)
  {
    return YES;
  }
  else
  {
    return NO;
  }
}

-(void)addSetToExerciseRecord:(NSInteger)erId :(NSInteger)reps :(NSInteger)value
{
  FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
  BOOL result = FALSE;
  result = [db addSetToExerciseRecord: erId: reps: value];
}

-(NSInteger)getCurrentExerciseRecord
{
  NSInteger myID;
  FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
  
  myID = [db getCurrentExerciseRecordId:[self _exerciseID]];
  return myID;
}


-(BOOL)createExerciseRecord
{
  // need tp_parent_id, exercise_id
  FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
  BOOL result = [db createExerciseRecord:[self _exerciseID]];
  return result;
  
}

-(NSInteger)getCurrentExerciseRecordId
{
  NSInteger id;
  FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
  
  id = [db getCurrentExerciseRecordId:[self _exerciseID]];
  return id;
}

-(void)addSetWithID:(NSInteger)erId
                   reps:(NSInteger)reps
                   value:(NSInteger)value

{
  // Don't submit record unless reps field is populated
  if ([self _exerciseID] !=0 )
  {
  
    // Get the exercise record id again (in case a new one was just created)
    _exerciseRecordID = [self getCurrentExerciseRecordId];
    
    // Check if an exercise record with this name/id exists for this training plan
   if (_exerciseRecordID == 0)
    {
      // Create an exercise record for this exercise
      [self createExerciseRecord ];
    }
  
    // Get the exercise record id again (in case a new one was just created)
    _exerciseRecordID = [self getCurrentExerciseRecordId];
    
//    // Get the values from the text fields
//    NSInteger reps = [repTextField.text integerValue];
//    NSInteger value = [weightTextField.text integerValue];
    
    // Add the new set record
    [self addSetToExerciseRecord: _exerciseRecordID: reps: value];
    
    // Clear the text fields
//    repTextField.text = @"";
//    weightTextField.text = @"";
    
    // Repopulate the set table
   // items = [self getSetRecords:exerciseRecordId];
   // [self.setsTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
  }
}

-(void)actions_01
{

  if([self _isStrengthTraining])
  {
    if (DEBUG_PATTERN) { NSLog(@"S Perform Action 1."); }
    NSUInteger count = [[self get_reps] count];
    for(unsigned int i = 0; i < count; i++)
    {
      NSUInteger reps   = [[[self get_reps  ] objectAtIndex:i] unsignedIntegerValue];
      NSUInteger pounds = [[[self get_pounds] objectAtIndex:i] unsignedIntegerValue];
    
      [self addSetWithID:[self _exerciseID] reps:reps value:pounds];
      
    }
  }
  else
  {
    if (DEBUG_PATTERN) { NSLog(@"C Perform Action 1."); }
  }
}

-(BOOL)rule_01
{
  // Strength Training Exercise
  if([self _isStrengthTraining])
  {
    if (
        [self isThereASetHint] &&
        [[self get_reps] count] > 0 &&
        [self isEqualLengthArray:[self get_reps] array:[self get_pounds]]
       )
    {
      if (DEBUG_PATTERN) { NSLog(@"S: Rule 1 Passed."); }
      return YES;
    }
    else
    {
      if (DEBUG_PATTERN) { NSLog(@"S: Rule 1 Failed."); }
      return NO;
    }
  }
  // Cardio Exercise
  else
  {
    if (DEBUG_PATTERN) { NSLog(@"C: START"); }

    if (
        [[self get_miles] count] > 0||
        [[self get_laps ] count] > 0
        )
    {
      if (DEBUG_PATTERN) { NSLog(@"C: Rule 1 Passed."); }
      return YES;
    }
    else
    {
      if (DEBUG_PATTERN) { NSLog(@"C: Rule 1 Failed."); }
      return NO;
    }
  }
}


-(void)actions_02
{
  if([self _isStrengthTraining])
  {
    
  }
  else
  {
    
  }
}

-(BOOL)rule_02
{
  if([self _isStrengthTraining])
  {
    
  }
  else
  {
    
  }
  return YES;
}


-(void)actions_03
{
  if([self _isStrengthTraining])
  {
    
  }
  else
  {
    
  }
}

-(BOOL)rule_03
{
  if([self _isStrengthTraining])
  {
    
  }
  else
  {
    
  }
  return YES;
}

-(NSString *)get_sentence
{
  return [[self _templateMatcher]_sentence];
}

-(NSArray *)get_sets
{
  return [[[self _templateMatcher] _brain] objectAtIndex:0];
}
-(NSArray *)get_reps
{
  return [[[self _templateMatcher] _brain] objectAtIndex:1];
}
-(NSArray *)get_pounds
{
  return [[[self _templateMatcher] _brain] objectAtIndex:2];
}
-(NSArray *)get_laps
{
  return [[[self _templateMatcher] _brain] objectAtIndex:3];
}
-(NSArray *)get_miles
{
  return [[[self _templateMatcher] _brain] objectAtIndex:4];
}
@end