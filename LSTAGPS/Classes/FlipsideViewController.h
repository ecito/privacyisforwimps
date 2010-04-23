//
//  FlipsideViewController.h
//  LSTAGPS
//
//  Created by Louis St-Amour on 10-04-14.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : UIViewController {
	id <FlipsideViewControllerDelegate> delegate;
	IBOutlet UITextField *textField;
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextField *textField;

- (IBAction)done:(id)sender;
- (IBAction)doneEditingStatus:(id)sender;
- (IBAction)selectGPS:(id)sender;
- (IBAction)selectCellTower:(id)sender;
@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

