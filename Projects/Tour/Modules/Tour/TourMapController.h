
/****************************************************************
 *
 *  Copyright 2011 The President and Fellows of Harvard College
 *  Copyright 2011 Modo Labs Inc.
 *
 *****************************************************************/

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BeamAnnotation.h"

typedef enum {
    MapInitialFocusModeAllStops,
    MapInitialFocusModeUpcomingStop,
} MapInitialFocusMode;

@class TourStop;
@class TourDataManager;

@protocol TourMapControllerDelegate

- (void)mapController:(TourMapController *)controller 
    didSelectTourStop:(TourStop *)stop;

@end

@interface TourMapController : UIViewController <CLLocationManagerDelegate> {
    NSInteger numberOfStops;
    TourStop *_selectedStop;
    UIImageView *_thumbnailView;
    BOOL approachPhotoZoomedIn;
    
    CGRect photoZoomedOutFrame;
    CGRect photoZoomedInFrame;
    BOOL receivedUserLocation;
    BOOL regionSetFromUserLocation;
}

@property (nonatomic, retain) TourStop *selectedStop;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIControl *imageViewControl;
@property (nonatomic, retain) IBOutlet UIImageView *thumbnailView;
@property (nonatomic, retain) IBOutlet UIImageView *zoomInOutIcon;
@property (nonatomic, retain) IBOutlet UILabel *stopTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *stopCaptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *mapTipLabel;
@property (nonatomic) BOOL showMapTip;

@property (nonatomic, assign) MapInitialFocusMode mapInitialFocusMode;
@property (nonatomic, retain) TourStop *upcomingStop;

@property (nonatomic, retain) MKAnnotationView *selectedAnnotationView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) MKAnnotationView *directionBeamAnnotationView;
@property (nonatomic, retain) BeamAnnotation *beamAnnotation;
@property (assign) id<TourMapControllerDelegate> delegate;

- (IBAction)photoTapped:(id)sender;
- (void)syncMapType;

@end
