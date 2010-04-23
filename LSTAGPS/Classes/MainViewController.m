//
//  MainViewController.m
//  LSTAGPS
//
//  Created by Louis St-Amour on 10-04-14.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MainViewController.h"
#import "SettingsModel.h"
#import "LSTAGPSAppDelegate.h"

@implementation MainViewController

@synthesize mapView;
@synthesize accuracyLabel;

- (void)viewDidLoad {
	[super viewDidLoad];
	[self updateAccuracyLabel];
	
	
}

- (void)updateAccuracyLabel {	
	accuracyLabel.text = [SettingsModel getSetting:kAccuracy];

}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self updateAccuracyLabel];
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)showInfo:(id)sender {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (void)dealloc {
	[super dealloc];
}


@end
