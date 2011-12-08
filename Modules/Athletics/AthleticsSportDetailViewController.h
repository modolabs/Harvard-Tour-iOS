#import <UIKit/UIKit.h>
#import "KGODetailPager.h"

@class AthleticsStory;
@class KGOShareButtonController;
@class AthleticsDataController;
//@class StoryListViewController;

@protocol AthleticsControllerDelegate <NSObject>

- (BOOL)canSelectPreviousStory;
- (BOOL)canSelectNextStory;
- (AthleticsStory *)selectPreviousStory;
- (AthleticsStory *)selectNextStory;

@end

@interface AthleticsSportDetailViewController : UIViewController <UIWebViewDelegate, KGODetailPagerController, KGODetailPagerDelegate> {
	//StoryListViewController *athleticsController;
    id<AthleticsControllerDelegate> athleticsController;
	
	KGODetailPager *storyPager;
    
    UIWebView *storyView;
	AthleticsStory *story;
    NSArray *stories;
    
	KGOShareButtonController *shareController;
    NSIndexPath *initialIndexPath;
    
    BOOL multiplePages;
}

@property (nonatomic, retain) id<AthleticsControllerDelegate> athleticsController;
@property (nonatomic, retain) AthleticsDataController *dataManager;

@property (nonatomic, retain) UIWebView *storyView;
@property (nonatomic, retain) NSArray *stories;
@property (nonatomic, retain) AthleticsStory *story; // use if you only want to present one story
@property (nonatomic, retain) AthleticsStory *category; // use only if you want the news home button to back to specific category
@property BOOL multiplePages;

- (void) setInitialIndexPath:(NSIndexPath *)initialIndexPath;

@end
