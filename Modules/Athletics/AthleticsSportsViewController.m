#import "UIKit+KGOAdditions.h"
#import "Foundation+KGOAdditions.h"
#import "AthleticsModel.h"
#import "AthleticsSportsViewController.h"
#import "AthleticsTableViewCell.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "CoreDataManager.h"
#import <QuartzCore/QuartzCore.h>

#define ATHLETICS_SCHDULES_ROW_HEIGHT 65
#define ATHLETICS_NEWS_ROW_HEIGHT 76
#define BOOKMARK_HEIGHT 10
#define OFFSIDE 27

@implementation AthleticsSportsViewController
@synthesize dataManager;
@synthesize federatedSearchResults;
@synthesize federatedSearchTerms;
@synthesize stories;
@synthesize schedules;
@synthesize categories;
@synthesize activeCategoryId;
@synthesize actieveMenuCategoryIdx;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _storyTable.separatorColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [self addTableView:_storyTable];
    self.dataManager.delegate = self;
    //configure these things
    self.navigationItem.title = [self titleForMenuCategory];
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ATHLETICS_SCHEDULE_BACK_BUTTON", @"Headlines") 
                                                                              style:UIBarButtonItemStylePlain 
                                                                             target:nil 
                                                                             action:nil] autorelease];
    [self.dataManager fetchMenuCategoryStories:[self.categories objectAtIndex:self.actieveMenuCategoryIdx] 
                                       startId:nil];
    [self.dataManager fetchMenuCategorySchedule:[self.categories objectAtIndex:self.actieveMenuCategoryIdx] 
                                       startId:nil];
    [self setupBookmarkStatus];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureBookmark];
}

- (void)viewDidUnload
{
    [_loadingLabel release];
    _loadingLabel = nil;
    [_lastUpdateLabel release];
    _lastUpdateLabel = nil;
    [_progressView release];
    _progressView = nil;
    [_storyTable release];
    _storyTable = nil;
    [_bookmarkView release];
    _bookmarkView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_loadingLabel release];
    [_lastUpdateLabel release];
    [_progressView release];
    [_storyTable release];
    [_athletcisCell release];
    [_bookmarkView release];
    self.activeCategoryId = nil;
    self.categories = nil;
    self.schedules = nil;
    [super dealloc];
}

#pragma mark - Navigation 

#pragma mark - Self Functions
- (NSString *)titleForMenuCategory {
    AthleticsCategory *currentCategory =  (AthleticsCategory *)[self.categories objectAtIndex:self.actieveMenuCategoryIdx];
    return currentCategory.title;
}

#pragma mark -
#pragma mark Bottom status bar

- (void)setStatusText:(NSString *)text {
    _loadingLabel.hidden = YES;
    _progressView.hidden = YES;
    _activityView.alpha = 1.0;
	_lastUpdateLabel.hidden = NO;
	_lastUpdateLabel.text = text;

    _storyTable.frame = CGRectMake(0, (BOOKMARK_HEIGHT + OFFSIDE), self.view.bounds.size.width,
                                   self.view.bounds.size.height - 
                                   (BOOKMARK_HEIGHT + OFFSIDE));
    [UIView animateWithDuration:1.0 delay:2.0 options:0 animations:^(void) {
        _activityView.alpha = 0;
    } completion:^(BOOL finished) {
        _activityView.hidden = YES;
    }];
}

- (void)setLastUpdated:(NSDate *)date {
    if (date) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [self setStatusText:[NSString stringWithFormat:@"%@ %@",
                             NSLocalizedString(@"ATHLETICS_LAST_UPDATED", @"Last Updated"),
                             [formatter stringFromDate:date]]];
        [formatter release];
    }
}

- (void)setProgress:(CGFloat)value {
	_loadingLabel.hidden = NO;
	_progressView.hidden = NO;
	_lastUpdateLabel.hidden = YES;
	_progressView.progress = value;
    
    _activityView.hidden = NO;
    _activityView.alpha = 1.0;

    _storyTable.frame = CGRectMake(0, (BOOKMARK_HEIGHT + OFFSIDE), self.view.bounds.size.width,
                                   self.view.bounds.size.height - _activityView.frame.size.height - (BOOKMARK_HEIGHT + OFFSIDE));
}

- (void)configureBookmark {
    [_bookmarkView layoutSubviews];
    [self.view bringSubviewToFront:_bookmarkView];
    _storyTable.frame = CGRectMake(0, (BOOKMARK_HEIGHT + OFFSIDE), self.view.bounds.size.width,
                                   self.view.bounds.size.height - (BOOKMARK_HEIGHT + OFFSIDE));
}

