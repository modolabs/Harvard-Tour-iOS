#import "KGOTableViewController.h"
#import "KGODatePager.h"
#import "KGOScrollingTabstrip.h"
#import "CalendarDataManager.h"
#import "KGOSearchBar.h"
#import "KGOSearchDisplayController.h"
#import "OverScrollFooterView.h"

bool isOverOneMonth(NSTimeInterval interval);
bool isOverOneDay(NSTimeInterval interval);
bool isOverOneHour(NSTimeInterval interval);

typedef enum {
    KGOCalendarBrowseModeDay, // date pager selects days
    //KGOCalendarBrowseModeMonth,
    KGOCalendarBrowseModeLimit, // fixed number of items per page
    KGOCalendarBrowseModeCategories
} KGOCalendarBrowseMode;

@interface CalendarDayViewController : KGOTableViewController <KGODatePagerDelegate,
KGOScrollingTabstripSearchDelegate, CalendarDataManagerDelegate> {
    
    BOOL _loading;   // whether events are currently being loaded
    BOOL _appending; // whether new events should be appended or refreshed
    
    // at any given time the user can only view the contents of one group.
    // if there are multiple groups, the group being viewed will be pressed in the tab strip.
    NSInteger _currentGroupIndex;

    // currentCalendars is the list of calendars associated with the current group.
    // if there is only one group, the calendar titles appear in the tab strip.
    NSArray *_currentCalendars;
}

@property(nonatomic, retain) IBOutlet KGODatePager *datePager;
@property(nonatomic, retain) IBOutlet KGOScrollingTabstrip *tabstrip;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingView;
@property(nonatomic, retain) IBOutlet OverScrollFooterView *footerView;

@property(nonatomic, retain) ModuleTag *moduleTag;
@property(nonatomic, retain) CalendarDataManager *dataManager;

// if the tab strip is showing calendar titles, this is the currently selected calendar
@property(nonatomic, retain) KGOCalendar *currentCalendar;

// calendars are organized in groups.
// groupTitles is all the top level groups.
// if there are multiple groups, their titles are shown in the tab strip.
@property(nonatomic, retain) NSMutableArray *groupTitles;

// the table will either be a plain, possibly sectioned list of events
// or a grouped, unsectioned list of categories.
@property(nonatomic) BOOL suppressSectionTitles;
@property(nonatomic, retain) NSMutableArray *currentSections;
@property(nonatomic, retain) NSMutableDictionary *currentEventsBySection;

@property(nonatomic) KGOCalendarBrowseMode browseMode;
@property(nonatomic) BOOL eventsLoaded; // true if there are any events at all to display

// temporarily set by federated search
@property(nonatomic, retain) NSString *federatedSearchTerms;
@property(nonatomic, retain) NSArray *federatedSearchResults;

- (void)clearEvents;
- (void)clearCalendars;

// ui setup
- (void)setupTabstripButtons;
- (void)showLoading;
- (void)hideLoading;

@end
