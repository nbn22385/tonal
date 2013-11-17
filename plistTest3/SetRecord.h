//
//  SetRecord.h
//  tonal
//
//  Created by Jeremy Ayala on 11/17/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetRecord : NSObject {
    
}

/// Exercise record parent id for this set record
@property NSInteger erParentId;

/// Number of reps in this set record
@property NSInteger numReps;

/// Value for this set record (weight/laps/miles)
@property NSInteger value;

/// Date of this set record
@property NSDate* date;


@end
