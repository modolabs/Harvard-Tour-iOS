#import <UIKit/UIKit.h>

@class TourOverviewController;
@class TourDataManager;

@interface TourHomeViewController : UIViewController {
    TourOverviewController *_tourOverviewController;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction) startTour:(id)sender;

@end
