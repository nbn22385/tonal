//
//  JNSSentenceState.m
//  tonal
//
//  Created by JEREMY AYALA on 12/1/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import "JNSSentenceState.h"

@implementation JNSSentenceState

@synthesize _laps, _sets, _sentence, _miles, _pounds, _reps, _exerciseID;

// Flags
@synthesize _isSetsPlural, _isNumberPerpNumberUsed, _isStrengthTraining, _isRepsAndPoundsCountEqual, _isMilesCountGreaterThanZero;
@synthesize _isRepCountGreaterThanZero, _isNumberTimesNumberUsed, _isSetIncludedWithState, _isLapsCountGreaterThanZero;

-(id)init
{
  self = [super init];
  
  if(self)
  {
    // Init the variables used in the class
    _sets   = [[NSMutableArray alloc] init];
    _reps   = [[NSMutableArray alloc] init];
    _pounds = [[NSMutableArray alloc] init];
    
    _laps   = [[NSMutableArray alloc] init];
    _miles  = [[NSMutableArray alloc] init];
  }
  
  return self;
}
@end
