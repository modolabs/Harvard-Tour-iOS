//
//  AthleticsSportsViewController.m
//  Universitas
//
//  Created by Liu Mingxing on 12/2/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//
#import "UIKit+KGOAdditions.h"
#import "AthleticsModel.h"
#import "AthleticsSportsViewController.h"
#import "AthleticsTableViewCell.h"
#import "KGOAppDelegate+ModuleAdditions.h"

@implementation AthleticsSportsViewController
@synthesize dataManager;
@synthesize federatedSearchResults;
@synthesize federatedSearchTerms;
@synthesize stories;
@synthesize categories;
@synthesize activeCategoryId;


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
    _navTabbedView.delegate = self;
    _storyTable.separatorColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [self addTableView:_storyTable];
    
    //configure these things
    self.navigationItem.title = @"Athletics";
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Headlines", nil) 
                                                                              style:UIBarButtonItemStylePlain 
                                                                             target:nil 
                                                                             action:nil] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                                            target:self 
                                                                                            action:@selector(refresh:)] autorelease];
    [self.dataManager fetchCategories];
    
    //    if (self.federatedSearchTerms || self.federatedSearchResults) {
    //        [_navTabbedView showSearchBarAnimated:NO];
    //        [_navTabbedView.searchController setActive:NO animated:NO];
    //        _navTabbedView.searchController.searchBar.text = self.federatedSearchTerms;
    //        
    //        if (self.federatedSearchResults) {
    //            [_navTabbedView.searchController setSearchResults:self.federatedSearchResults
    //                                                 forModuleTag:self.dataManager.moduleTag];
    //        }
    //    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupNavTabbedButtons]; // needed for updating bookmark status
}



- (void)viewDidUnload
{
    [_navTabbedView release];
    _navTabbedView = nil;
    [_loadingLabel release];
    _loadingLabel = nil;
    [_lastUpdateLabel release];
    _lastUpdateLabel = nil;
    [_progressView release];
    _progressView = nil;
    [_storyTable release];
    _storyTable = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_navTabbedView release];
    [_loadingLabel release];
    [_lastUpdateLabel release];
    [_progressView release];
    [_storyTable release];
    [_athletcisCell release];
    self.activeCategoryId = nil;
    self.categories = nil;
    [super dealloc];
}

#pragma mark - Navigation 
- (void)refresh:(id)sender {
    
}

- (void)setupNavTabbedButtons {
    if (self.categories.count > 0) {
        [_navTabbedView removeAllTabs];
        _navTabbedView.frame = CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44);
        
        //configure the tabbar.
        const NSInteger count = self.categories.count;
        AthleticsCategory *activeCategory = nil;
        for (int i = 0; i < count; i++) {
            AthleticsCategory *aCategory = [self.categories objectAtIndex:i];
            [_navTabbedView insertTabWithTitle:aCategory.title atIndex:i animated:NO];
            if (!activeCategory || [aCategory.category_id isEqualToString:activeCategoryId]) {
                activeCategory = aCategory;
                activeCategoryId = activeCategory.category_id;
            }
        }
        [_navTabbedView setNeedsLayout];
        for (NSUInteger i = 0; i < _navTabbedView.numberOfTabs; i++) {
            if ([[_navTabbedView titleForTabAtIndex:i] isEqualToString:activeCategory.title]) {
                [_navTabbedView setSelectedTabIndex:i];
                break;
            }
        }
    } else {
        [_navTabbedView removeFromSuperview];
        _navTabbedView = nil;
        
        CGFloat dh = _activityView.hidden ? 0 : _activityView.frame.size.height;
        _storyTable.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - dh);
    }
}

#pragma mark -
#pragma mark Bottom status bar

- (void)setStatusText:(NSString *)text {
    _loadingLabel.hidden = YES;
    _progressView.hidden = YES;
    _activityView.alpha = 1.0;
	_lastUpdateLabel.hidden = NO;
	_lastUpdateLabel.text = text;
    
    CGFloat y = _navTabbedView != nil ? _navTabbedView.frame.size.height : 0;
    _storyTable.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - y);
    
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
                             NSLocalizedString(@"Last Updated", nil),
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
    CGFloat y = _navTabbedView != nil ? _navTabbedView.frame.size.height : 0;
    _storyTable.frame = CGRectMake(0, 0, self.view.bounds.size.width,
                                   self.view.bounds.size.height - y - _activityView.frame.size.height);
}

#pragma mark -
#pragma mark NewsDataController delegate methods

- (void)dataController:(AthleticsDataController *)controller didFailWithCategoryId:(NSString *)categoryId
{
    if([self.activeCategoryId isEqualToString:categoryId]) {
        [self setStatusText:NSLocalizedString(@"Update failed", @"news story update failed")];
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
    
    [self setupNavTabbedButtons]; // update button pressed states
    
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


#pragma mark -KGOScrollingTabstrip Delegate
- (void)tabbedControl:(KGOTabbedControl *)contol didSwitchToTabAtIndex:(NSInteger)index {
    NSString *title = [contol titleForTabAtIndex:index];
    for (AthleticsCategory *aCategory in self.categories) {
        if ([aCategory.title isEqualToString:title]) {
            NSString *tagValue = aCategory.category_id;
            [self switchToCategory:tagValue];
            break;
        }
    }
}

- (void)switchToCategory:(NSString *)category {
    showingBookmarks = NO;
    showingMenuCategories = NO;
    if (![category isEqualToString:self.activeCategoryId]) {
		self.activeCategoryId = category;
        self.dataManager.delegate = self;
        if (![self.activeCategoryId isEqualToString:@"0"]) {
            showingMenuCategories = YES;
            [self.dataManager fetchMenusForCategory:self.activeCategoryId startId:nil];
        } else {
            [self.dataManager fetchStoriesForCategory:self.activeCategoryId startId:nil];
        }
        // makes request to server if no request has been made this session
        //[self.dataManager requestStoriesForCategory:self.activeCategoryId loadMore:NO forceRefresh:NO];
    }
}

#pragma mark -KGOTable Methds
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.stories.count > 0) ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger n = self.stories.count;
    return n;
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
        cell.textLabel.text = NSLocalizedString(@"Load more stories", @"new story SportsView");
        [cell applyBackgroundThemeColorForIndexPath:indexPath tableView:tableView];
        // TODO: set color to #999999 while things are loading
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#1A1611"];
    } else {
        NSString *cellIdentifier = [AthleticsTableViewCell commonReuseIdentifier];
        cell = (AthleticsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            NSArray *container = [[NSBundle mainBundle] loadNibNamed:@"AthleticsTableViewCell" owner:self options:nil];
            _athletcisCell = (AthleticsTableViewCell *)[container objectAtIndex:0];
            cell = [_athletcisCell retain];
            [_athletcisCell configureLabelsTheme];
        }
        [(AthleticsTableViewCell *)cell setStory:[self.stories objectAtIndex:indexPath.row]];
        [cell applyBackgroundThemeColorForIndexPath:indexPath tableView:tableView];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
