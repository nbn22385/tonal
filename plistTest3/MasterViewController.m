//
//  MasterViewController.m
//  plistTest3
//
//  Created by Jeremy Ayala on 9/18/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import "MasterViewController.h"
#import "ExerciseViewController.h"
#import "FMDBDataAccess.h"

#define MUSCLE_SECTION 0
#define CARDIO_SECTION 1

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController
@synthesize myItems, musclePlistArray, cardioPlistArray; //muscleGroupsArray, cardioGroupsArray;
@synthesize muscleGroupDict, cardioGroupDict;
@synthesize categoryArray1,categoryArray2;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    self.navigationItem.title = @"Categories";

    // Load the property list   
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"];
    NSArray *rootPlistArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    [self populateCategories];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    
    switch (section) {
        case MUSCLE_SECTION:
            //numRows = musclePlistArray.count;
            numRows = categoryArray1.count;
            break;
        case CARDIO_SECTION:
            //numRows = cardioPlistArray.count;
            numRows = categoryArray2.count;
            break;
        default:
            break;
    }
    return numRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // Set the section name on the Categories screen
    NSString *sectionName;
    switch (section)
    {
        case MUSCLE_SECTION:
            sectionName = @"Strength Training";
            break;
        case CARDIO_SECTION:
            sectionName = @"Cardio";
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString *cellItem;

    switch ([indexPath section]) {
        case MUSCLE_SECTION:
            //muscleGroupDict = [musclePlistArray objectAtIndexedSubscript:indexPath.row];
            //muscleGroupDict = musclePlistArray [indexPath.row];//[musclePlistArray objectAtIndex:indexPath.row];
            //cellItem = [muscleGroupDict valueForKey:@"group"];
            cellItem = categoryArray1 [indexPath.row];
            break;
        case CARDIO_SECTION:
            //cardioGroupDict = [cardioPlistArray objectAtIndexedSubscript:indexPath.row];
            //cellItem = [cardioGroupDict valueForKey:@"group"];
            cellItem = categoryArray2 [indexPath.row];
            break;
        default:
            break;
    }
    //NSLog(@"Section %d, %@", [indexPath section], cellItem);
    cell.textLabel.text = cellItem;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showExercises"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        // Send muscleGroupDict to the next table view screen
        //NSDictionary *selectedItem;
        NSString *selectedGroup;
        
        switch ([indexPath section]) {
            case MUSCLE_SECTION:
                //muscleGroupDict = [musclePlistArray objectAtIndex:indexPath.row];
                //selectedItem = muscleGroupDict;//[muscleGroupDict valueForKey:@"exercises"];
                selectedGroup = [categoryArray1 objectAtIndex:indexPath.row];
                break;
            case CARDIO_SECTION:
                //cardioGroupDict = [cardioPlistArray objectAtIndex:indexPath.row];
                //selectedItem = cardioGroupDict;//[muscleGroupDict valueForKey:@"exercises"];
                selectedGroup = [categoryArray2 objectAtIndex:indexPath.row];
                break;
            default:
                break;
        }
        
        // pass the array of exercises
        //[segue destinationViewController].groupDict = selectedItem;
        
        // pass the string
        ExerciseViewController *exerciseViewController = [segue destinationViewController];
        //NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        
        exerciseViewController.groupName = selectedGroup;
        //detailViewController.trainingPlanId = tpId;
        
    }
    
    
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


}

#pragma mark - Database functions

-(void)populateCategories
{
    self.categories = [[NSMutableArray alloc] init];
    FMDBDataAccess *db = [[FMDBDataAccess alloc] init];
    
    self.categoryArray1 = [db getCategories:1];
    self.categoryArray2 = [db getCategories:2];
}

@end
