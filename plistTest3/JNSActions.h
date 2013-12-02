//
//  JNSActions.h
//  JNSPattern
//
//  Created by JEREMY AYALA on 11/29/13.
//  Copyright (c) 2013 Jeremy Ayala. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JNSTemplateMatch, JNSSentenceState;

@interface JNSActions : NSObject


@property(nonatomic, copy) NSString *_sentence;
@property(nonatomic) JNSTemplateMatch *_templateAPI;

@property(nonatomic) NSUInteger _exerciseCount;
@property(nonatomic) NSUInteger _exerciseID;
@property(nonatomic) NSInteger _exerciseRecordID;

// Flags
  @property(nonatomic) BOOL _addedRecord;
//@property(nonatomic) BOOL _isSetsPlural;
//@property(nonatomic) BOOL _isNumberPerpNumberUsed;
//@property(nonatomic) BOOL _isNumberTimesNumberUsed;
//@property(nonatomic) BOOL _isStrengthTraining;
//@property(nonatomic) BOOL _isRepsAndPoundsCountEqual;
//@property(nonatomic) BOOL _isRepCountGreaterThanZero;

@property (nonatomic) JNSSentenceState *_oldJNSSentenceState;
@property (nonatomic, copy) NSMutableArray *_verbSentenceStateList;

-(id)initWithSentence:(NSString *)sentence;
//-(id)initWithSentenceNumber:(NSUInteger)index;

//-(void)isStrengthTraining;
-(void)getExerciseIDFromSentence:(NSString *)sentence;

-(BOOL)doThis;
@end
