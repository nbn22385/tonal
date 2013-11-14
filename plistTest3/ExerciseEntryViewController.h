//
//  ExerciseEntryViewController.h
//  plistTest3
//
//  Created by Jeremy Ayala on 10/23/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface ExerciseEntryViewController : UIViewController <UITextFieldDelegate>
{
}
// IBOutlets
@property (nonatomic, strong) IBOutlet UILabel *infoLabel;

@property (nonatomic, strong) IBOutlet UITextField *repTextField;
@property (nonatomic, strong) IBOutlet UITextField *weightTextField;

@property (nonatomic, strong) IBOutlet UILabel *repLabel;
@property (nonatomic, strong) IBOutlet UILabel *weightLabel;

@property (nonatomic, strong) IBOutlet UIButton *addSetButton;

@property (nonatomic, strong) IBOutlet UILabel *thirdLabel;
@property (strong, nonatomic) IBOutlet UITextField *thirdTextField;

@property (strong, nonatomic) IBOutlet UITableView *pastSetsTable;

// IBActions
- (IBAction)addSetButtonPressed:(id)sender;

-(void)setUnitInfo;

@property (strong, nonatomic) NSString *databasePath;
@property (strong, nonatomic) NSString *exerciseName;
@property (strong, nonatomic) NSString *unitName;
@property BOOL hasSetsReps;




@end
