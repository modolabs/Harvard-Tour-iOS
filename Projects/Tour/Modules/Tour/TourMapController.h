#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

typedef enum {
    MapInitialFocusModeAllStops,
    MapInitialFocusModeUpcomingStop,
} MapInitialFocusMode;

@class TourStop;
@class TourDataManager;

@interface TourMapController : UIViewController {
    NSInteger numberOfStops;
    TourStop *_selectedStop;
    UIImageView *_thumbnailView;
    BOOL approachPhotoZoomedIn;
    
    CGRect photoZoomedOutFrame;
    CGRect photoZoomedInFrame;
}

@property (nonatomic, retain) TourStop *selectedStop;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIControl *imageViewControl;
@property (nonatomic, retain) IBOutlet UIImageView *thumbnailView;
@property (nonatomic, retain) IBOutlet UIImageView *zoomInOutIcon;
@property (nonatomic, retain) IBOutlet UILabel *stopTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *stopCaptionLabel;
@property (nonatomic, retain) IBOutlet UIView *lenseIconsContainer;
@property (nonatomic, retain) IBOutlet UILabel *mapTipLabel;
@property (nonatomic) BOOL showMapTip;

@property (nonatomic, assign) MapInitialFocusMode mapInitialFocusMode;
@property (nonatomic, retain) TourStop *upcomingStop;

@property (nonatomic, retain) MKAnnotationView *selectedAnnotationView;

- (IBAction)photoTapped:(id)sender;
- (void)syncMapType;

@end