- (void)headerViewFrameDidChange:(KGODetailPageHeaderView *)headerView {
    headerView.frame = CGRectMake(0, 0, 320, 38);
    [headerView buttonSizeFitsToMargin];
}

- (void)setupBookmarkStatus {
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, BOOKMARK_HEIGHT);
    _bookmarkView = [[KGODetailPageHeaderView alloc] initWithFrame:frame];
    [_bookmarkView setDetailItem:[self.categories objectAtIndex:self.actieveMenuCategoryIdx]];
    _bookmarkView.showsBookmarkButton = YES;
    _bookmarkView.showsShareButton = NO;
    _bookmarkView.showsSubtitle = NO;
    _bookmarkView.delegate = self;
    _bookmarkView.titleLabel.text = [self titleForMenuCategory];
    [self.view addSubview:_bookmarkView];
}

#pragma mark -
#pragma mark NewsDataController delegate methods

- (void)dataController:(AthleticsDataController *)controller didFailWithCategoryId:(NSString *)categoryId
{
    if([self.activeCategoryId isEqualToString:categoryId]) {
        [self setStatusText:NSLocalizedString(@"ATHLETICS_LIST_UPDATE_FAILED", @"Update failed")];
    }
}

- (void)dataController:(AthleticsDataController *)controller didMakeProgress:(CGFloat)progress
{
    [self setProgress:progress];
}
/*
 - (void)dataController:(NewsDataController *)controller didPruneStoriesForCategoryId:(NSString *)categoryId
 {
 }
 */
- (void)dataController:(AthleticsDataController *)controller didReceiveSearchResults:(NSArray *)results
{
    
}

- (void)dataController:(AthleticsDataController *)controller didRetrieveCategories:(NSArray *)theCategories
{
    self.categories = theCategories;
    
    if (!self.activeCategoryId && theCategories.count) {
        AthleticsCategory *category = [theCategories objectAtIndex:0];
        self.activeCategoryId = category.category_id;
    }
    
    // now that we have categories load the stories
    if (self.activeCategoryId) {
        [self.dataManager fetchStoriesForCategory:self.activeCategoryId startId:nil];
    }
}

- (void)dataController:(AthleticsDataController *)controller didRetrieveStories:(NSArray *)theStories
{
    self.stories = theStories;
    [self setLastUpdated:[NSDate date]];
    [self reloadDataForTableView:_storyTable];
    [_storyTable flashScrollIndicators];
}

- (void)dataController:(AthleticsDataController *)controller didRetrieveMenuCategories:(NSArray *)menuCategories {
    self.stories = menuCategories;
    [self setLastUpdated:[NSDate date]];
    [self reloadDataForTableView:_storyTable];
    [_storyTable flashScrollIndicators];
}

- (void)dataController:(AthleticsDataController *)controller didRetrieveSchedules:(NSArray *)theSchedules {
    self.schedules = theSchedules;
    [self setLastUpdated:[NSDate date]];
    [self reloadDataForTableView:_storyTable];
    [_storyTable flashScrollIndicators];
}

#pragma mark -TableView Data Organization
- (UITableViewCell *)tableView:(UITableView *)tableView athleticsCellAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    NSString *cellIdentifier = [AthleticsTableViewCell commonReuseIdentifier];
    cell = (AthleticsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        NSArray *container = [[NSBundle mainBundle] loadNibNamed:@"AthleticsTableViewCell" owner:self options:nil];
        _athletcisCell = (AthleticsTableViewCell *)[container objectAtIndex:0];
        cell = [[_athletcisCell retain] autorelease];
        [_athletcisCell configureLabelsTheme];
    }
    [(AthleticsTableViewCell *)cell setStory:[self.stories objectAtIndex:indexPath.row]];
    [cell applyBackgroundThemeColorForIndexPath:indexPath tableView:tableView];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView loadMoreCellAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    static NSString *loadMoreIdentifier = @"loadmore";
    cell = [tableView dequeueReusableCellWithIdentifier:loadMoreIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:loadMoreIdentifier] autorelease];
    }
    cell.textLabel.text = NSLocalizedString(@"ATHLETICS_LIST_LOAD_MORE", @"Load more stories");
    cell.textLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyNavListTitle];
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    [cell applyBackgroundThemeColorForIndexPath:indexPath tableView:tableView];
    // TODO: set color to #999999 while things are loading
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#1A1611"];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView scheduleCellAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    static NSString *scheduleIdentifier = @"schedule";
    cell = [tableView dequeueReusableCellWithIdentifier:scheduleIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                      reuseIdentifier:scheduleIdentifier] autorelease];
    }
    AthleticsSchedule *schedule = [self.schedules objectAtIndex:indexPath.row];
    cell.textLabel.text = schedule.title;
    cell.textLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertySportListTitle];
    double unixtime = [schedule.start doubleValue];
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:unixtime];
    NSString *detailString = [NSString stringWithFormat:@"%@\n%@",[startDate weekDateTimeString],schedule.location];
    cell.detailTextLabel.text = detailString;
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertySportListSubtitle];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView loadFullSchedulesCellAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    static NSString *loadFullSchedulesIdentifier = @"loadFullSchedules";
    cell = [tableView dequeueReusableCellWithIdentifier:loadFullSchedulesIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:loadFullSchedulesIdentifier] autorelease];
    }
    cell.textLabel.text = NSLocalizedString(@"ATHLETICS_FULL_SCHEDULE_AND_RESULTS", @"Full Schedule and Results");
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    cell.textLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyNavListTitle];
    return cell;
}

