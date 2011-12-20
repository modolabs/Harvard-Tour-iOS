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
   AthleticsCategory *currentCategory =  (AthleticsCategory *)[self.categories objectAtIndex:self.actieveMenuCategoryIdx];
    self.navigationItem.title = currentCategory.title;
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Headlines", nil) 
                                                                              style:UIBarButtonItemStylePlain 
                                                                             target:nil 
                                                                             action:nil] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                                                            target:self 
                                                                                            action:@selector(refresh:)] autorelease];
    
    [self.dataManager fetchMenuCategoryStories:[self.categories objectAtIndex:self.actieveMenuCategoryIdx] 
                                       startId:nil];
    [self.dataManager fetchMenuCategorySchedule:[self.categories objectAtIndex:self.actieveMenuCategoryIdx] 
                                       startId:nil];
    
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
    self.activeCategoryId = nil;
    self.categories = nil;
    self.schedules = nil;
    [super dealloc];
}

#pragma mark - Navigation 
- (void)refresh:(id)sender {
    
}

#pragma mark -
#pragma mark Bottom status bar

- (void)setStatusText:(NSString *)text {
    _loadingLabel.hidden = YES;
    _progressView.hidden = YES;
    _activityView.alpha = 1.0;
	_lastUpdateLabel.hidden = NO;
	_lastUpdateLabel.text = text;

    _storyTable.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
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

    _storyTable.frame = CGRectMake(0, 0, self.view.bounds.size.width,
                                   self.view.bounds.size.height - _activityView.frame.size.height);
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
    cell.textLabel.text = NSLocalizedString(@"Load more stories", @"new story SportsView");
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
    cell.detailTextLabel.text = schedule.location;
    return cell;
}

#pragma mark -KGOTable Methds
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.stories.count > 0) + (self.stories.count > 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger condition = (self.stories.count > 0) + (self.stories.count > 0);
    if (0 == condition) {
        return 0;
    } else if (2 == condition) {
        if (0 == section) {
            return self.schedules.count;
        } else {
            return self.stories.count;
        }
    } else {
        return self.stories.count + self.schedules.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSInteger condition = (self.stories.count > 0) + (self.schedules.count > 0);
    if (2 == condition) {
        if (0 == indexPath.section) {
            cell = [self tableView:tableView scheduleCellAtIndexPath:indexPath];
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
            cell = [self tableView:tableView scheduleCellAtIndexPath:indexPath];
        }
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
