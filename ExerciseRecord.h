//
//  ExerciseRecord.h
//  tonal
//
//  Created by JEREMY AYALA on 12/1/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExerciseRecord : NSObject

/// Exercise record id
@property NSInteger erId;

/// Training plan parent id for this set record
@property NSInteger tpParentId;

/// Exercise id
@property NSInteger exerciseId;

///
@property NSString *exerciseName;

@end