- (void)scheduleCellDidSelected:(NSIndexPath *)indexPath {
    AthleticsSchedule *scheduleInstance = [self.schedules objectAtIndex:indexPath.row];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:scheduleInstance forKey:@"schedule"];
    [params setObject:@"schedule" forKey:@"type"];
    
    [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameDetail
                           forModuleTag:self.dataManager.moduleTag
                                 params:params];
}

- (void)fullSchedulCellDidSelected:(NSIndexPath *)indexPath {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"scheduleList" forKey:@"type"];
    [params setObject:self.schedules forKey:@"schedules"];
    [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameItemList
                           forModuleTag:self.dataManager.moduleTag
                                 params:params];
}

- (void)storyCellDidSelected:(NSIndexPath *)indexPath {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"story" forKey:@"type"];
    [params setObject:indexPath forKey:@"indexPath"];
    [params setObject:self.stories forKey:@"stories"];
    [params setObject:self.dataManager.currentCategory forKey:@"category"];
    [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameDetail
                           forModuleTag:self.dataManager.moduleTag
                                 params:params];
}

- (void)loadMoreStoryCellDidSelected:(NSIndexPath *)indexPath {
    AthleticsStory *story = [self.stories lastObject];
    NSString *lastId = story.identifier;
    // TODO: doesn't seem right that we need to se this on the datamanager
    self.dataManager.currentStories = [[self.stories mutableCopy] autorelease];
    [self.dataManager requestMenuCategoryStoriesForCategory:self.dataManager.currentCategory 
                                                    afterId:lastId];
}

