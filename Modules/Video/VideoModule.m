#import "VideoModule.h"
#import "VideoListViewController.h"
#import "VideoDetailViewController.h"
#import "VideoWebViewController.h"

NSString * const KGODataModelNameVideo = @"Video";

@implementation VideoModule

@synthesize dataManager;
@synthesize searchSection;

- (void)willLaunch
{
    [super willLaunch];
    if (!self.dataManager) {
        self.dataManager = [[[VideoDataManager alloc] init] autorelease];
        self.dataManager.module = self;
    }
}

- (NSArray *)registeredPageNames {
    return [NSArray arrayWithObjects:
            LocalPathPageNameHome,
            LocalPathPageNameDetail,
            LocalPathPageNameSearch,
            LocalPathPageNameWebViewDetail,
            nil];
}

- (UIViewController *)modulePage:(NSString *)pageName params:(NSDictionary *)params {
    UIViewController *vc = nil;
    if ([pageName isEqualToString:LocalPathPageNameHome]) {
        VideoListViewController *listVC = [[[VideoListViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        listVC.dataManager = self.dataManager;
        vc = listVC;
    
    } else if ([pageName isEqualToString:LocalPathPageNameSearch]) {
        VideoListViewController *listVC = [[[VideoListViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        listVC.dataManager = self.dataManager;
        
        NSString *searchText = [params objectForKey:@"q"];
        if (searchText) {
            listVC.federatedSearchTerms = searchText;
        }
        
        NSArray *searchResults = [params objectForKey:@"searchResults"];
        if (searchResults) {
            listVC.federatedSearchResults = searchResults;
        }
        
        vc = listVC;

    } else if ([pageName isEqualToString:LocalPathPageNameDetail]) {
        Video *video = [params objectForKey:@"video"];
        NSString *section = [params objectForKey:@"section"];
        if (video) {
            VideoDetailViewController *detailVC = [[[VideoDetailViewController alloc] initWithVideo:video
                                                                                         andSection:section] autorelease];
            detailVC.dataManager = self.dataManager;
            vc = detailVC;
        }

    } else if ([pageName isEqualToString:LocalPathPageNameWebViewDetail]) {
        Video *video = [params objectForKey:@"video"];
        VideoWebViewController *webVC = [[[VideoWebViewController alloc]
                                          initWithURL:[NSURL URLWithString:video.url]] autorelease];
        webVC.navigationItem.title = video.title; 
        vc = webVC;
    }
    return vc;
}

#pragma mark Data

- (NSArray *)objectModelNames {
    return [NSArray arrayWithObject:KGODataModelNameVideo];
}


#pragma mark Search

- (BOOL)supportsFederatedSearch {
    return YES;
}

- (void)dataManager:(VideoDataManager *)manager didReceiveVideos:(NSArray *)videos
{
    [self.searchDelegate receivedSearchResults:videos forSource:self.tag];
}

- (void)performSearchWithText:(NSString *)searchText 
                       params:(NSDictionary *)params 
                     delegate:(id<KGOSearchResultsHolder>)delegate {
    
    self.searchDelegate = delegate;
    self.dataManager.delegate = self;
    [self.dataManager searchSection:self.searchSection forQuery:searchText];
}

- (void)dealloc {
    dataManager.delegate = nil;
    [dataManager release];
    [super dealloc];
}

@end
