#import "UIKit+KGOAdditions.h"
#import "AthleticsModel.h"
#import "AthleticsListController.h"
#import "AthleticsTableViewCell.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "UIKit+KGOAdditions.h"
#import "KGOTheme.h"
#import "KGOSearchDisplayController.h"


@interface AthleticsListController (Private)

- (void)setupTabstrip;

@end


@implementation AthleticsListController
@synthesize dataManager;
@synthesize federatedSearchResults;
@synthesize federatedSearchTerms;
@synthesize stories;
@synthesize categories;
@synthesize activeCategoryId;

#define ATHLETICS_LOADMORE_ROW_HEIGHT 50
#define ATHLETICS_NEWS_ROW_HEIGHT 76
#define ATHLETICS_MENUCATEGORY_ROW_HEIGHT 55
#define ATHLETICS_TABLEVIEW_SPACING 0

#define ATHLETICS_TABLEVIEW_TAG_TOPNEWS 0
#define ATHLETICS_TABLEVIEW_TAG_MEN 1
#define ATHLETICS_TABLEVIEW_TAG_WOMEN 2
#define ATHLETICS_TABLEVIEW_TAG_MYSPORTS 3

#define ATHLETICS_LABEL_TAG_NULL 4
- (id)init {
    self = [super init];
    if (self) {
        
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
    self.dataManager.delegate = self;
    self.dataManager.currentCategories = nil;
    self.dataManager.currentCategory = nil;
    self.dataManager.currentStories = nil;
    [self.dataManager fetchCategories];
    [self addTableView:_storyTable];
    //configure these things
    self.navigationItem.title = @"Athletics";
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ATHLETICS_HEADLINES", @"Headlines") 
                                                                             style:UIBarButtonItemStylePlain 
                                                                            target:nil 
                                                                            action:nil] autorelease];
    [self setupTabstrip];
    [_navTabs selectButtonAtIndex:0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    self.dataManager.delegate = self;
    [_navTabs selectButtonAtIndex:[self.activeCategoryId integerValue]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    self.activeCategoryId = nil;
    self.categories = nil;
    [super dealloc];
}

#pragma mark - Navigation 
- (BOOL)showMunuCategories {
    if ([self.activeCategoryId isEqualToString:@"0"]) {
        return NO;
    }
    return YES;
}

#pragma mark - KGOScrollTabs
- (void)setupTabstrip {
    _navTabs.delegate = self;
    _navTabs.showsSearchButton = YES;
    [_navTabs addButtonWithTitle:NSLocalizedString(@"ATHLETICS_TAB_TOP_NEWS", @"Top News")];
    [_navTabs addButtonWithTitle:NSLocalizedString(@"ATHLETICS_TAB_MEN", @"Men")];
    [_navTabs addButtonWithTitle:NSLocalizedString(@"ATHLETICS_TAB_WOMEN", @"Women")];
    [_navTabs addButtonWithTitle:NSLocalizedString(@"ATHLETICS_TAB_MY_SPORTS", @"My Sports")];
    _topNewsTabIndex = 0;
    _menTabIndex = 1;
    _womenTabIndex = 2;
    _mySportsTabIndex = 3;
    [_navTabs layoutSubviews];
}

- (void)tabstrip:(KGOScrollingTabstrip *)tabstrip clickedButtonAtIndex:(NSUInteger)index {
    self.dataManager.delegate = self;
    self.activeCategoryId = [NSString stringWithFormat:@"%d",index];
    if (index == _topNewsTabIndex) {
        [self.dataManager fetchStoriesForCategory:self.activeCategoryId startId:nil];
        _storyTable.tag = ATHLETICS_TABLEVIEW_TAG_TOPNEWS;
    } else if (index == _menTabIndex) {
        [self.dataManager fetchMenusForCategory:self.activeCategoryId startId:nil];
        _storyTable.tag = ATHLETICS_TABLEVIEW_TAG_MEN;
    } else if (index == _womenTabIndex) {
        [self.dataManager fetchMenusForCategory:self.activeCategoryId startId:nil];
        _storyTable.tag = ATHLETICS_TABLEVIEW_TAG_WOMEN;
    } else if (index == _mySportsTabIndex) {
        _storyTable.tag = ATHLETICS_TABLEVIEW_TAG_MYSPORTS;
        [self.dataManager fetchBookmarks];
    }
}

#pragma mark - KGOScrollingTabstripSearchDelegate

- (BOOL)tabstripShouldShowSearchDisplayController:(KGOScrollingTabstrip *)tabstrip {
    return YES;
}

- (UIViewController *)viewControllerForTabstrip:(KGOScrollingTabstrip *)tabstrip {
    return self;
}

#pragma mark -
#pragma mark Bottom status bar

- (void)activeViewLayout {
    CGRect oldTableFrame = _storyTable.frame;
    CGRect activityFrame = _activityView.frame;
    
    CGFloat newHeight = self.view.bounds.size.height - _navTabs.frame.size.height;
    [_storyTable setFrame:CGRectMake(oldTableFrame.origin.x, oldTableFrame.origin.y,
                                     oldTableFrame.size.width, newHeight)];
    CGFloat yActivityView = oldTableFrame.origin.y + newHeight - activityFrame.size.height;
    [_activityView setFrame:CGRectMake(activityFrame.origin.x, yActivityView,
                                       activityFrame.size.width, activityFrame.size.height)];
}

- (void)setStatusText:(NSString *)text {
    _loadingLabel.hidden = YES;
    _progressView.hidden = YES;
    _activityView.alpha = 1.0;
	_lastUpdateLabel.hidden = NO;
	_lastUpdateLabel.text = text;
    
    [self activeViewLayout];
    
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
    _loadingLabel.text = NSLocalizedString(@"COMMON_LOADING", @"Loading...");
    _activityView.hidden = NO;
    _activityView.alpha = 1.0;
    
    [self activeViewLayout];
}

#pragma mark -
#pragma mark NewsDataController delegate methods

- (void)dataController:(AthleticsDataController *)controller didFailWithCategoryId:(NSString *)categoryId
{
    if([self.activeCategoryId isEqualToString:categoryId]) {
        [self setStatusText:NSLocalizedString(@"ATHLETICS_UPDATE_FAILED", @"Update failed")];
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
-(void)receivedSearchResults:(NSArray *)searchResults forSource:(NSString *)source {
    self.stories = searchResults;
    [_storyTable reloadData];
    [_storyTable flashScrollIndicators];
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
    [_storyTable reloadData];
    [_storyTable flashScrollIndicators];
}

- (void)dataController:(AthleticsDataController *)controller didRetrieveMenuCategories:(NSArray *)menuCategories {
    self.stories = menuCategories;
    [self setLastUpdated:[NSDate date]];
    [_storyTable reloadData];
    [_storyTable flashScrollIndicators];
}

- (void)dataController:(AthleticsDataController *)controller didRetrieveBookmarkedCategories:(NSArray *)bookmarkedCategories {
    self.stories = bookmarkedCategories;
    [_storyTable reloadData];
    [_storyTable flashScrollIndicators];
}

#pragma mark -Menu Cell Organization
- (BOOL)string:(NSString *)src containString:(NSString *)match {
    if ([src rangeOfString:match].location != NSNotFound) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)titleForDesignated:(AthleticsCategory *)mCategory {
    if (activeCategoryId.intValue == _mySportsTabIndex) {
        if ([self string:mCategory.ivar containString:@"m-"]) 
        {
            return [NSString stringWithFormat:@"Men's %@",mCategory.title];
        }
        if ([self string:mCategory.ivar containString:@"w-"]) 
        {
            return [NSString stringWithFormat:@"Women's %@",mCategory.title];
        }
    }
    return mCategory.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForMenuAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"athleticsMenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                      reuseIdentifier:cellIdentifier] autorelease];
    }
    AthleticsCategory *menuCategory = [self.stories objectAtIndex:indexPath.row];
    cell.textLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyMediaListTitle];
    cell.textLabel.textColor = [[KGOTheme sharedTheme] textColorForThemedProperty:KGOThemePropertyMediaListTitle];
    
    cell.textLabel.text = [self titleForDesignated:menuCategory];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark -KGOTable Methds
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.stories.count == 0 && [self.activeCategoryId isEqualToString:@"3"]) {
        UILabel *nullLabel = [[UILabel alloc] initWithFrame:tableView.frame];
        nullLabel.text = NSLocalizedString(@"ATHLETICS_BOOKMARK_INSTRUCTIONS", @"To save a favorite, click the star icon while viewing a sport");
        nullLabel.font = [UIFont boldSystemFontOfSize:16];
        nullLabel.numberOfLines = 2;
        nullLabel.textAlignment = UITextAlignmentCenter;
        nullLabel.lineBreakMode = UILineBreakModeWordWrap;
        nullLabel.tag = ATHLETICS_LABEL_TAG_NULL;
        [tableView addSubview:nullLabel];
        [nullLabel release];
    } else {
        NSArray *subViews = [tableView subviews];
        for (UIView *view in subViews) {
            if (view.tag == ATHLETICS_LABEL_TAG_NULL) {
                [view removeFromSuperview];
                break;
            }
        }
    }
    return (self.stories.count > 0) ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self showMunuCategories]) {
        return self.stories.count;
    } else {
        NSInteger n = self.stories.count;
        if ([self.dataManager canLoadMoreStories]) {
            n++;
        }
        return n;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.row == self.stories.count) {
        static NSString *loadMoreIdentifier = @"loadmore";
        cell = [tableView dequeueReusableCellWithIdentifier:loadMoreIdentifier];
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:loadMoreIdentifier] autorelease];
        }
        cell.textLabel.text = NSLocalizedString(@"ATHLETICS_LOAD_MORE_STORIES", @"Load more stories");
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyNavListTitle];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        [cell applyBackgroundThemeColorForIndexPath:indexPath tableView:tableView];
        // TODO: set color to #999999 while things are loading
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#1A1611"];
    } else {
        if ([self showMunuCategories]) {
            cell = [self tableView:tableView cellForMenuAtIndexPath:indexPath];
        } else {
            NSString *cellIdentifier = [AthleticsTableViewCell commonReuseIdentifier];
            cell = (AthleticsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                [[NSBundle mainBundle] loadNibNamed:@"AthleticsTableViewCell" owner:self options:nil];
                cell = _athletcisCell;
                [_athletcisCell configureLabelsTheme];
            }
            [(AthleticsTableViewCell *)cell setStory:[self.stories objectAtIndex:indexPath.row]];
            [cell applyBackgroundThemeColorForIndexPath:indexPath tableView:tableView];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == self.stories.count) {
        AthleticsStory *story = [self.stories lastObject];
        NSString *lastId = story.identifier;
        // TODO: doesn't seem right that we need to se this on the datamanager
        self.dataManager.currentStories = [[self.stories mutableCopy] autorelease];
        [self.dataManager requestStoriesForCategory:self.activeCategoryId afterId:lastId];
	} else {
        if ([self showMunuCategories]) {
            //TODO:Add Menu Categories Methods.
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:indexPath forKey:@"indexPath"];
            [params setObject:self.stories forKey:@"menuCategories"];
            [params setObject:self.dataManager.currentCategory forKey:@"category"];
            
            [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameItemList
                                   forModuleTag:self.dataManager.moduleTag
                                         params:params];
        } else {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:@"story" forKey:@"type"];
            [params setObject:indexPath forKey:@"indexPath"];
            [params setObject:self.stories forKey:@"stories"];
            [params setObject:self.dataManager.currentCategory forKey:@"category"];
            [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameDetail
                                   forModuleTag:self.dataManager.moduleTag
                                         params:params];
        }        
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == self.stories.count) {
        return ATHLETICS_LOADMORE_ROW_HEIGHT;
	} else {
        if ([self showMunuCategories]) {
            return ATHLETICS_MENUCATEGORY_ROW_HEIGHT;
        } else {
            return ATHLETICS_NEWS_ROW_HEIGHT;
        }        
	}
}

#pragma mark - KGOSearchDisplayDelegate



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
    KGOSearchDisplayController *displayC = (KGOSearchDisplayController *)resultsHolder;
    NSArray *results = displayC.results;
    AthleticsStory *story = aResult;
    NSInteger idx = [results indexOfObject:story];
    if (idx >= 0  && idx < results.count) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:@"story" forKey:@"type"];
        [params setObject:[NSIndexPath indexPathForRow:idx inSection:0] forKey:@"indexPath"];
        [params setObject:results forKey:@"stories"];
        [params setObject:self.dataManager.currentCategory forKey:@"category"];
        [params setObject:displayC.searchResults forKey:@"stories"];
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
    [_navTabs hideSearchBarAnimated:YES];
}


@end
