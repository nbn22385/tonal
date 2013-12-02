//
//  voiceViewController.m
//  tonal
//
//  Created by JEREMY AYALA on 11/25/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import "voiceViewController.h"
#import "FMDBDataAccess.h"
#import "JNSKnowledgeAgent.h"
#import "JNSActions.h"

@implementation voiceViewController 
{

}
@synthesize _action, _addedRecord;

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
	// Do any additional setup after loading the view.
  self.navigationItem.title = @"Voice Input";

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
  NSLog(@"textViewDidBeginEditing");

  NSString *string = [textView text];
  if ([string rangeOfString:@"Click Here"].location == NSNotFound) {
    NSLog(@"string does not contain bla");
  } else {
    [textView setText:@""];
  }
  
  NSLog(@"YES");
}


-(void)dictationRecordingDidEnd
{
  NSLog(@"dictationRecordingDidEnd");

}

- (IBAction)addSetButtonPressed:(id)sender
{
  // Hide the keyboard
  //[repTextField resignFirstResponder];
  //[weightTextField resignFirstResponder];
  //[thirdTextField resignFirstResponder];
  
  NSString *string = [inputExerciseField text];
  if ([string rangeOfString:@"Click Here"].location == NSNotFound || [string rangeOfString:@"Added Exercise to Training Plan."].location == NSNotFound)
  {

    if (![[inputExerciseField text] isEqualToString:@""])
    {
      [ self set_action: [[JNSActions alloc] initWithSentence:[inputExerciseField text]]];
      
      [self set_addedRecord:[[self _action] _addedRecord]];
    }
    else{
      NSLog(@"nothing added nice try");
    }
  }
  else{
    NSLog(@"nothing new added nice try");
  }

  if([self _addedRecord])
  {
    [inputExerciseField setText:@"Added Exercise to Training Plan."];
  }
  
}

- (IBAction)clearButtonPressed:(id)sender
{

  [inputExerciseField setText:@""];
  
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  //[ self set_action: [[JNSActions alloc] initWithSentence:[inputExerciseField text]]];
  //[[ self _action ] doThis];
  
  NSLog(@"touchesEnded");
  [[self view] endEditing:YES];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
  NSLog(@"textViewShouldEndEditing");
  
  return YES;
}

-(void)addSetToExerciseRecord:(NSInteger)erId :(NSInteger)reps :(NSInteger)value
{
  FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
  BOOL result = FALSE;
  result = [db addSetToExerciseRecord: erId: reps: value];
}

@end
