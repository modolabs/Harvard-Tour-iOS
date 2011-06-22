#import <UIKit/UIKit.h>

@class TourOverviewController;
@class TourDataManager;

@interface TourHomeViewController : UIViewController <UIWebViewDelegate>{
    TourOverviewController *_tourOverviewController;
    
    NSString * welcomeText;
    NSString * welcomeDisclaimerText;
    
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (IBAction) startTour:(id)sender;

- (void) setupWebViewLayout;

@end
