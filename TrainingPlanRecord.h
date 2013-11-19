//
//  TrainingPlanRecord.h
//  tonal
//
//  Created by Jeremy Ayala on 11/18/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrainingPlanRecord : NSObject

/// Start Date of this training plan record
@property NSDate* startDate;

/// End Date of this training plan record
@property NSDate* endDate;

/// Name of this training plan record
@property NSString* name;

@end
