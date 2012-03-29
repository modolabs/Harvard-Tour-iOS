#import <Foundation/Foundation.h>
#import "KGOTableViewController.h"
#import "VideoDataManager.h"
#import "KGOScrollingTabstrip.h"
#import "KGOSearchBar.h"
#import "KGOSearchDisplayController.h"
#import "Video.h"

@class ThumbnailTableViewCell;

@interface VideoListViewController : KGOTableViewController <
VideoDataDelegate,
KGOScrollingTabstripSearchDelegate> {

    BOOL showingBookmarks;
    ThumbnailTableViewCell *_cell;
    IBOutlet UITableView *_videoTable;
    IBOutlet KGOScrollingTabstrip *_navScrollView;
}

@property (nonatomic, retain) VideoDataManager *dataManager;
@property (nonatomic, retain) NSArray *videos;
// Array of NSDictionaries containing title and value keys.
@property (nonatomic, retain) NSArray *videoSections;
@property (assign) NSUInteger activeSectionIndex;

@property (nonatomic, retain) KGOSearchBar *theSearchBar;

@property (nonatomic, retain) NSArray *federatedSearchResults;
@property (nonatomic, retain) NSString *federatedSearchTerms;

@property (nonatomic, retain) IBOutlet ThumbnailTableViewCell *cell;

@end
