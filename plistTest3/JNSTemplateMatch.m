//
//  JNSTemplateMatch.m
//  JNSPattern
//
//  Created by JEREMY AYALA on 11/29/13.
//  Copyright (c) 2013 Jeremy Ayala. All rights reserved.
//

#import "JNSTemplateMatch.h"
#import "JNSSentenceState.h"

@implementation JNSTemplateMatch

-(id)initDemoWithSentence:(NSUInteger)item
{
  self = [super init];
  
  NSArray *sentences = [NSArray arrayWithObjects:
                        // 0
                        @"I did Triceps Pussdown four sets the first set i completed 88 reps with 20 pounds the second set i did 12 reps with 50 pounds and the third set I did 10 pounds for 205 reps the fourth set I did 8 pounds with 275 reps and the last set i did 6 pounds for 30 reps.",
                        // 1
                        @"I did triceps push down four sets the first set i completed 98 reps with 20 pounds and then i did 12 reps with 50 pounds and then I did 10 pounds for 205 reps the fourth set I did 8 pounds with 25 reps and then i did 6 pounds for 30 reps.",
                        // 2
                        @"I did triceps push down four sets the first set i completed 80 reps with 20 pounds and 12 reps with 50 pounds and then 10 pounds for 2005 reps also  8 pounds with 25 reps also i did 6 pounds for 30 reps.",
                        // 3
                        @"I did triceps dipfour sets the first set i completed 8 reps with 20 pounds next 12 reps with 50 pounds and then 10 pounds for 2095 reps next  8 pounds with 25 reps also i did 6 pounds for 30 reps.",
                        // 4
                        @"I did 2 reps of Bench for 80 pounds",
                        // 5
                        @"I swam the butterfly for 16 laps",
                        // 6
                        @"I did 3 sets of 12 reps 1 with 45 pounds and 2 with 35 pounds.",
                        // 7
                        @"I did 3 by 3 of Bench Press",
                        nil];
  
  if(self)
  {
    // Init the variables used in the class
//    _sets   = [[NSMutableArray alloc] init];
//    _reps   = [[NSMutableArray alloc] init];
//    _pounds = [[NSMutableArray alloc] init];
//    
//    _laps   = [[NSMutableArray alloc] init];
//    _miles  = [[NSMutableArray alloc] init];
    
//    [self set_brain: [NSArray arrayWithObjects:_sets,_reps, _pounds, _laps, _miles, nil]];

    // Copy sentence to the class
//    [self set_sentence: [sentences objectAtIndex:item]];
    
    
  }
  return self;
}


-(id)init
{
  self = [super init];
  
  if(self)
  {
    // Init the variables used in the class
   // _sets   = [[NSMutableArray alloc] init];
   // _reps   = [[NSMutableArray alloc] init];
   // _pounds = [[NSMutableArray alloc] init];

   // _laps   = [[NSMutableArray alloc] init];
   // _miles  = [[NSMutableArray alloc] init];
    
    //_brain =[NSArray arrayWithObjects:_sets,_reps, _pounds, _laps, _miles, nil];

    // Copy sentence to the class
    //[self set_sentence:sentence];
    
    
  }
  return self;
}

//-(NSUInteger)getExerciseID
//{
//  
//  return 1;
//}


