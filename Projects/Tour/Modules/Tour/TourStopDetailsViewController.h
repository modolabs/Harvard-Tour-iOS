#import <UIKit/UIKit.h>

@class TourStop;
@class KGOTabbedControl;
@interface TourStopDetailsViewController : UIViewController {
    
}

@property (nonatomic, retain) IBOutlet KGOTabbedControl *tabControl;
@property (nonatomic, retain) TourStop *tourStop;
@end
