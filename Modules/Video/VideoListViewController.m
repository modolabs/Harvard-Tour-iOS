#import "VideoListViewController.h"
#import "Constants.h"
#import "VideoDetailViewController.h"
#import "CoreDataManager.h"
#import "VideoModule.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "KGOTheme.h"
#import "ThumbnailTableViewCell.h"
#import "VideoModule.h"

static const NSInteger kVideoListCellThumbnailTag = 0x78;

#pragma mark Private methods

@interface VideoListViewController (Private)

- (void)requestVideosForActiveSection;

@end


@implementation VideoListViewController

@synthesize dataManager;
@synthesize videos = _videos;
@synthesize videoSections;
@synthesize activeSectionIndex;
@synthesize theSearchBar;
@synthesize cell = _cell;

@synthesize federatedSearchTerms, federatedSearchResults;

#pragma mark NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.activeSectionIndex = 0;
    }
    return self;
}

- (void)dealloc {
    self.dataManager.delegate = nil;
    [theSearchBar release];
    [videoSections release];
    [_videos release];
    [dataManager release];

    self.federatedSearchTerms = nil;
    self.federatedSearchResults = nil;
    
    [super dealloc];
}

#pragma mark VideoDataDelegate
- (void)setupNavScrollButtons {
    BOOL bookmarkSelected = NO;
    if ([_navScrollView numberOfButtons] > 0 && [_navScrollView indexOfSelectedButton] == NSNotFound) {
        bookmarkSelected = YES;
    }
    
    [_navScrollView removeAllRegularButtons];
    
    for (NSDictionary *sectionInfo in self.videoSections) {
        [_navScrollView addButtonWithTitle:[sectionInfo objectForKey:@"title"]];
    }
    
    if ([self.dataManager bookmarkedVideos].count) {
        [_navScrollView setShowsBookmarkButton:YES]; 
    } else {
        [_navScrollView setShowsBookmarkButton:NO]; 
    }
    
    if (bookmarkSelected && [self.dataManager bookmarkedVideos].count > 0) {
        [_navScrollView selectButtonAtIndex:[_navScrollView bookmarkButtonIndex]];
    } else {
        [_navScrollView selectButtonAtIndex:self.activeSectionIndex];
    }
    
    [_navScrollView setNeedsLayout];
}


- (void)requestVideosForActiveSection { 
    if (self.videoSections.count > self.activeSectionIndex) {
        NSString *section = [[self.videoSections objectAtIndex:self.activeSectionIndex] objectForKey:@"value"];
        self.dataManager.delegate = self;
        [self.dataManager requestVideosForSection:section];
    }
}

- (void)dataManager:(VideoDataManager *)manager didReceiveSections:(NSArray *)sections
{
    self.videoSections = (NSArray *)sections;
    [self setupNavScrollButtons]; // update button pressed states
    [self requestVideosForActiveSection];
}

- (void)dataManager:(VideoDataManager *)manager didReceiveVideos:(NSArray *)videos
{
    self.videos = videos;
    [_videoTable reloadData];
}

- (void)setupNavScrollView {
    _navScrollView.showsSearchButton = YES;
    _navScrollView.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavScrollView];
    [self addTableView:_videoTable];
    _videoTable.rowHeight = 90.0f;
    self.dataManager.delegate = self;
    [self.dataManager requestSections];
    self.navigationItem.title = [[KGO_SHARED_APP_DELEGATE() moduleForTag:self.dataManager.module.tag] shortName];
    
    if (self.federatedSearchTerms || self.federatedSearchResults) {
        [_navScrollView showSearchBarAnimated:NO];
        [_navScrollView.searchController setActive:NO animated:NO];
        _navScrollView.searchController.searchBar.text = self.federatedSearchTerms;
        
        if (self.federatedSearchResults) {
            [_navScrollView.searchController setSearchResults:self.federatedSearchResults
                                                 forModuleTag:self.dataManager.module.tag];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataManager.delegate = self;
    [self setupNavScrollButtons];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Save whatever thumbnail data we've downloaded.
    [[CoreDataManager sharedManager] saveData];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.videos.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    ThumbnailTableViewCell *cell = (ThumbnailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:
                                                              [ThumbnailTableViewCell commonReuseIdentifier]];
    if (!cell) {
        [[NSBundle mainBundle] loadNibNamed:@"ThumbnailTableViewCell" owner:self options:nil];
        cell = _cell;
        cell.thumbnailSize = CGSizeMake(120, tableView.rowHeight);
    }

    Video *video = [self.videos objectAtIndex:indexPath.row];
    cell.thumbView.delegate = video;
    video.thumbView = cell.thumbView;

    cell.titleLabel.text = video.title;
    cell.subtitleLabel.text = video.subtitle;
    
    cell.thumbView.imageURL = video.thumbnailURLString;
    cell.thumbView.imageData = video.thumbnailImageData;
    
    [cell.thumbView loadImage];
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.videos.count > indexPath.row) {
        NSString *section = [[self.videoSections objectAtIndex:self.activeSectionIndex] objectForKey:@"value"];
        Video *video = [self.videos objectAtIndex:indexPath.row];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                section, @"section", video, @"video", nil];
        [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameDetail
                               forModuleTag:self.dataManager.module.tag
                                     params:params];
    }
}

#pragma mark KGOScrollingTabstripDelegate

- (void)tabstrip:(KGOScrollingTabstrip *)tabstrip clickedButtonAtIndex:(NSUInteger)index {
    self.activeSectionIndex = index;
    [self requestVideosForActiveSection];
    if (self.videoSections.count > self.activeSectionIndex) {
        VideoModule *module = (VideoModule *)[KGO_SHARED_APP_DELEGATE() moduleForTag:self.dataManager.module.tag];
        module.searchSection = [[self.videoSections objectAtIndex:self.activeSectionIndex] objectForKey:@"value"];
    }
}

- (void)tabstripBookmarkButtonPressed:(id)sender {
    showingBookmarks = YES;
    self.videos = [self.dataManager bookmarkedVideos];
    [_videoTable reloadData];
}

- (BOOL)tabstripShouldShowSearchDisplayController:(KGOScrollingTabstrip *)tabstrip
{
    return YES;
}

- (UIViewController *)viewControllerForTabstrip:(KGOScrollingTabstrip *)tabstrip
{
    return self;
}

#pragma mark KGOSearchDisplayDelegate
- (BOOL)searchControllerShouldShowSuggestions:(KGOSearchDisplayController *)controller {
    return NO;
}

- (NSArray *)searchControllerValidModules:(KGOSearchDisplayController *)controller {
    return [NSArray arrayWithObject:self.dataManager.module.tag];
}

- (NSString *)searchControllerModuleTag:(KGOSearchDisplayController *)controller {
    return self.dataManager.module.tag;
}

- (void)resultsHolder:(id<KGOSearchResultsHolder>)resultsHolder 
      didSelectResult:(id<KGOSearchResult>)aResult
{
    NSString *section = [[self.videoSections objectAtIndex:self.activeSectionIndex] objectForKey:@"value"];
    
    if ([aResult isKindOfClass:[Video class]]) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                section, @"section", aResult, @"video", nil];
        [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameDetail
                               forModuleTag:[aResult moduleTag]
                                     params:params];
    }
}

- (void)searchController:(KGOSearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    if (controller == self.dataManager.module.searchDelegate) {
        self.dataManager.module.searchDelegate = nil;
    }
    self.federatedSearchTerms = nil;
    self.federatedSearchResults = nil;
    [_navScrollView hideSearchBarAnimated:YES];
    [_navScrollView selectButtonAtIndex:self.activeSectionIndex];
}

@end
