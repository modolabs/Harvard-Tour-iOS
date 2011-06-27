#import <UIKit/UIKit.h>
#import "HTMLTemplateBasedViewController.h"

@class TourOverviewController;
@class TourDataManager;

@interface TourHomeViewController : HTMLTemplateBasedViewController 
<UIWebViewDelegate> {
    TourOverviewController *_tourOverviewController;
    
    NSString * welcomeText;
    NSString * welcomeDisclaimerText;
    
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction) startTour:(id)sender;


@end
