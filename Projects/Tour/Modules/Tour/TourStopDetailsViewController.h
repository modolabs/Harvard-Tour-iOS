#import <UIKit/UIKit.h>

@class TourStop;
@class KGOTabbedControl;
@interface TourStopDetailsViewController : UIViewController {
    
}

@property (nonatomic, retain) IBOutlet KGOTabbedControl *tabControl;
@property (nonatomic, retain) IBOutlet UIScrollView *scollView;
@property (nonatomic, retain) IBOutlet UIView *lenseContentView;

// placeholders used to construct lense item views from nib files
@property (nonatomic, retain) IBOutlet UIView *lenseItemPhotoView;

@property (nonatomic, retain) TourStop *tourStop;
@end
