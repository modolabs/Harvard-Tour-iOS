
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/


#import <UIKit/UIKit.h>

@protocol TourSettingsControllerDelegate

- (void)endTour;

@end

@interface TourSettingsViewController : UIViewController {

    IBOutlet UISegmentedControl *segmentedControl;
}

@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (assign) id<TourSettingsControllerDelegate> delegate;

- (IBAction)endTourButtonTapped:(id)sender;

@end
