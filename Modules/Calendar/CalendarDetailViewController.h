#import <UIKit/UIKit.h>
#import "KGODetailPager.h"
#import <EventKitUI/EventKitUI.h>
#import "KGOCalendar.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "KGODetailPageHeaderView.h"
#import "CalendarDataManager.h"

@class KGOEventWrapper, CalendarDataManager, KGOShareButtonController;

@interface CalendarDetailViewController : UIViewController <KGODetailPageHeaderDelegate,
KGODetailPagerController, KGODetailPagerDelegate, CalendarDataManagerDelegate,
UITableViewDataSource, UITableViewDelegate,
MFMailComposeViewControllerDelegate, EKEventEditViewDelegate>
{
    KGOEventWrapper *_event;
    KGOShareButtonController *_shareController;
    NSArray *_detailSections;
}

@property (nonatomic, retain) KGOEventWrapper *event;

// these are paging sections for KGODetailPager
@property (nonatomic, retain) NSArray *sections;
@property (nonatomic, retain) NSDictionary *eventsBySection;

@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, retain) CalendarDataManager *dataManager;
@property (nonatomic, retain) id<KGOSearchResult> searchResult; 

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet KGODetailPageHeaderView *headerView;

- (NSArray *)sectionForBasicInfo;
- (NSArray *)sectionForAttendeeInfo;
- (NSArray *)sectionForContactInfo;
- (NSArray *)sectionForExtendedInfo;
- (NSArray *)sectionsForFields;

- (UIView *)viewForTableHeader;

@end

