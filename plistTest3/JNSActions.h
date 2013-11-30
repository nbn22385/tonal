//
//  JNSActions.h
//  JNSPattern
//
//  Created by JEREMY AYALA on 11/29/13.
//  Copyright (c) 2013 Jeremy Ayala. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JNSTemplateMatch;

@interface JNSActions : NSObject

@property(nonatomic)JNSTemplateMatch *_templateMatcher;
@property(nonatomic) BOOL _addedRecord;
@property(nonatomic) BOOL _isStrengthTraining;
@property(nonatomic) NSUInteger _exerciseID;
@property  NSInteger _exerciseRecordID;


-(id)initWithSentenceNumber:(NSUInteger)index;
-(id)initWithSentence:(NSString *)sentence;

-(void)decideExerciseCategory;
-(BOOL)doThis;
@end