#pragma mark -KGOTable Methds
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.stories.count > 0) + (self.schedules.count > 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger condition = (self.stories.count > 0) + (self.schedules.count > 0);
    if (0 == condition) {
        return 0;
    } else if (2 == condition) {
        if (0 == section) {
            if (self.schedules.count <= 2) {
                return self.schedules.count;
            } else {
                return 3;
            }
        } else {
            NSInteger n = self.stories.count;
            if ([self.dataManager canLoadMoreStories]) {
                n++;
            }
            return n;
        }
    } else {
        NSInteger scheduleNumber = self.schedules.count;
        if (self.stories.count > 0) {
            NSInteger n = self.stories.count;
            if ([self.dataManager canLoadMoreStories]) {
                n++;
            }
            return n;
        } else {
            return (scheduleNumber <= 2) ? scheduleNumber : 3;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSInteger condition = (self.stories.count > 0) + (self.schedules.count > 0);
    if (2 == condition) {
        if (0 == indexPath.section) {
            if (indexPath.row <= 1) {
                cell = [self tableView:tableView scheduleCellAtIndexPath:indexPath];
            } else {
                cell = [self tableView:tableView loadFullSchedulesCellAtIndexPath:indexPath];
            }
        } else {
            if (indexPath.row == self.stories.count) {
               cell = [self tableView:tableView loadMoreCellAtIndexPath:indexPath];
            } else {
               cell = [self tableView:tableView athleticsCellAtIndexPath:indexPath];
            }
        }
    } else {
        if (self.stories.count > 0) {
            if (indexPath.row == self.stories.count) {
                cell = [self tableView:tableView loadMoreCellAtIndexPath:indexPath];
            } else {
                cell = [self tableView:tableView athleticsCellAtIndexPath:indexPath];
            }
        } else {
            if (indexPath.row <= 1) {
                cell = [self tableView:tableView scheduleCellAtIndexPath:indexPath];
            } else {
                cell = [self tableView:tableView loadFullSchedulesCellAtIndexPath:indexPath];
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger condition = (self.stories.count > 0) + (self.schedules.count > 0);
    if (0 == condition) {
        return;
    } else if (2 == condition) {
        if (0 == indexPath.section) {
            if (indexPath.row == 2) {
                [self fullSchedulCellDidSelected:indexPath];
            } else {
                [self scheduleCellDidSelected:indexPath];
            }
        } else {
            if (indexPath.row == self.stories.count) {
                [self loadMoreStoryCellDidSelected:indexPath];
            } else {
                [self storyCellDidSelected:indexPath];
            }
        }
    } else {
        if (self.stories.count > 0) {
            if (indexPath.row == self.stories.count) {
                [self loadMoreStoryCellDidSelected:indexPath];
            } else {
                [self storyCellDidSelected:indexPath];
            }
        } else {
            if (indexPath.row == 2) {
                [self fullSchedulCellDidSelected:indexPath];
            } else {
                [self scheduleCellDidSelected:indexPath];
            }
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSInteger condition = (self.stories.count > 0) + (self.schedules.count > 0);
    if (0 == condition) {
        return nil;
    } else if (2 == condition) {
        if (0 == section) {
            return @"Schedule";
        } else {
            return @"News";
        }
    } else {
        if (self.stories.count > 0) {
            return @"News";
        } else {
            return @"Schedule";
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger condition = (self.stories.count > 0) + (self.stories.count > 0);
    if (0 == condition) {
        return 0;
    } else if (2 == condition) {
        if (0 == indexPath.section) {
            return ATHLETICS_SCHDULES_ROW_HEIGHT;
        } else {
            return ATHLETICS_NEWS_ROW_HEIGHT;
        }
    } else {
        if (self.stories.count > 0) {
            return ATHLETICS_NEWS_ROW_HEIGHT;
        } else {
            return ATHLETICS_SCHDULES_ROW_HEIGHT;
        }
    }
    return 0;
}

#pragma mark - KGOSearchDisplayDelegate

//- (BOOL)tabstripShouldShowSearchDisplayController:(KGOScrollingTabstrip *)tabstrip
//{
//    return YES;
//}

//- (UIViewController *)viewControllerForTabstrip:(KGOScrollingTabstrip *)tabstrip
//{
//    return self;
//}

- (BOOL)searchControllerShouldShowSuggestions:(KGOSearchDisplayController *)controller {
    return NO;
}

- (NSArray *)searchControllerValidModules:(KGOSearchDisplayController *)controller {
    return [NSArray arrayWithObject:self.dataManager.moduleTag];
}

- (NSString *)searchControllerModuleTag:(KGOSearchDisplayController *)controller {
    return self.dataManager.moduleTag;
}

- (void)resultsHolder:(id<KGOSearchResultsHolder>)resultsHolder didSelectResult:(id<KGOSearchResult>)aResult {
    AthleticsStory *story = aResult;
    if ([[story hasBody] boolValue]) {
        NSArray *resultStories = [resultsHolder results];
        NSInteger row = [resultStories indexOfObject:story];
        NSDictionary *params = nil;
        if (row != NSNotFound) {
            params = [NSDictionary dictionaryWithObjectsAndKeys:
                      resultStories, @"stories",
                      [NSIndexPath indexPathForRow:row inSection:0], @"indexPath",
                      nil];
        } else {
            params = [NSDictionary dictionaryWithObjectsAndKeys:
                      aResult, @"story",
                      nil];
        }
        [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameDetail 
                               forModuleTag:self.dataManager.moduleTag
                                     params:params];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:story.link]];
    }
}

- (void)searchController:(KGOSearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    self.federatedSearchTerms = nil;
    self.federatedSearchResults = nil;
    //    [_navTabbedView hideSearchBarAnimated:YES];
}


@end

@implementation KGODetailPageHeaderView (Athletics)
- (void)buttonSizeFitsToMargin {
    CGRect frame = CGRectZero;
    frame.origin.x = self.bounds.size.width;
    
    // if there is no subtitle, make title label narrower
    // and align buttons at the top.
    // if there is a subtitle, make title label the full width,
    // subtitle label narrower, and align buttons with subtitle.
    frame.origin.y = (self.subtitleLabel == nil ? 0 : self.titleLabel.frame.size.height);
    self.titleLabel.textAlignment = UITextAlignmentCenter;
    self.titleLabel.frame = CGRectMake(10, 0, 246, 38);
    self.titleLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertySportListTitle];
    for (UIButton *aButton in self.actionButtons) {
        if (![aButton isDescendantOfView:self]) {
            [self addSubview:aButton];
        }
        
        frame.size = aButton.frame.size;
        frame.origin.x -= frame.size.width ;
        aButton.frame = frame;
        
        if (aButton == self.bookmarkButton) {
            [self setupBookmarkButtonImages];
        }
    }
}
@end
