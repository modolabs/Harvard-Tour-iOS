#import <UIKit/UIKit.h>
#import "KGOTabbedControl.h"

@class TourStop;
@class KGOTabbedControl;
@interface TourStopDetailsViewController : UIViewController <UIWebViewDelegate, KGOTabbedControlDelegate, UIScrollViewDelegate> {
    NSMutableArray *moviePlayers;
    
}

@property (nonatomic, retain) IBOutlet KGOTabbedControl *tabControl;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *lenseContentView;

@property (nonatomic, retain) UIScrollView *slideShowScrollView;
@property (nonatomic, retain) NSArray *slides;
@property (nonatomic, retain) UIPageControl *slidesPageControl;
@property (nonatomic, assign) NSInteger displayedPageIndex;

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSString *html;

// placeholders used to construct lense item views from nib files
@property (nonatomic, retain) IBOutlet UIView *lenseItemPhotoView;
@property (nonatomic, retain) IBOutlet UIView *lenseItemVideoView;
@property (nonatomic, retain) IBOutlet UIView *lenseItemSlideShowView;

@property (nonatomic, retain) TourStop *tourStop;

@end
