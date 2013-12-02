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
#import "JNSSentenceState.h"

@implementation JNSActions
@synthesize _templateAPI, _sentence, _exerciseID, _exerciseRecordID, _addedRecord, _verbSentenceStateList, _oldJNSSentenceState, _exerciseCount;


//-(id)initWithSentenceNumber:(NSUInteger)index
//{
//  self = [super init];
//  
//  if(self)
//  {
//    [self set_templateAPI: [[JNSTemplateMatch alloc] initDemoWithSentence:index]];
//    
//    [self getExerciseIDFromSentence:[[self _templateAPI] _sentence]];
//    
//    NSString *tagSentence = [_templateAPI createPOSWithSentence:[ [self _templateAPI] _sentence]];
//    
//    [_templateAPI set_sentence:tagSentence];
//    [self set_sentence:[[self _templateAPI]_sentence ]];
//    
//    [_templateAPI setFirstLevelPatternsFromSentence:[[self _templateAPI]_sentence ]];
//  }
//  return self;
//}


-(id)initWithSentence:(NSString *)sentence
{
  self = [super init];
  
  if(self)
  {
    _verbSentenceStateList = [[NSMutableArray alloc] init];

    [self set_templateAPI: [[JNSTemplateMatch alloc] init]];

    // Get the exercise ID from the raw sentence
    [self getExerciseIDFromSentence: sentence];
    
    NSString *tagSentence = [[self _templateAPI] createPOSWithSentence: sentence];
    
    [self isExerciseCountGreaterThanOne:sentence];
    
    //_oldJNSSentenceState set_sentence:  tagSentence]; 
      
    // re-set the sentence to the correct tag parse
    //[_templateAPI set_sentence:tagSentence];
      
    // Set The State Controller to the whole sentence  
    [self set_sentence: tagSentence];

    //[_templateAPI setFirstLevelPatternsFromSentence:[[self _templateAPI]_sentence ]];
    [self validateBasicSentence];
    
  }
  return self;
}

-(void)performVerbSentencePharse
{
    //find verbs
  
    //Find out if sets or set appear in the statement
    NSString *pattern = @"<[a-zA-Z]+/(Adverb|verb)>";
    NSArray *matches = [[self _templateAPI] findPattern:pattern inSentence:[self _sentence]];
    
    if (DEBUG_PATTERN) { [[self _templateAPI] printMatches:matches inSentence:[self _sentence]];}
  
    if([matches count] > 0 )
    {
      //[self set_isSetsPlural:YES];
      if (DEBUG_PATTERN) { NSLog(@"End of Verb Find"); }
      
      // substring that is the lenght of the verb to the next verb
      
      NSUInteger countMatches = [matches count];
      for (unsigned int i = 0; i < countMatches; i++)
      {
             
        NSTextCheckingResult *match = [matches objectAtIndex:i];
        
        NSRange r = [match range];
        NSUInteger startPoint = r.location;
        // default to no more verbs
        NSUInteger length = [[self _sentence] length];
        NSUInteger endPoint = length - r.location;
        
        //if you found another verb
        if (i + 1 > countMatches)
        {
          NSTextCheckingResult *matchPlus1 = [matches objectAtIndex:i+1];
          
          NSRange rPlus1 = [matchPlus1 range];
          endPoint = rPlus1.location - r.location;
        }
        
        NSRange withRange = NSMakeRange(startPoint, endPoint);
        
        NSString *section = [[self _sentence] substringWithRange:withRange];
          
        // Create a new sentence state from the section  
        JNSSentenceState* sentenceState = [[JNSSentenceState alloc] init];  
        
        // Set the Sentence State
        [sentenceState set_sentence:section];
        
        // Check to ensure the length is greater than a certain amount
        if ([section length] > 50)
        {
          sentenceState  = [[self _templateAPI] gatherInitialMetricsWithState:sentenceState];
          [self setFlagsWithState:sentenceState];
          
          [[self _verbSentenceStateList] addObject:sentenceState];
        }
      }
      
      [self identifyStateInformation: _verbSentenceStateList];
      
      if (DEBUG_PATTERN) { NSLog(@"End of Verb Find"); }
    }
    else
    {
      if (DEBUG_PATTERN) { NSLog(@"No Verbs left leaving function"); }
    }
}

