//
//  JNSSentenceState.h
//  tonal
//
//  Created by JEREMY AYALA on 12/1/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JNSSentenceState;

@interface JNSSentenceState : NSObject

@property (nonatomic, copy) NSMutableArray * _sets;
@property (nonatomic, copy) NSMutableArray * _reps;
@property (nonatomic, copy) NSMutableArray * _pounds;

@property (nonatomic, copy) NSMutableArray * _laps;
@property (nonatomic, copy) NSMutableArray * _miles;

@property (nonatomic) NSUInteger _exerciseID;
@property (nonatomic, copy) NSString *_sentence;

// Flags
@property(nonatomic) BOOL _isSetsPlural;
@property(nonatomic) BOOL _isSetIncludedWithState;

@property(nonatomic) BOOL _isNumberPerpNumberUsed;
@property(nonatomic) BOOL _isNumberTimesNumberUsed;

@property(nonatomic) BOOL _isStrengthTraining;

@property(nonatomic) BOOL _isRepsAndPoundsCountEqual;
@property(nonatomic) BOOL _isRepCountGreaterThanZero;
@property(nonatomic) BOOL _isLapsCountGreaterThanZero;
@property(nonatomic) BOOL _isMilesCountGreaterThanZero;



-(id)init;

@end
