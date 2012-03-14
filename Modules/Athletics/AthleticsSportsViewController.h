#import <UIKit/UIKit.h>
#import "AthleticsTableViewCell.h"
#import "KGOSearchBar.h"
#import "KGOTableViewController.h"
#import "AthleticsDataController.h"
#import "KGOSearchDisplayController.h"

@interface AthleticsSportsViewController : KGOTableViewController <KGOSearchBarDelegate,AthleticsDataDelegate> {
    IBOutlet UILabel *_loadingLabel;
    IBOutlet UILabel *_lastUpdateLabel;
    IBOutlet UIProgressView *_progressView;
    IBOutlet UITableView *_storyTable;
    IBOutlet UIView *_activityView;
    IBOutlet UILabel *_titleLabel;
    IBOutlet UIButton *_bookmarkButton;
    IBOutlet AthleticsTableViewCell *_athletcisCell;
    
    NSString *activeCategoryId;
    NSInteger actieveMenuCategoryIdx;
    BOOL showingBookmarks;
    BOOL showingMenuCategories;
}

@property (nonatomic, retain) AthleticsDataController *dataManager;
@property (nonatomic, retain) NSArray *federatedSearchResults;
@property (nonatomic, retain) NSString *federatedSearchTerms;
@property (nonatomic, retain) NSArray *stories;
@property (nonatomic, retain) NSArray *schedules;
@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) NSString *activeCategoryId;
@property (nonatomic, assign)  NSInteger actieveMenuCategoryIdx;

- (IBAction)bookmarkButtonPressed:(id)sender;

- (void)setStatusText:(NSString *)text;
- (NSString *)titleForMenuCategory;
- (void)setupBookmarkStatus;

@end