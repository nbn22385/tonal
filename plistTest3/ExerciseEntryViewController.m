//
//  ExerciseEntryViewController.m
//  plistTest3
//
//  Created by Jeremy Ayala on 10/23/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import "ExerciseEntryViewController.h"
#import "FMDBDataAccess.h"
#import "SetRecord.h"

@interface ExerciseEntryViewController ()

@end

@implementation ExerciseEntryViewController

@synthesize exerciseName, exerciseId, exerciseRecordId, infoLabel;
@synthesize hasSetsReps, unitName;
@synthesize repLabel, repTextField, weightLabel, weightTextField, addSetButton;
@synthesize thirdLabel, thirdTextField;
@synthesize setsTable, items;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // prevent statusbar overlap
    //if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    //    self.edgesForExtendedLayout = UIRectEdgeNone;
    
	// Set the title
    self.navigationItem.title = exerciseName;
    
    // Display the summary statement
    NSString *str = @"Add ";
    str = [str stringByAppendingString:exerciseName];
    str = [str stringByAppendingString:@" to your training plan by completing the information below."];
    infoLabel.text = str;
    
    // Determine what units will be used
    [self setUnitInfo];

    // Toggle the controls according to the exercise
    [self configureControls];
    
    // Set the exercise id
    exerciseId = [self getIdForExerciseName];
    
    // Set the exercise record id
    exerciseRecordId = [self getCurrentExerciseRecordId];
    
    // Set up sets tableview
    setsTable.dataSource = self;
    setsTable.delegate = self;
    items = [self getSetRecords:exerciseRecordId];

}

- (void)configureControls
{
    
    if (hasSetsReps)
    {
        // Show rep, weight inputs
        [repTextField setHidden:FALSE];
        [weightTextField setHidden:FALSE];
        [weightTextField setPlaceholder:[unitName capitalizedString]];
        [repLabel setHidden:FALSE];
        [weightLabel setHidden:FALSE];
        [addSetButton setTitle:@"Add Set" forState:UIControlStateNormal];
        
        // Hide secondary input
        [thirdTextField setHidden:TRUE];
        [thirdLabel setHidden:TRUE];
        
    }
    else
    {
        // Show secondary input
        [thirdTextField setHidden:FALSE];
        [thirdTextField setPlaceholder:[unitName capitalizedString]];
        [thirdLabel setHidden:FALSE];
        [addSetButton setTitle:@"Add Activity" forState:UIControlStateNormal];
        //thirdLabel.text = [unitName capitalizedString];

        // Hide rep, weight inputs
        [repTextField setHidden:TRUE];
        [weightTextField setHidden:TRUE];
        [repLabel setHidden:TRUE];
        [weightLabel setHidden:TRUE];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Button click

- (IBAction)addSetButtonPressed:(id)sender
{
    // Hide the keyboard
    [repTextField resignFirstResponder];
    [weightTextField resignFirstResponder];
    [thirdTextField resignFirstResponder];
    
    // Don't submit record unless reps field is populated
    if (![repTextField.text isEqual: @""]) {
    
        // Check if an exercise record with this name/id exists for this training plan
        if (exerciseRecordId == 0) {
            // Create an exercise record for this exercise
            [self createExerciseRecord];
        }

        // Get the exercise record id again (in case a new one was just created)
        exerciseRecordId = [self getCurrentExerciseRecordId];
        
        // Get the values from the text fields
        NSInteger reps = [repTextField.text integerValue];
        NSInteger value = [weightTextField.text integerValue];
        
        // Add the new set record
        [self addSetToExerciseRecord: exerciseRecordId: reps: value];
        
        // Clear the text fields
        repTextField.text = @"";
        weightTextField.text = @"";
        
        // Repopulate the set table
        items = [self getSetRecords:exerciseRecordId];
        [self.setsTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [items count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setCell" forIndexPath:indexPath];
    
    // SetRecord for cell population
    SetRecord* sr = [SetRecord alloc];
    sr = [items objectAtIndex:indexPath.row];
    
    // Set up the cell
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    cell.textLabel.text = [NSString stringWithFormat:@"%dx%d",[sr numReps], [sr value]];
    
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[sr date]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    cell.detailTextLabel.text = dateString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// open a alert with an OK and cancel button
//	NSString *alertString = [NSString stringWithFormat:@"Clicked on row #%d", [indexPath row]];
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertString message:@"" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
//	[alert show];
}

#pragma mark - Database functions

-(void)setUnitInfo
{
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *unitString = [defaults objectForKey:@"unitString"];
    NSInteger i = [defaults integerForKey:@"unitSelection"];
    
    hasSetsReps = [db hasSetsReps:(exerciseName)];
    unitName = [db getUnitName:(exerciseName)];
    
    // If the user wants metric, change the placeholder text
    if ([unitString isEqualToString:@"Metric"]) {
        if ([unitName isEqualToString:@"pounds"]) {
            unitName = @"kilograms";
        }
        if ([unitName isEqualToString:@"miles"]) {
            unitName = @"kilometers";
        }
    }

}

-(NSInteger)getIdForExerciseName
{
    NSInteger eId = -1;
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    eId = [db getIdForExerciseName:self.exerciseName];
    return eId;
}

-(NSInteger)getCurrentExerciseRecordId
{
    NSInteger id;
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    
    id = [db getCurrentExerciseRecordId:exerciseId];
    return id;
}

-(BOOL)exerciseExistsInTrainingPlan
{
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];

    NSInteger id = [db exerciseExistsInTrainingPlan:exerciseId];
    BOOL result = (id > 0) ? TRUE : FALSE;
    
    return result;
}

-(BOOL)createExerciseRecord
{
    // need tp_parent_id, exercise_id
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    BOOL result = [db createExerciseRecord:exerciseId];
    return result;
    
}

///
/// Database function to return sets for an exercise record
/// @param Exercise record id
/// @return Array of setRecord objects
///
-(void)addSetToExerciseRecord:(NSInteger)erId :(NSInteger)reps :(NSInteger)value
{
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    BOOL result = FALSE;
    result = [db addSetToExerciseRecord: erId: reps: value];
    
}

///
/// Database function to return sets for an exercise record
/// @param Exercise record id
/// @return Array of setRecord objects
///
-(NSArray*)getSetRecords:(NSInteger)forErId
{
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    NSArray* result = [NSArray array];

    result = [db getSetRecords:exerciseRecordId];

    return result;
}

@end