-(void)performGeneralParse
{
  // Create a new sentence state from the section
  JNSSentenceState* sentenceState = [[JNSSentenceState alloc] init];
  
  [sentenceState set_sentence:[self _sentence]];
   
  sentenceState  = [[self _templateAPI] gatherInitialMetricsWithState:sentenceState];
  [self setFlagsWithState:sentenceState];
  NSArray *arraylist = [NSArray arrayWithObjects:sentenceState, nil];
  [self identifyStateInformation: arraylist];

}

-(BOOL)isExerciseValid
{
  if([self _exerciseID] > 0)
    return YES;
  else
    return NO;
}

-(void)validateBasicSentence
{
    if ([self isExerciseValid])
    {
      if ([self _exerciseCount] == 1)
      {
        if([self isVerbsIncluded:[self _sentence]])
        {
          [self performVerbSentencePharse];
        }
        else
        {
          [self performGeneralParse];
        }
      }
      // Exercise Count is > 1
      else
      {
        
      }
    }
    // Exercise is not valid
    else
    {
      if (DEBUG_PATTERN) { NSLog(@"Exerise ID not Valid"); }

    }
}

-(void)identifyStateInformation:(NSArray *)sentenceStates
{
  for(JNSSentenceState * sentenceState in sentenceStates)
  {
    if ([sentenceState _isSetIncludedWithState])
    {
      if([sentenceState _isSetsPlural])
      {
        [self addComplexTrainingSet:sentenceState];
      }
      else
      {
        if([sentenceState _isRepCountGreaterThanZero] &&
           [sentenceState _isRepsAndPoundsCountEqual])
        {
          [self addNonPluralStrengthTrainingSet:sentenceState];
        }
      }
    }
    // sets are not included in state
    else
    {
      if([sentenceState _isRepCountGreaterThanZero] &&
         [sentenceState _isRepsAndPoundsCountEqual])
      {
        [self addNonPluralStrengthTrainingSet:sentenceState];
      }
      else
      {
        if([sentenceState _isNumberPerpNumberUsed])
        {
          JNSSentenceState * complexState = [[JNSSentenceState alloc] init];
          complexState = [[self _templateAPI]gatherComplexMatrics:sentenceState];
          [self addComplexTrainingSet:complexState];
        }
        else
        {
          // not number perp number
        }
        
        if([sentenceState _isNumberTimesNumberUsed])
        {
          JNSSentenceState * complexState = [[JNSSentenceState alloc] init];
          complexState = [[self _templateAPI]gatherComplexMatrics:sentenceState];
          [self addComplexTrainingSet:complexState];
        }
        else
        {
          //not number perp number
        }
        if([sentenceState _isLapsCountGreaterThanZero])
        {
          [self addNonPluralCardioSet:sentenceState];

        }
        else if([sentenceState _isMilesCountGreaterThanZero])
        {
          [self addNonPluralCardioSet:sentenceState];

        }
        
      }
    }
  }
}

//@property(nonatomic) BOOL _isSetsPlural;
//@property(nonatomic) BOOL _isSetIncludedWithState;
//
//@property(nonatomic) BOOL _isNumberPerpNumberUsed;
//@property(nonatomic) BOOL _isNumberTimesNumberUsed;
//
//@property(nonatomic) BOOL _isStrengthTraining;
//
//@property(nonatomic) BOOL _isRepsAndPoundsCountEqual;
//@property(nonatomic) BOOL _isRepCountGreaterThanZero;

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
    NSArray *matches  = [[self _templateAPI] findPattern:pattern inSentence: sentence];

    if([matches count] > 0)
    {
      if (DEBUG_PATTERN) { NSLog(@"Found a Match for the Exercise ID: %i !!!", i+1); }
      [self set_exerciseID:i+1];
      continue;
    }
  }
}