// return the corrected tagged sentence
-(NSString *)createPOSWithSentence:(NSString *)sentence
{
  
  NSString *tagSentence = @"";
  NSMutableArray *tagArray = [[NSMutableArray alloc] init];
  

  NSRange range = NSMakeRange(0, [sentence length]);
  
  NSLinguisticTagger *tagger =[[NSLinguisticTagger alloc]
                               initWithTagSchemes:
                               [NSArray arrayWithObjects:
                                NSLinguisticTagSchemeTokenType,      // basic token
                                NSLinguisticTagSchemeLexicalClass,   // term for part of speech analysis
                                NSLinguisticTagSchemeNameType,       // name recognition
                                NSLinguisticTagSchemeNameTypeOrLexicalClass,
                                NSLinguisticTagSchemeLemma, nil]     // lemma head word in the dictionary
                               options: 0];
  
  NSDictionary *map = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:@"en", nil] forKey:@"Latn"];
  NSOrthography *orthography = [NSOrthography orthographyWithDominantScript:@"Latn" languageMap:map];
  
  // Send the sentence to the tagger
  [tagger setString:sentence];
  [tagger setOrthography:orthography range:range];
  
  [tagger enumerateTagsInRange:range
                        scheme:NSLinguisticTagSchemeLexicalClass
                       options:NSLinguisticTaggerOmitWhitespace // you can omit white space
                    usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop)
   {
     NSString *token = [sentence substringWithRange:tokenRange];
     
     [tagArray addObject:[NSString stringWithFormat:@"<%@/%@> ",token, tag]];
   }];
  
  for(NSString * tagPair in tagArray)
  {
    tagSentence = [tagSentence stringByAppendingString: tagPair];
  }
  
  tagSentence = [self correctNumberTagInSentence: tagSentence];
  
  return tagSentence;
}


-(NSString *)correctNumberTagInSentence:(NSString *)sentence
{
  // Fix the numbers getting tagged as pronouns
  NSString *pattern    = @"<([0-9]+)/[a-zA-Z]+>";
  NSString *newPattern = @"<$1/Number>";
  NSString *newSentence = [self replacePattern:pattern inSentence:sentence with:newPattern];
  
  // Fix the reps getting tagged as verbs
  pattern    = @"<(rep(s)?)/([a-zA-Z]+)>";
  newPattern = @"<$1/Noun>";
  newSentence = [self replacePattern:pattern inSentence:newSentence with:newPattern];
  
  // Fix the reps getting spelled as wraps
  pattern    = @"<(wrap(s)?)/([a-zA-Z]+)>";
  newPattern = @"<rep/Noun>";
  newSentence = [self replacePattern:pattern inSentence:newSentence with:newPattern];
  
  // Fix numbers that are spelled out
  NSArray *wordNumList = [NSArray arrayWithObjects:@"zero", @"one", @"two", @"three", @"four", @"five", @"six", @"seven", @"eight", @"nine", @"ten", @"eleven",@"twelve",@"thirteen",@"fourteen",@"fifteen",@"sixteen",@"seventeen",@"eighteen",@"nineteen",@"twenty", nil];
  
  NSUInteger wordCount = [wordNumList count];
  for(unsigned int i = 0; i < wordCount; i++)
  {
    pattern    = [NSString stringWithFormat:@"<%@/Number>",[wordNumList objectAtIndex:i]];

    newPattern = [NSString stringWithFormat:@"<%i/Number>", i];
    
    newSentence = [self replacePattern:pattern inSentence:newSentence with:newPattern];
  }
  
  if (DEBUG_PATTERN) { NSLog(@"Corrected Sentence: %@", newSentence); }
  
  

  return newSentence;
}

//_brain =[NSArray arrayWithObjects:_sets,_reps, _pounds, _laps, _miles, nil];

