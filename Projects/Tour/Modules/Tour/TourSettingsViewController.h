//
//  TourSettingsViewController.h
//  Tour
//
//  Created by Jim Kang on 6/7/11.
//  Copyright 2011 Modo Labs. All rights reserved.
//

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
