#import <UIKit/UIKit.h>
#import "KGORequestManager.h"

typedef enum _RequestPhase {
    RequestPhasePages = 100,
    RequestPhaseGroup,
    RequestPhasePage,
    RequestPhaseDetail,
}RequestPhase;


@interface ContentTableViewController : UIViewController <KGORequestDelegate,
UITableViewDataSource, UITableViewDelegate> {
	
    NSMutableDictionary * listOfFeeds;
    NSMutableArray * feedKeys;
    UIView * loadingView;

    ModuleTag * moduleTag;
    RequestPhase _currentPhase;
    RequestPhase _goPhase;
}

@property (nonatomic, retain) NSMutableDictionary *feedTitles;
@property (nonatomic, retain) NSMutableArray *feedKeys;
@property (nonatomic, retain) NSMutableArray *feedGroups;

@property (nonatomic, retain) ModuleTag * moduleTag;
@property (nonatomic, retain) UIView *loadingView;

@property (nonatomic, retain) NSString *feedKey;
@property (nonatomic, retain) NSString *feedGroup;

@property (nonatomic, retain) KGORequest *pagesRequest;
@property (nonatomic, retain) KGORequest *pageRequest;
@property (nonatomic, retain) KGORequest *groupRequest;

// if there are multiple feeds, show a list
@property (nonatomic, retain) UITableView *tableView;

// if there's only one feed, show it directly
@property (nonatomic, retain) UIWebView *contentView;
@property (nonatomic, retain) NSString *contentTitle;
@property (nonatomic, assign)  RequestPhase currentPhase;
@property (nonatomic, assign)  RequestPhase goPhase;

- (void)addLoadingView;
- (void)removeLoadingView;

- (void)requestPageContent;
- (void)requestGroupContent;
@end