-(JNSSentenceState *)gatherInitialMetricsWithState:(JNSSentenceState *)sentenceState
{
  
  //Find Reps
  NSString *pattern = @"<[0-9]+/Number> <rep(s)?/Noun>";
  NSArray *matchList = [NSArray arrayWithArray:[self findPattern:pattern inSentence: [sentenceState _sentence]]];
  
  if ([matchList count] > 0)
  {
    if (DEBUG_PATTERN) { NSLog(@"Rep");[self printMatches:matchList inSentence:[sentenceState _sentence]]; }
    
    for (NSNumber *item in [self getNumberListFromSentence:[sentenceState _sentence] matchList:matchList])
    {
      [[sentenceState _reps] addObject:item];
    }
  }
  
  //Find sets
  pattern = @"<[0-9]+/Number> <set(s)?/Noun>";
  matchList = [NSArray arrayWithArray:[self findPattern:pattern inSentence:[sentenceState _sentence]]];
  if ([matchList count] > 0)
  {
    if (DEBUG_PATTERN) { NSLog(@"Pound"); [self printMatches:matchList inSentence:[sentenceState _sentence]];}
    
    for (NSNumber *item in [self getNumberListFromSentence:[sentenceState _sentence] matchList:matchList])
    {
      [[sentenceState _sets] addObject:item];
    }
  }
  
  //Find Pounds
  pattern = @"<[0-9]+/Number> <pound(s)?/Noun>";
  matchList = [NSArray arrayWithArray:[self findPattern:pattern inSentence:[sentenceState _sentence]]];
  if ([matchList count] > 0)
  {
    if (DEBUG_PATTERN) { NSLog(@"Pound"); [self printMatches:matchList inSentence:[sentenceState _sentence]];}

    for (NSNumber *item in [self getNumberListFromSentence:[sentenceState _sentence] matchList:matchList])
    {
      [[sentenceState _pounds] addObject:item];
    }
  }
  
  //Find Laps
  pattern = @"<[0-9]+/Number> <lap(s)?/Noun>";
  matchList = [NSArray arrayWithArray:[self findPattern:pattern inSentence:[sentenceState _sentence]]];
  if (DEBUG_PATTERN) { NSLog(@"Lap"); [self printMatches:matchList inSentence:[sentenceState _sentence]];}

  for (NSNumber *item in [self getNumberListFromSentence:[sentenceState _sentence] matchList:matchList])
  {
    [[sentenceState _laps] addObject:item];
  }
  
  //Find Miles
  pattern = @"<[0-9]+/Number> <mile(s)?/Noun>";
  matchList = [NSArray arrayWithArray:[self findPattern:pattern inSentence:[sentenceState _sentence]]];
  if (DEBUG_PATTERN) { NSLog(@"Mile"); [self printMatches:matchList inSentence:[sentenceState _sentence]];}

  for (NSNumber *item in [self getNumberListFromSentence:[sentenceState _sentence] matchList:matchList])
  {
    [[sentenceState _miles] addObject:item];
  }
  return sentenceState;
}


-(JNSSentenceState *)gatherComplexMatrics:(JNSSentenceState *)sentenceState
{
  //Find Reps Complex Pattern
  NSString *pattern  = @"<[0-9]+/Number> (<[a-zA-Z]+/Preposition>|<(x|time(s)?)/Noun>) <[0-9]+/Number> (<[a-zA-Z]+/Preposition>|<(x|time(s)?)/Noun>) <[0-9]+/Number>";
  NSArray *matchList = [NSArray arrayWithArray:[self findPattern:pattern inSentence:[sentenceState _sentence]]];
  if (DEBUG_PATTERN) { NSLog(@"Rep");[self printMatches:matchList inSentence:[sentenceState _sentence]]; }
  
  for (NSNumber *item in [self getNumberListFromRepsSection:[sentenceState _sentence] matchList:matchList])
  {
    [[sentenceState _reps] addObject:item];
  }
  
  //Find Pounds Complex Pattern
  pattern = @"<[0-9]+/Number> (<[a-zA-Z]+/Preposition>|<(x|time(s)?)/Noun>) <[0-9]+/Number> (<[a-zA-Z]+/Preposition>|<(x|time(s)?)/Noun>) <[0-9]+/Number>";
  matchList = [NSArray arrayWithArray:[self findPattern:pattern inSentence:[sentenceState _sentence]]];
  if (DEBUG_PATTERN) { NSLog(@"Pound"); [self printMatches:matchList inSentence:[sentenceState _sentence]];}
  
  for (NSNumber *item in [self getNumberListFromPoundsSection:[sentenceState _sentence] matchList:matchList])
  {
    [[sentenceState _pounds] addObject:item];
  }
  
  //Find Set Complex Pattern
  pattern = @"<[0-9]+/Number> (<[a-zA-Z]+/Preposition>|<(x|time(s)?)/Noun>) <[0-9]+/Number> (<[a-zA-Z]+/Preposition>|<(x|time(s)?)/Noun>) <[0-9]+/Number>";
  matchList = [NSArray arrayWithArray:[self findPattern:pattern inSentence:[sentenceState _sentence]]];
  if (DEBUG_PATTERN) { NSLog(@"Lap"); [self printMatches:matchList inSentence:[sentenceState _sentence]];}
  
  for (NSNumber *item in [self getNumberListFromSetsSection:[sentenceState _sentence] matchList:matchList])
  {
    [[sentenceState _sets] addObject:item];
  }
  
  return sentenceState;
}





