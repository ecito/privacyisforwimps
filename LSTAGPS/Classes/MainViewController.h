//
//  MainViewController.h
//  LSTAGPS
//
//  Created by Louis St-Amour on 10-04-14.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FlipsideViewController.h"
#import <MapKit/MapKit.h>

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate> {
	MKMapView *mapView;
	IBOutlet UILabel *accuracyLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *accuracyLabel;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (IBAction)showInfo:(id)sender;
- (void)updateAccuracyLabel;

@end
