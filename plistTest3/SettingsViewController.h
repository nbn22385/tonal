//
//  SettingsViewController.h
//  tonal
//
//  Created by Jeremy Ayala on 11/18/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController {
    IBOutlet UISegmentedControl *segmentedControl;
}

@property NSUserDefaults *defaults;
@property NSString *unitString;

- (IBAction)changeValue:(id)sender;


@end