-(BOOL)isVerbsIncluded:(NSString *)sentence
{
  //find verbs
  
  //Find out if sets or set appear in the statement
  NSString *pattern = @"<[a-zA-Z]+/(Adverb|verb)>";
  NSArray  *matches = [[self _templateAPI] findPattern:pattern inSentence:[self _sentence]];
  
  if ([matches count] > 0)
  {
    return YES;
  }
  else
  {
    return NO;
  }
}

-(void)isExerciseCountGreaterThanOne:(NSString *)sentence
{
  if (DEBUG_PATTERN) { NSLog(@"Looking for ID"); }
  
  [self set_exerciseCount:0];
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
    NSArray *matches  = [[self _templateAPI] findPattern:pattern inSentence: sentence];
    
    if([matches count] > 0)
    {
      [self set_exerciseCount: [self _exerciseCount] + 1];
    }
  }
  if (DEBUG_PATTERN) { NSLog(@"Exercise Count: %i !!!!!!!!", [self _exerciseCount]); }
}



// _brain =[NSArray arrayWithObjects:_sets,_reps, _pounds, _laps, _miles, nil];
-(void)isStrengthTrainingWithState:(JNSSentenceState *)sentenceState
{
  NSUInteger strengthCount = [[sentenceState _reps] count] + [[sentenceState _sets ] count] + [[sentenceState _pounds] count];
  NSUInteger cardioCount   = [[sentenceState _laps] count] + [[sentenceState _miles] count];
  
  if(strengthCount > cardioCount)
  {
    [sentenceState set_isStrengthTraining:YES];
    if (DEBUG_PATTERN) { NSLog(@"isStrengthTrainingWithState: YES"); }
  }
  else
  {
    [sentenceState set_isStrengthTraining:NO];
    if (DEBUG_PATTERN) { NSLog(@"isStrengthTrainingWithState: NO"); }

  }
}

//    _brain =[NSArray arrayWithObjects:_sets,_reps, _pounds, _laps, _miles, nil];
-(void)isRepsAndPoundsCountEqualWithState:(JNSSentenceState *)sentenceState
{
  NSUInteger repsCount   = [[sentenceState _reps  ] count];
  NSUInteger poundsCount = [[sentenceState _pounds] count];
  
  if(repsCount == poundsCount)
  {
    [sentenceState set_isRepsAndPoundsCountEqual:YES];
    if (DEBUG_PATTERN) { NSLog(@"isRepsAndPoundsCountEqual: YES"); }
  }
  else
  {
    [sentenceState set_isRepsAndPoundsCountEqual:NO];
    if (DEBUG_PATTERN) { NSLog(@"isRepsAndPoundsCountEqual: NO"); }
    
  }
}

-(void)isSetsPluralWithState:(JNSSentenceState *)sentenceState
{
  //Find out if sets or set appear in the statement
  NSString *pattern = @"<[0-9]+/Number> <sets/Noun>";
  NSArray *matches = [[self _templateAPI] findPattern:pattern inSentence:[sentenceState _sentence]];
 
  if (DEBUG_PATTERN) { [[self _templateAPI] printMatches:matches inSentence:[sentenceState _sentence]];}

  
  if([matches count] > 0 )
  {
    [sentenceState set_isSetsPlural:YES];
    if (DEBUG_PATTERN) { NSLog(@"isSetsPlural: YES"); }
  }
  else
  {
    [sentenceState set_isSetsPlural:NO];
    if (DEBUG_PATTERN) { NSLog(@"isSetsPlural: NO"); }
  }
}

