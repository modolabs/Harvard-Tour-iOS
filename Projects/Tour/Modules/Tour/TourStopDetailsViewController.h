#import <UIKit/UIKit.h>

@class TourStop;
@class KGOTabbedControl;
@interface TourStopDetailsViewController : UIViewController <UIWebViewDelegate> {
    
}

@property (nonatomic, retain) IBOutlet KGOTabbedControl *tabControl;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *lenseContentView;

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSString *html;

// placeholders used to construct lense item views from nib files
@property (nonatomic, retain) IBOutlet UIView *lenseItemPhotoView;

@property (nonatomic, retain) TourStop *tourStop;
@end
