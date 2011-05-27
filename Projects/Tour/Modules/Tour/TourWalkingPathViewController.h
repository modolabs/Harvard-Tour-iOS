#import <UIKit/UIKit.h>
#import "TourStop.h"

typedef enum {
    TourStopModeApproach,
    TourStopModeLenses
} TourStopMode;

@interface TourWalkingPathViewController : UIViewController {
    
}

@property (nonatomic) TourStopMode tourStopMode;
@property (nonatomic, retain) TourStop *currentStop;
@property (nonatomic, retain) TourStop *initialStop;
@property (nonatomic, retain) IBOutlet UIBarItem *previousBarItem;
@property (nonatomic, retain) IBOutlet UIBarItem *nextBarItem;
@property (nonatomic, retain) IBOutlet UIButton *titleButton;  //not used as a button


- (IBAction)previous;
- (IBAction)next;

@end
