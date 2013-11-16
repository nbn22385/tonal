//
//  DetailViewController.h
//  plistTest3
//
//  Created by Jeremy Ayala on 9/18/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController<UIAlertViewDelegate>
{
}

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) IBOutlet UIButton *nwTpButton;
@property (strong, nonatomic) IBOutlet UIButton *continueTpButton;
@property (strong, nonatomic) IBOutlet UIButton *closeTpButton;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;

// Tab bar stuff
@property (strong, nonatomic) IBOutlet UITabBar *myTabBar;
@property (strong, nonatomic) IBOutlet UITabBarItem *settingsTabBarItem;

// IBActions
- (IBAction)closeTrainingPlanButtonClick:(id)sender;
- (IBAction)newTrainingPlanButtonClick:(id)sender;
- (IBAction)continueTrainingPlanButtonClick:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property NSInteger currentTpId;

@end