-(void)isSetIncludedWithState:(JNSSentenceState *)sentenceState
{
  //Find out if sets or set appear in the statement
  NSString *pattern = @"<[0-9]+/Number> <set(s)?/Noun>";
  NSArray *matches = [[self _templateAPI] findPattern:pattern inSentence:[sentenceState _sentence]];
  
  if (DEBUG_PATTERN) { [[self _templateAPI] printMatches:matches inSentence:[sentenceState _sentence]];}
  
  
  if([matches count] > 0 )
  {
    [sentenceState set_isSetIncludedWithState:YES];
    if (DEBUG_PATTERN) { NSLog(@"isSetIncludedWithState: YES"); }
  }
  else
  {
    [sentenceState set_isSetIncludedWithState:NO];
    if (DEBUG_PATTERN) { NSLog(@"isSetIncludedWithState: NO"); }
  }
}


//Find out if 3 by 3 by 3, 3 for 3 for 3, 3 with 3 with 3, template was used
-(void)isNumberPerpNumberUsedWithState:(JNSSentenceState *)sentenceState
{
  NSString *pattern = @"<[0-9]+/Number> <[a-zA-Z]+/Preposition> <[0-9]+/Number> <[a-zA-Z]+/Preposition> <[0-9]+/Number>";
  NSArray *matches = [[self _templateAPI] findPattern:pattern inSentence:[sentenceState _sentence]];
  
  if (DEBUG_PATTERN) { [[self _templateAPI] printMatches:matches inSentence:[sentenceState _sentence]];}
  
  if([matches count] > 0 )
  {
    [sentenceState set_isNumberPerpNumberUsed:YES];
    if (DEBUG_PATTERN) { NSLog(@"isNumberPerpNumberUsed: YES"); }
  }
  else
  {
    [sentenceState set_isNumberPerpNumberUsed:NO];
    if (DEBUG_PATTERN) { NSLog(@"isNumberPerpNumberUsed: NO"); }
  }
}

-(void)isNumberTimesNumberUsedWithState:(JNSSentenceState *)sentenceState
{
  NSString *pattern = @"<[0-9]+/Number> <(x|time(s)?)/Noun> <[0-9]+/Number> <(x|time(s)?)/Noun> <[0-9]+/Number>";
  NSArray *matches = [[self _templateAPI] findPattern:pattern inSentence:[sentenceState _sentence]];
  
  if (DEBUG_PATTERN) { [[self _templateAPI] printMatches:matches inSentence:[sentenceState _sentence]];}
  
  if([matches count] > 0 )
  {
    [sentenceState set_isNumberTimesNumberUsed:YES];
    if (DEBUG_PATTERN) { NSLog(@"isNumberTimesNumberUsed: YES"); }
  }
  else
  {
    [sentenceState set_isNumberTimesNumberUsed:NO];
    if (DEBUG_PATTERN) { NSLog(@"isNumberTimesNumberUsed NO"); }
  }
}

-(void)isRepCountGreaterThanZeroWithState:(JNSSentenceState *)sentenceState
{
  NSUInteger repsCount =  [[sentenceState _reps] count];
  
  if(repsCount > 0)
  {
    [sentenceState set_isRepCountGreaterThanZero:YES];
    if (DEBUG_PATTERN) { NSLog(@"set_isRepCountGreaterThanZero: YES"); }
  }
  else
  {
    [sentenceState set_isRepCountGreaterThanZero:NO];
    if (DEBUG_PATTERN) { NSLog(@"set_isRepCountGreaterThanZero NO"); }
  }
}

-(void)isLapCountGreaterThanZeroWithState:(JNSSentenceState *)sentenceState
{
  NSUInteger lapCount =  [[sentenceState _laps] count];
  
  if(lapCount > 0)
  {
    [sentenceState set_isLapsCountGreaterThanZero:YES];
    if (DEBUG_PATTERN) { NSLog(@"set_isLapCountGreaterThanZero: YES"); }
  }
  else
  {
    [sentenceState set_isLapsCountGreaterThanZero:NO];
    if (DEBUG_PATTERN) { NSLog(@"set_isLapCountGreaterThanZero NO"); }
  }
}

