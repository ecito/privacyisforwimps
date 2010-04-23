//
//  LSTAGPSAppDelegate.m
//  LSTAGPS
//
//  Created by Louis St-Amour on 10-04-14.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "LSTAGPSAppDelegate.h"
#import "MainViewController.h"
#import "SettingsModel.h"

//SimpleGeo stuff
#define kSGOAuth_Key				@""  // SimpleGeo Auth Key
#define kSGOAuth_Secret			@""	 // SimpleGeo secret
#define kSGLayer						@"" // some layer you create in SimpleGeo
#define kUsernameKey				@"" // this is the unique key where your history will be saved


@implementation LSTAGPSAppDelegate


@synthesize window;
@synthesize mainViewController;
@synthesize locationManager;
@synthesize gpsEnabled;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	if ([[SettingsModel getSetting:kAccuracy] isEqualToString:kAccuracyGPS]) {
		[self startStandardUpdates];
	} else {
		[self startSignificantChangeUpdates];
	}
	
	return YES;
}

- (void)startSignificantChangeUpdates {
	[SettingsModel setSetting:kAccuracyCellTower forKey:kAccuracy];
	
	if (nil == locationManager) {
		locationManager = [[CLLocationManager alloc] init];
	} else {
		[locationManager stopUpdatingLocation];
	}
	
	locationManager.delegate = self;
	[locationManager startMonitoringSignificantLocationChanges];
}

- (void)startStandardUpdates {
	[SettingsModel setSetting:kAccuracyGPS forKey:kAccuracy];

	if (nil == locationManager) {
		locationManager = [[CLLocationManager alloc] init];
	} else {
		[locationManager stopMonitoringSignificantLocationChanges];
	}
	
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;

	[locationManager startUpdatingLocation];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
	
	[mainViewController.mapView setRegion:
		MKCoordinateRegionMakeWithDistance(
			 newLocation.coordinate,
			 newLocation.horizontalAccuracy,
			 newLocation.horizontalAccuracy
		) animated: YES];
	
	SGLocationService *service = [SGLocationService sharedLocationService];
	service.HTTPAuthorizer = [[SGOAuth alloc] initWithKey:kSGOAuth_Key secret:kSGOAuth_Secret];
	
// this properties dictionary gets saved as metadata for the record at simplegeo:
//	[properties] => stdClass Object
//	(
//		[layer] => layername
//		[type] => object
//		[accuracy] => cell
//	)	
	NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
															[SettingsModel getSetting:kAccuracy], kAccuracy,
															[SettingsModel getSetting:kStatus], kStatus,
															nil];
	
	[service updateRecord:kUsernameKey layer:kSGLayer coord:newLocation.coordinate properties:properties];
}


-(NSString *)uniqueKey {
	return [self dateKey];
}

- (NSString *)deviceIdentifierKey {
	return [[UIDevice currentDevice] uniqueIdentifier];
}

-(NSString *)dateKey {
	NSDate *today = [[NSDate alloc] init];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
	return [dateFormatter stringFromDate:today];
}
#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
