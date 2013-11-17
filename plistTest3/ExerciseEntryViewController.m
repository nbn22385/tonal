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

@synthesize exerciseName, infoLabel;
//@synthesize hasSetsReps;
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
    self.exerciseId = [self getIdForExerciseName];
    
    // Set the exercise record id
    self.exerciseRecordId = [self getCurrentExerciseRecordId];
    
    // Set up sets tableview
    setsTable.dataSource = self;
    setsTable.delegate = self;
    items = [self getSetRecords:self.exerciseRecordId];

}

- (void)configureControls
{
    
    if (self.hasSetsReps)
    {
        // Show rep, weight inputs
        [repTextField setHidden:FALSE];
        [weightTextField setHidden:FALSE];
        [weightTextField setPlaceholder:[self.unitName capitalizedString]];
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
        [thirdTextField setPlaceholder:[self.unitName capitalizedString]];
        [thirdLabel setHidden:FALSE];
        [addSetButton setTitle:@"Add Activity" forState:UIControlStateNormal];
        //thirdLabel.text = [self.unitName capitalizedString];

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
    
    // Check if an exercise record with this name/id exists for this training pla
    if (self.exerciseRecordId == 0) {
        // Create an exercise record for this exercise
        [self createExerciseRecord];
    }

    // Get the exercise record id again (in case a new one was just created)
    self.exerciseRecordId = [self getCurrentExerciseRecordId];
    
    NSInteger reps = [repTextField.text integerValue];
    NSInteger value = [weightTextField.text integerValue];
    
    // Add the new set record
    [self addSetToExerciseRecord: self.exerciseRecordId: reps: value];
    
    // Clear the text fields
    repTextField.text = @"";
    weightTextField.text = @"";
    
    // Repopulate the set table
    items = [self getSetRecords:self.exerciseRecordId];
    [self.setsTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];


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
    
    //static NSString *CellIdentifier = @"setCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setCell" forIndexPath:indexPath];
    
    // Temp SetRecord for cell population
    SetRecord* sr = [SetRecord alloc];
    sr = [items objectAtIndex:indexPath.row];
    
    // Set up the cell...
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    //cell.textLabel.text = [NSString stringWithFormat:@"Cell Row #%d", [indexPath row]];
    //cell.textLabel.text = [items objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%d, %d",[sr numReps], [sr value]];
    
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

    
    self.hasSetsReps = [db hasSetsReps:(exerciseName)];
    self.unitName = [db getUnitName:(exerciseName)];
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
    
    id = [db getCurrentExerciseRecordId:self.exerciseId];
    return id;
}

-(BOOL)exerciseExistsInTrainingPlan
{
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];

    NSInteger id = [db exerciseExistsInTrainingPlan:self.exerciseId];
    BOOL result = (id > 0) ? TRUE : FALSE;
    
    return result;
}

-(BOOL)createExerciseRecord
{
    // need tp_parent_id, exercise_id
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    BOOL result = [db createExerciseRecord:self.exerciseId];
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

    result = [db getSetRecords:self.exerciseRecordId];

    return result;
}

@end
