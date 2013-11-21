//
//  SettingsViewController.m
//  tonal
//
//  Created by Jeremy Ayala on 11/18/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize defaults, unitString;

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
    self.navigationItem.title = @"Settings";
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    // set the segmented control to the correct value
    segmentedControl.selectedSegmentIndex = [defaults integerForKey:@"unitSelection"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)changeValue:(id)sender {
    
    NSString *value = [NSString alloc];
    
    switch ([sender selectedSegmentIndex]) {
        case 0:
            value = @"US";
            break;
        case 1:
            value = @"Metric";
            break;
        default:
            break;
    }
    
    NSInteger i = [sender selectedSegmentIndex];
    [defaults setInteger:i forKey:@"unitSelection"];
    [defaults setObject:value forKey:@"unitString"];
    [defaults synchronize];
    
    NSLog(@"Saved units as: %@", value);

}
@end
