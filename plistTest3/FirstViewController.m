//
//  FirstViewController.m
//  plistTest3
//
//  Created by Jeremy Ayala on 9/18/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import "FirstViewController.h"
#import "MasterViewController.h"
#import "FMDBDataAccess.h"

@interface FirstViewController ()
- (void)configureView;
@end

@implementation FirstViewController
@synthesize nwButton, continueButton, infoLabel;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
    
    // If a training plan is in progress, disable New button, enable Continue button
    NSInteger currTpId = [self getCurrentTrainingPlanId];
    NSString* tpStartDate;
    
    if (currTpId == 0) {
        // No open training plans
        [nwButton setEnabled:YES];
        [continueButton setEnabled:NO];
        [infoLabel setText:@""];
    }
    else {
        // Found an open training plan
        [nwButton setEnabled:NO];
        [continueButton setEnabled:YES];
        tpStartDate = [self getCurrentTrainingPlanStartDate];
        [infoLabel setText:[@"Started on: " stringByAppendingString:tpStartDate]];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startButton:(id)sender {
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"FirstSegue"]){
        MasterViewController *masterViewController = [segue destinationViewController];

        //masterViewController.trainingPlanId = ?;
        
    }
}

#pragma mark - Database functions

-(NSInteger)getCurrentTrainingPlanId
{
    NSInteger id;
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    
    id = [db getCurrentTrainingPlanId];
    return id;
}

-(NSString*)getCurrentTrainingPlanStartDate
{
    NSDate* startDate;
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    
    startDate = [db getCurrentTrainingPlanStartDate];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
    return [dateFormat stringFromDate:startDate];
}

@end
