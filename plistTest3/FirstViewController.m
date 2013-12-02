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
#import "HistoryViewController.h"

@interface FirstViewController ()
- (void)configureView;
@end

@implementation FirstViewController
@synthesize nwTpButton, continueTpButton, closeTpButton, infoLabel;
@synthesize currentTpId;
@synthesize myTabBar;

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
    currentTpId = [self getCurrentTrainingPlanId];
    NSString* tpStartDate;
    
    if (currentTpId == 0) {
        // No open training plans
        [nwTpButton setEnabled:YES];
        [continueTpButton setEnabled:NO];
        [closeTpButton setHidden:YES];
        [infoLabel setText:@""];
    }
    else {
        // Found an open training plan
        [nwTpButton setEnabled:NO];
        [continueTpButton setEnabled:YES];
        [closeTpButton setHidden:NO];
        [closeTpButton setEnabled:YES];
        tpStartDate = [self getCurrentTrainingPlanStartDate];
        [infoLabel setText:[@"Started on: " stringByAppendingString:tpStartDate]];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    myTabBar.delegate = self;
    [myTabBar setSelectedItem:[myTabBar.items objectAtIndex:0]];

}

-(void) viewDidAppear:(BOOL)animated
{
    // Select the home tab
    [myTabBar setSelectedItem:[myTabBar.items objectAtIndex:0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"FirstSegue"]){
        //MasterViewController *masterViewController = [segue destinationViewController];

        //masterViewController.trainingPlanId = ?;
        
    }
    
    if([[segue identifier] isEqualToString:@"History"]){
        // Does not get hit
        NSLog(@"History segue triggered");
        HistoryViewController *historyViewController = [[HistoryViewController alloc] init];
        historyViewController = [segue destinationViewController];
    }

}

#pragma mark - Tab bar methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSLog(@"didSelectItem: %d", item.tag);
    //HistoryViewController *historyViewController = [[HistoryViewController alloc] init];

    switch (item.tag) {
        case 0:
            // Home
            break;
        case 1:
            // History
            [self performSegueWithIdentifier:@"History" sender:nil];
            break;
        case 2:
            // Voice
            [self performSegueWithIdentifier:@"Voice" sender:nil];
            if (currentTpId == 0)
            {
              NSLog(@"NOPE");
              // Create a new training plan record
              [self createNewTrainingPlan];
              [self configureView];
            }
            else
            {
              NSLog(@"YUP");
            }
            break;
        case 3:
            // Settings
            [self performSegueWithIdentifier:@"Settings" sender:nil];
            break;
        default:
            break;
    }
}

#pragma mark - Button click events

- (IBAction)closeTrainingPlanButtonClick:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Please Confirm"
                                                   message:@"Close Training Plan?"
                                                  delegate:self
                                         cancelButtonTitle:@"No"
                                         otherButtonTitles:@"Yes", nil];
    [alert show];
    
}

- (IBAction)newTrainingPlanButtonClick:(id)sender {
    // Create a new training plan record
    [self createNewTrainingPlan];
    [self configureView];
    
}

- (IBAction)continueTrainingPlanButtonClick:(id)sender {
    // Continue with the open training plan
    //NSInteger curentId = [self getCurrentTrainingPlanId];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // No button
    }
    if (buttonIndex == 1)
    {
        // Yes button
        [self closeCurrentTrainingPlan];
        [self configureView];
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

-(BOOL)closeCurrentTrainingPlan
{
    BOOL result;
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    result = [db closeCurrentTrainingPlan];
    NSLog(@"closeCurrentTrainingPlan result: %d", result);
    return result;
}

-(NSInteger)createNewTrainingPlan
{
    NSInteger id;
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    
    id = [db createNewTrainingPlan];
    return id;
}

@end
