#import <UIKit/UIKit.h>
#import "KGODetailPager.h"
#import "KGOCalendar.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "KGODetailPageHeaderView.h"
#import "CalendarDataManager.h"

@class KGOEvent, CalendarDataManager, KGOShareButtonController;

@interface CalendarDetailViewController : UIViewController <KGODetailPageHeaderDelegate,
KGODetailPagerController, KGODetailPagerDelegate, CalendarDataManagerDelegate,
UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate,
MFMailComposeViewControllerDelegate>
{
    KGOEvent *_event;
    KGOShareButtonController *_shareController;
    NSArray *_detailSections;

    // for description section
    NSInteger _descriptionSectionId;
    CGFloat _descriptionHeight;
    UIWebView *_descriptionView;
}

@property (nonatomic, retain) KGOEvent *event;

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
- (NSString *)dateDescriptionForEvent:(KGOEvent *)event;

@end

