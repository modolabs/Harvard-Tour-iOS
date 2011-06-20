#import <UIKit/UIKit.h>


@interface TourWelcomeBackViewController : UIViewController {
    
}

- (IBAction)startOver;
- (IBAction)resumeTour;

@property(nonatomic, retain) IBOutlet UIWebView * webView;

- (void) setupWebViewLayout;

@end
