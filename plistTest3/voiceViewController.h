//
//  voiceViewController.h
//  tonal
//
//  Created by JEREMY AYALA on 11/25/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JNSActions;

@interface voiceViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
  IBOutlet UITextView *inputExerciseField;

}

@property (nonatomic) JNSActions *_action;

//-(IBAction)getInputSentence:(id)sender;
- (IBAction)addSetButtonPressed:(id)sender;

@end
