#import <UIKit/UIKit.h>
#import "KGOScrollingTabstrip.h"
#import "AthleticsTableViewCell.h"
#import "KGOSearchBar.h"
#import "AthleticsDataController.h"
#import "KGOSearchDisplayController.h"
@interface AthleticsListController : KGOTableViewController <KGOSearchBarDelegate,AthleticsDataDelegate,KGOScrollingTabstripDelegate,KGOScrollingTabstripSearchDelegate> {
    
    IBOutlet UILabel *_loadingLabel;
    IBOutlet UILabel *_lastUpdateLabel;
    IBOutlet UIProgressView *_progressView;
    IBOutlet UITableView *_storyTable;
    IBOutlet UIView *_activityView;
    IBOutlet KGOScrollingTabstrip *_navTabs;
    IBOutlet AthleticsTableViewCell *_athletcisCell;
    
    NSString *activeCategoryId;
    
    NSInteger _topNewsTabIndex;
    NSInteger _menTabIndex;
    NSInteger _womenTabIndex;
    NSInteger _mySportsTabIndex;
    
}

@property (nonatomic, retain) AthleticsDataController *dataManager;
@property (nonatomic, retain) NSArray *federatedSearchResults;
@property (nonatomic, retain) NSString *federatedSearchTerms;
@property (nonatomic, retain) NSArray *stories;
@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) NSString *activeCategoryId;

- (void)setStatusText:(NSString *)text;
@end