// get the number in Set
-(NSArray *)getNumberListFromSetsSection:(NSString *)sentence
                               matchList:(NSArray  *)matchList
{
  NSMutableArray *results = [[NSMutableArray alloc] init];
  
  for (NSTextCheckingResult *match in matchList)
  {
    NSRange r = [match range];
    NSString *section = [sentence substringWithRange:r];
    
    
    [results addObject:[NSNumber numberWithInteger:[self getIntegerValueFromSetsSection:section]]];
  }
  return results;
}
// get the integer value from the Set
-(NSUInteger)getIntegerValueFromSetsSection:(NSString *)section
{
  NSString *pattern    = @"<([0-9]+)/Number> (<[a-zA-Z]+/Preposition>|<(x|time(s)?)/Noun>) <[0-9]+/Number> (<[a-zA-Z]+/Preposition>|<(x|time(s)?)/Noun>) <[0-9]+/Number>";
  NSString *newPattern = @"$1";
  
  NSString *value = [self replacePattern:pattern inSentence:section with:newPattern];
  
  //NSLog(@Integer Value:  %lu", (NSUInteger)[value integerValue]);
  
  return (NSInteger)[value integerValue];
}

// get the number in rep section
-(NSArray *)getNumberListFromRepsSection:(NSString *)sentence
                        matchList:(NSArray  *)matchList
{
  NSMutableArray *results = [[NSMutableArray alloc] init];
  
  for (NSTextCheckingResult *match in matchList)
  {
    NSRange r = [match range];
    NSString *section = [sentence substringWithRange:r];
    
    
    [results addObject:[NSNumber numberWithInteger:[self getIntegerValueFromRepsSection:section]]];
  }
  return results;
}

// get the integer value from the rep section
-(NSUInteger)getIntegerValueFromRepsSection:(NSString *)section
{
  NSString *pattern    = @"<[0-9]+/Number> (<[a-zA-Z]+/Preposition>|<(x|time(s)?)/Noun>) <([0-9]+)/Number> (<[a-zA-Z]+/Preposition>|<(x|time(s)?)/Noun>) <[0-9]+/Number>";
  NSString *newPattern = @"$4";
  NSString *value = [self replacePattern:pattern inSentence:section with:newPattern];
  
  NSLog(@"Integer Value:  %i", (NSUInteger)[value integerValue]);

  return (NSInteger)[value integerValue];
}
                        
                        
// get the number in pounds
-(NSArray *)getNumberListFromPoundsSection:(NSString *)sentence
                        matchList:(NSArray  *)matchList
{
  NSMutableArray *results = [[NSMutableArray alloc] init];
  
  for (NSTextCheckingResult *match in matchList)
  {
    NSRange r = [match range];
    NSString *section = [sentence substringWithRange:r];
    
    
    [results addObject:[NSNumber numberWithInteger:[self getIntegerValueFromPoundsSection:section]]];
  }
  return results;
}
                        
