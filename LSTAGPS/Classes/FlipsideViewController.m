//
//  FlipsideViewController.m
//  LSTAGPS
//
//  Created by Louis St-Amour on 10-04-14.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FlipsideViewController.h"
#import "SettingsModel.h"
#import "LSTAGPSAppDelegate.h"

@implementation FlipsideViewController

@synthesize delegate;
@synthesize textField;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];   
}

- (IBAction)done:(id)sender {
	[self.delegate flipsideViewControllerDidFinish:self];	
}

- (IBAction)doneEditingStatus:(id)sender {
	UITextField *statusField = sender;
	[SettingsModel setSetting:statusField.text forKey:kStatus];
	[statusField resignFirstResponder];
}

- (IBAction)selectGPS:(id)sender {
	
	LSTAGPSAppDelegate *appDelegate = (LSTAGPSAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate startStandardUpdates];
	
	[self.delegate flipsideViewControllerDidFinish:self];	
}

- (IBAction)selectCellTower:(id)sender {

	LSTAGPSAppDelegate *appDelegate = (LSTAGPSAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate startSignificantChangeUpdates];
	
	[self.delegate flipsideViewControllerDidFinish:self];	
}

- (void)dealloc {
	[super dealloc];
}


@end
