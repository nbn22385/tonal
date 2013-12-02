//
//  JNSTemplateMatch.h
//  JNSPattern
//
//  Created by JEREMY AYALA on 11/29/13.
//  Copyright (c) 2013 Jeremy Ayala. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEBUG_PATTERN 1

@class JNSSentenceState;
 
@interface JNSTemplateMatch : NSObject
{
//  NSMutableArray *_sets;
//  NSMutableArray *_reps;
//  NSMutableArray *_pounds;
//  
//  NSMutableArray *_laps;
//  NSMutableArray *_miles;
}

//@property (nonatomic, copy) NSString * _sentence;
//@property (nonatomic, copy) NSArray * _brain;

-(id)init;
-(id)initDemoWithSentence:(NSUInteger)item;

//-(NSUInteger)getExerciseID;

-(NSString *)createPOSWithSentence:(NSString *)sentence;

-(NSString *)correctNumberTagInSentence:(NSString *)sentence;

-(JNSSentenceState *)gatherInitialMetricsWithState:(JNSSentenceState *)sentenceState;
-(JNSSentenceState *)gatherComplexMatrics:(JNSSentenceState *)sentenceState;

-(NSArray *)findPattern:(NSString *)pattern
             inSentence:(NSString *)sentence;

-(void)printMatches:(NSArray  *)matchList
         inSentence:(NSString *)sentence;

-(NSString *)replacePattern:(NSString *)pattern
                 inSentence:(NSString *)sentence
                       with:(NSString *)myTemplate;

@end
