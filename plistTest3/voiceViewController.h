//
//  voiceViewController.h
//  tonal
//
//  Created by JEREMY AYALA on 11/25/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface voiceViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
  IBOutlet UITextView *inputExerciseField;
}
//-(IBAction)getInputSentence:(id)sender;

@end
