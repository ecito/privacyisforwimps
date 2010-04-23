//
//  LSTAGPSAppDelegate.h
//  LSTAGPS
//
//  Created by Louis St-Amour on 10-04-14.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "SGClient.h"

#define kAccuracy							@"accuracy"
#define kAccuracyGPS					@"gps"
#define kAccuracyCellTower		@"cell"
#define kStatus								@"status"


@class MainViewController;

@interface LSTAGPSAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> {
	UIWindow *window;
	MainViewController *mainViewController;
	CLLocationManager *locationManager;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;
@property (nonatomic, retain) CLLocationManager *locationManager;

- (void)startSignificantChangeUpdates;
- (void)startStandardUpdates;
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation;

@end