// get the integer value from the pounds
-(NSUInteger)getIntegerValueFromPoundsSection:(NSString *)section
{
  NSString *pattern    = @"<[0-9]+/Number> (<[a-zA-Z]+/Preposition>|<(x|time(s)?)/Noun>) <[0-9]+/Number> (<[a-zA-Z]+/Preposition>|<(x|time(s)?)/Noun>) <([0-9]+)/Number>";
  NSString *newPattern = @"$7";
  
  NSString *value = [self replacePattern:pattern inSentence:section with:newPattern];
  
  NSLog(@"Integer Value:  %i", (NSUInteger)[value integerValue]);
  
  return (NSInteger)[value integerValue];
}
    
                        
                        

                        
                        
                        
                        
                        
                        
                        
                        
                        
// get the number in front of  a number-noun set
-(NSArray *)getNumberListFromSentence:(NSString *)sentence
                            matchList:(NSArray  *)matchList
  {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    for (NSTextCheckingResult *match in matchList)
    {
      NSRange r = [match range];
      NSString *section = [sentence substringWithRange:r];
      
      
      [results addObject:[NSNumber numberWithInteger:[self getIntegerValueFromSection:section]]];
    }
    return results;
  }

// get the integer value from the <number/tag> pair// secondary funtion for above results
-(NSUInteger)getIntegerValueFromSection:(NSString *)section
{
  NSString *pattern    = @"<([0-9]+)/Number> <[a-zA-Z]+/Noun>";
  NSString *newPattern = @"$1";
  
  NSString *value = [self replacePattern:pattern inSentence:section with:newPattern];
  
  //NSLog(@Integer Value:  %lu", (NSUInteger)[value integerValue]);
  
  return (NSInteger)[value integerValue];
}

// get word from a  num-noun pair
-(NSString *)getStringValueFromSection:(NSString *)section
{
  NSString *pattern    = @"<([a-zA-Z]+)/Number> <[a-zA-Z]+/Noun>";
  NSString *newPattern = @"$1";
  
  NSString *value = [self replacePattern:pattern inSentence:section with:newPattern];
  
  //NSLog(@Integer Value:  %lu", (NSUInteger)[value integerValue]);
  
  return value;
}


-(void)printMatches:(NSArray  *)matchList
         inSentence:(NSString *)sentence
{
  for (NSTextCheckingResult *match in matchList)
  {
    NSRange r = [match range];
    NSString *subString = [sentence substringWithRange:r];
    
    NSLog(@"Match at P{%lu,%lu} is %@",(unsigned long)r.location, (unsigned long)r.length, subString);
  }
}


// return a string of with the new template values
-(NSString *)replacePattern:(NSString *)pattern
                 inSentence:(NSString *)sentence
                       with:(NSString *)myTemplate
{
  NSRegularExpression *reg = [[NSRegularExpression alloc]initWithPattern:pattern
                                                                 options:NSRegularExpressionCaseInsensitive
                                                                   error:nil];
  
  NSString *newSentence = [reg stringByReplacingMatchesInString:sentence
                                                        options:0
                                                          range:NSMakeRange(0, [sentence length])
                                                   withTemplate:myTemplate];
  return newSentence;
}


// find pattern in sentence and return matches
-(NSArray *)findPattern:(NSString *)pattern
            inSentence:(NSString *)sentence
{
  NSRegularExpression *reg = [[NSRegularExpression alloc]
                              initWithPattern:pattern
                              options:NSRegularExpressionCaseInsensitive
                              error:nil];
  
  NSArray *matchList = [reg matchesInString:sentence options:0 range:NSMakeRange(0, [sentence length])];
  
  return matchList;
}


// find a pattern in a certain range and return matches
-(NSArray *)findPattern:(NSString *)pattern
             inSentence:(NSString *)sentence
              withRange:(NSRange   )withRange
{
    NSRegularExpression *reg = [[NSRegularExpression alloc]
                                initWithPattern:pattern
                                options:NSRegularExpressionCaseInsensitive
                                error:nil];
    
    NSArray *matchList = [reg matchesInString:sentence options:0 range:withRange];
  
  return matchList;
}


@end