-(void)isMilesCountGreaterThanZeroWithState:(JNSSentenceState *)sentenceState
{
  NSUInteger milesCount =  [[sentenceState _miles] count];
  
  if(milesCount > 0)
  {
    [sentenceState set_isMilesCountGreaterThanZero:YES];
    if (DEBUG_PATTERN) { NSLog(@"set_isMileCountGreaterThanZero: YES"); }
  }
  else
  {
    [sentenceState set_isMilesCountGreaterThanZero:NO];
    if (DEBUG_PATTERN) { NSLog(@"set_isMileCountGreaterThanZero NO"); }
  }
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

-(void)set_exerciseIDWithState:(JNSSentenceState *)sentenceState
{
  [sentenceState set_exerciseID: [self _exerciseID]];
}

-(void)setFlagsWithState:(JNSSentenceState *)sentenceState
{
    // set exercise state
    [self set_exerciseIDWithState:            sentenceState];
  
    // Strength Training or Cardio
    [self isStrengthTrainingWithState:        sentenceState];
    
    // Reps = Sets
    [self isRepsAndPoundsCountEqualWithState: sentenceState];
    
    // SetS
    [self isSetsPluralWithState:              sentenceState];
  
    // Set included
    [self isSetIncludedWithState:             sentenceState];
  
    // Rep > 0
    [self isRepCountGreaterThanZeroWithState: sentenceState];
    
    // 3 by 3
    [self isNumberPerpNumberUsedWithState:    sentenceState];
    
    // 3 x 3
    [self isNumberTimesNumberUsedWithState:   sentenceState];
  
    [self isLapCountGreaterThanZeroWithState: sentenceState];
  
    [self isMilesCountGreaterThanZeroWithState: sentenceState];
}



-(BOOL)doThis
{
//  // reset the add record flag
//  [self set_addedRecord: NO];
//  
//  // Strength Training or Cardio
//  [self isStrengthTraining];
//  
//  // Reps = Sets
//  [self isRepsAndPoundsCountEqual];
//  
//  // Sets not Set
//  [self isSetsPlural];
//  
//  // Rep > 0
//  [self isRepCountGreaterThanZero];
//  
//  // 3 by 3
//  [self isNumberPerpNumberUsed];
//  
//  // 3 x 3
//  [self isNumberTimesNumberUsed];
//  
//  if ([self rule_01])
//  {
//    [self actions_01];
//    return [self _addedRecord];
//  }
//  else if ([self rule_02])
//  {
//      [self actions_02];
//    return [self _addedRecord];
//
//  }
//  else if ([self rule_03])
//  {
//    [self actions_03];
//    return [self _addedRecord];
//
//  }
//  return [self _addedRecord];
  return true;
}

-(BOOL)isThereASetHint
{
//  NSArray *wordNumList = [NSArray arrayWithObjects:@"one", @"two", @"three", @"for", @"five", @"six", @"seven", @"eight", @"nine", @"ten", @"eleven", nil];
//  
//  NSArray *NumLust     = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:2], [NSNumber numberWithInt:3], [NSNumber numberWithInt:4],
//                                                   [NSNumber numberWithInt:5],[NSNumber numberWithInt:1], [NSNumber numberWithInt:6], [NSNumber numberWithInt:7],
//                                                   [NSNumber numberWithInt:8],[NSNumber numberWithInt:9], [NSNumber numberWithInt:10],[NSNumber numberWithInt:11], nil];
//  
//  NSString *pattern = @"<[a-zA-Z]+/Number> <[a-zA-Z]+/Noun>";
//  
//  NSArray *matches  = [[self _templateAPI] findPattern:pattern inSentence:[self get_sentence]];
//  
//  
//  [[self _templateAPI] printMatches:matches inSentence:[self get_sentence]];
//  
  return YES;
}

-(BOOL)addSetToExerciseRecord:(NSInteger)erId :(NSInteger)reps :(NSInteger)value
{
  FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
  BOOL result = FALSE;

  result = [db addSetToExerciseRecord: erId: reps: value];
  return result;
}

-(NSInteger)getCurrentExerciseRecord:(NSUInteger)exerciseID
{
  NSInteger myID;
  FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
  
  myID = [db getCurrentExerciseRecordId: exerciseID];
  return myID;
}


-(BOOL)createExerciseRecord:(NSUInteger)exerciseID
{
  // need tp_parent_id, exercise_id
  FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
  BOOL result = [db createExerciseRecord:exerciseID];
  return result;
  
}

-(NSInteger)getCurrentExerciseRecordId:(NSUInteger)exerciseID
{
  NSInteger myID;
  FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
  
  myID = [db getCurrentExerciseRecordId:exerciseID];
  return myID;
}
   
-(void)addNonPluralStrengthTrainingSet:(JNSSentenceState * )sentenceState
{
  NSUInteger exerciseID = [sentenceState _exerciseID];
  
  NSUInteger reps  = [[[sentenceState   _reps]firstObject]unsignedIntegerValue];

  NSUInteger value = [[[sentenceState _pounds]firstObject]unsignedIntegerValue];
  
 [self addSetWithID:exerciseID reps:reps value:value];
  
}

-(void)addComplexTrainingSet:(JNSSentenceState * )sentenceState
{
  NSUInteger exerciseID = [sentenceState _exerciseID];
  
  NSUInteger sets  = [[[sentenceState   _sets]firstObject]unsignedIntegerValue];

  NSUInteger reps  = [[[sentenceState   _reps]firstObject]unsignedIntegerValue];
  
  NSUInteger value = [[[sentenceState _pounds]firstObject]unsignedIntegerValue];
  
  for (unsigned int i = 0; i < sets; i++)
  {
    [self addSetWithID:exerciseID reps:reps value:value];
  }
}



-(void)addNonPluralCardioSet:(JNSSentenceState * )sentenceState
{
  NSUInteger exerciseID = [sentenceState _exerciseID];
  
  NSUInteger reps  = 1;

  NSUInteger value = 0;
  
  if([[sentenceState _laps]  firstObject])
  {
    value = [[[sentenceState _laps]firstObject]unsignedIntegerValue ];
  }
  if([[sentenceState _miles]  firstObject])
  {
    value = [[[sentenceState _miles]firstObject]unsignedIntegerValue ];
  }
  
  
  [self addSetWithID:exerciseID reps:reps value:value];
  
}
   

-(void)addSetWithID:(NSUInteger) exerciseID
               reps:(NSInteger)reps
              value:(NSInteger)value
{

  // Don't submit record unless reps field is populated
  if ([self _exerciseID] !=0 )
  {
  
    // Get the exercise record id again (in case a new one was just created)
    _exerciseRecordID = [self getCurrentExerciseRecordId:exerciseID];
    
    // Check if an exercise record with this name/id exists for this training plan
   if (_exerciseRecordID == 0)
    {
      // Create an exercise record for this exercise
      [self createExerciseRecord: exerciseID ];
    }
  
    // Get the exercise record id again (in case a new one was just created)
    _exerciseRecordID = [self getCurrentExerciseRecordId:exerciseID];

    
    // Add the new set record
    [self set_addedRecord: [self addSetToExerciseRecord: _exerciseRecordID: reps: value]];
  }
  else
  {
    [self set_addedRecord: NO];
  }
}

-(void)actions_01
{
//  // if you get the same amount of reps and pounds just add the exercise set
//  if([self _isStrengthTraining])
//  {
//    if (DEBUG_PATTERN) { NSLog(@"S Perform Action 1."); }
//    NSUInteger count = [[self get_reps] count];
//    for(unsigned int i = 0; i < count; i++)
//    {
//      NSUInteger reps   = [[[self get_reps  ] objectAtIndex:i] unsignedIntegerValue];
//      NSUInteger pounds = [[[self get_pounds] objectAtIndex:i] unsignedIntegerValue];
//    
//      [self addSetWithID:[self _exerciseID] reps:reps value:pounds];
//      
//    }
//  }
//  // if you get just one mile or lap just added it the excerise set
//  else
//  {
//    if (DEBUG_PATTERN) { NSLog(@"C Perform Action 1."); }
//    
//    if ([[self get_miles] count] == 1)
//    {
//      NSUInteger miles = [[[self get_miles  ] objectAtIndex:0] unsignedIntegerValue];
//      [self addSetWithID:[self _exerciseID] reps:1 value:miles];
//    }
//    else if ([[self get_laps] count] == 1)
//    {
//      NSUInteger laps = [[[self get_laps  ] objectAtIndex:0] unsignedIntegerValue];
//      [self addSetWithID:[self _exerciseID] reps:1 value:laps];
//    }
//  }
}

-(BOOL)rule_01
{
//  // Strength Training Exercise
//  if([self _isStrengthTraining])
//  {
//    if (
//        [self isThereASetHint] &&
//        [[self get_reps] count] > 0 &&
//        [self isEqualLengthArray:[self get_reps] array:[self get_pounds]]
//       )
//    {
//      if (DEBUG_PATTERN) { NSLog(@"S: Rule 1 Passed."); }
//      return YES;
//    }
//    else
//    {
//      if (DEBUG_PATTERN) { NSLog(@"S: Rule 1 Failed."); }
//      return NO;
//    }
//  }
//  // Cardio Exercise
//  else
//  {
//    if (DEBUG_PATTERN) { NSLog(@"C: START"); }
//
//    if (
//        [[self get_miles] count] > 0||
//        [[self get_laps ] count] > 0
//        )
//    {
//      if (DEBUG_PATTERN) { NSLog(@"C: Rule 1 Passed."); }
//      return YES;
//    }
//    else
//    {
//      if (DEBUG_PATTERN) { NSLog(@"C: Rule 1 Failed."); }
//      return NO;
//    }
//  }
  return true;
}


-(void)actions_02
{
//  if([self _isStrengthTraining])
//  {
//    
//  }
//  else
//  {
//    
//  }
}

-(BOOL)rule_02
{
//  if([self _isStrengthTraining])
//  {
//    if (
//        [[self get_reps] count] > 0 &&
//        [[self get_sets] count] > 0
//        )
//    {
//      if (DEBUG_PATTERN) { NSLog(@"S: Rule 2 Passed."); }
//      
//      
//      
//      return YES;
//    }
//    else
//    {
//      if (DEBUG_PATTERN) { NSLog(@"S: Rule 2 Failed."); }
//      return NO;
//    }
//  }
//  else
//  {
//    
//  }
  return YES;
}


-(void)actions_03
{
//  if([self _isStrengthTraining])
//  {
//    
//  }
//  else
//  {
//    
//  }
}

-(BOOL)rule_03
{
//  if([self _isStrengthTraining])
//  {
//    
//  }
//  else
//  {
//    
//  }
  return YES;
}

//-(NSString *)get_sentence
//{
//  return [[self _templateAPI]_sentence];
//}
//
//-(NSArray *)get_sets
//{
//  return [[[self _templateAPI] _brain] objectAtIndex:0];
//}
//-(NSArray *)get_reps
//{
//  return [[[self _templateAPI] _brain] objectAtIndex:1];
//}
//-(NSArray *)get_pounds
//{
//  return [[[self _templateAPI] _brain] objectAtIndex:2];
//}
//-(NSArray *)get_laps
//{
//  return [[[self _templateAPI] _brain] objectAtIndex:3];
//}
//-(NSArray *)get_miles
//{
//  return [[[self _templateAPI] _brain] objectAtIndex:4];
//}
@end