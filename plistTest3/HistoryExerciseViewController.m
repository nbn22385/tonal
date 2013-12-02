//
//  HistoryExerciseViewController.m
//  tonal
//
//  Created by JEREMY AYALA on 12/1/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import "HistoryExerciseViewController.h"
#import "FMDBDataAccess.h"
#import "HistorySetsViewController.h"
#import "ExerciseRecord.h"

@interface HistoryExerciseViewController ()

@end

@implementation HistoryExerciseViewController

@synthesize items;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Exercises";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
  // fill the items array
  items = [self getExercisesForTrainingPlan:self.thisTpId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  // Display the exercises in the exerciseArray
  ExerciseRecord *er = [[ExerciseRecord alloc]init];
  er = [items objectAtIndex:indexPath.row];
  
    cell.textLabel.text = er.exerciseName;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"HistorySets"]) {
    
      NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
      
      NSInteger *selectedErId;
      
      ExerciseRecord *er = [[ExerciseRecord alloc] init];
      er = [items objectAtIndex:indexPath.row];
      
      HistorySetsViewController *hsvc = [segue destinationViewController];
      
      hsvc.thisErId = er.erId;
      NSLog(@"Passing exercise record id %d", er.erId);
    
  }
}


-(NSArray*)getExercisesForTrainingPlan:(NSInteger)withId
{
  FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
  NSArray* result = [NSArray array];
  
  result = [db getExercisesForTrainingPlan:self.thisTpId];
  
  
  return result;
}


@end
