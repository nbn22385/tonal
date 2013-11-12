//
//  DetailViewController.h
//  plistTest3
//
//  Created by Jeremy Ayala on 9/18/13.
//  Copyright (c) 2013 nbn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController
{
}

@property (strong, nonatomic) id detailItem;

- (IBAction)startButton:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
