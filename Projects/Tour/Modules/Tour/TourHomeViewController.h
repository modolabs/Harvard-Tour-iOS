#import <UIKit/UIKit.h>

@class TourOverviewController;
@class TourDataManager;

@interface TourHomeViewController : UIViewController {
    IBOutlet UIView *_welcomeView;
    TourOverviewController *_tourOverviewController;
}

@property (nonatomic, retain) IBOutlet UIView *welcomeView;

- (IBAction) startTour:(id)sender;

@end
