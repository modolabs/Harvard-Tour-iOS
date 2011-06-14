#import <UIKit/UIKit.h>
#import "TourStop.h"
#import "TourOverviewController.h"

typedef enum {
    TourStopModeApproach,
    TourStopModeLenses
} TourStopMode;

@class TourMapController;
@class TourStopDetailsViewController;
@class TourFinishViewController;

@interface TourWalkingPathViewController : UIViewController 
<TourOverviewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate> {
    TourStop *_initialStop;
    TourStop *_currentStop;    
}

@property (nonatomic) TourStopMode tourStopMode;
@property (nonatomic, retain) TourStop *currentStop;
@property (nonatomic, retain) TourStop *initialStop;
@property (nonatomic, retain) TourStop *actionSheetStop;
@property (nonatomic, retain) IBOutlet UIBarItem *previousBarItem;
@property (nonatomic, retain) IBOutlet UIBarItem *nextBarItem;
@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) UIView *currentContent;

@property (nonatomic, retain) TourMapController *tourMapController;
@property (nonatomic, retain) TourStopDetailsViewController *tourStopDetailsController;
@property (nonatomic, retain) TourFinishViewController *tourFinishController;

- (IBAction)previous;
- (IBAction)next;
- (IBAction)tourOverview;
- (IBAction)cameraButtonTapped:(id)sender;

@end
