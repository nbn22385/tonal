//
//  ExerciseEntryViewController.m
//  plistTest3
//
//  Created by Jeremy Ayala on 10/23/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import "ExerciseEntryViewController.h"
#import "FMDBDataAccess.h"

@interface ExerciseEntryViewController ()

@end

@implementation ExerciseEntryViewController

@synthesize exerciseName, infoLabel;
//@synthesize hasSetsReps;
@synthesize repLabel, repTextField, weightLabel, weightTextField, addSetButton;
@synthesize thirdLabel, thirdTextField;

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


- (IBAction)addSetButtonPressed:(id)sender
{
    // Hide the keyboard
    [repTextField resignFirstResponder];
    [weightTextField resignFirstResponder];
    
    // Clear the text fields
    repTextField.text = @"";
    weightTextField.text = @"";

}

#pragma mark - Database functions

-(void)setUnitInfo
{
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];

    
    self.hasSetsReps = [db hasSetsReps:(exerciseName)];
    self.unitName = [db getUnitName:(exerciseName)];
    
}

@end
