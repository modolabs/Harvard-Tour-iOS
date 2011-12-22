//
//  AthleticsListController.m
//  Universitas
//
//  Created by Liu Mingxing on 12/2/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//
#import "UIKit+KGOAdditions.h"
#import "AthleticsModel.h"
#import "AthleticsListController.h"
#import "AthleticsTableViewCell.h"
#import "KGOAppDelegate+ModuleAdditions.h"

@implementation AthleticsListController
@synthesize dataManager;
@synthesize federatedSearchResults;
@synthesize federatedSearchTerms;
@synthesize stories;
@synthesize categories;
@synthesize activeCategoryId;

#define ATHLETICS_LOADMORE_ROW_HEIGHT 50
#define ATHLETICS_NEWS_ROW_HEIGHT 76
#define ATHLETICS_MENUCATEGORY_ROW_HEIGHT 50

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
    _navTabbar.tintColor = [[KGOTheme sharedTheme] backgroundColorForApplication];
    [self addTableView:_storyTable];
    self.dataManager.delegate = self;
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
//        [_navTabbar showSearchBarAnimated:NO];
//        [_navTabbar.searchController setActive:NO animated:NO];
//        _navTabbar.searchController.searchBar.text = self.federatedSearchTerms;
//        
//        if (self.federatedSearchResults) {
//            [_navTabbar.searchController setSearchResults:self.federatedSearchResults
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
    [_navTabbar release];
    _navTabbar = nil;
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
    [_navTabbar release];
    [_loadingLabel release];
    [_lastUpdateLabel release];
    [_progressView release];
    [_storyTable release];
    self.activeCategoryId = nil;
    self.categories = nil;
    [super dealloc];
}

#pragma mark - Navigation 
- (void)refresh:(id)sender {
    
}

- (void)setupNavTabbedButtons {
    if (self.categories.count > 0) {
        _navTabbar.frame = CGRectMake(0, self.view.bounds.size.height - 49, self.view.bounds.size.width, 49);
        
        //configure the tabbar.
        const NSInteger count = self.categories.count;
        AthleticsCategory *activeCategory = nil;
        UITabBarItem *barItem = nil;
        NSMutableArray *barItems = [NSMutableArray array];
        for (int i = 0; i < count; i++) {
            AthleticsCategory *aCategory = [self.categories objectAtIndex:i];
            barItem = [[UITabBarItem alloc] initWithTitle:aCategory.title 
                                                    image:nil 
                                                      tag:[aCategory.category_id integerValue]];
            [barItems addObject:barItem];
            [barItem release];

            if ([aCategory.category_id isEqualToString:activeCategoryId]) {
                activeCategory = aCategory;
            }
        }
        [_navTabbar setItems:barItems animated:YES];
        for (NSUInteger i = 0; i < [_navTabbar items].count; i++) {
            barItem = [[_navTabbar items] objectAtIndex:i];
            if ([barItem.title isEqualToString:activeCategory.title]) {
                [_navTabbar setSelectedItem:barItem];
                break;
            }
        }
    } else {
        [_navTabbar removeFromSuperview];
        _navTabbar = nil;
        
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
    
    CGFloat y = _navTabbar != nil ? _navTabbar.frame.size.height : 0;
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
    CGFloat y = _navTabbar != nil ? _navTabbar.frame.size.height : 0;
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


#pragma mark -UITabbar Delegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSString *title = item.title;
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

#pragma mark -Menu Cell Organization
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
    cell.textLabel.text = menuCategory.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
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
        cell.textLabel.text = NSLocalizedString(@"Load more stories", @"new story list");
        [cell applyBackgroundThemeColorForIndexPath:indexPath tableView:tableView];
        // TODO: set color to #999999 while things are loading
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#1A1611"];
    } else {
        if (showingMenuCategories) {
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
        if (showingMenuCategories) {
            //TODO:Add Menu Categories Methods.
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:indexPath forKey:@"indexPath"];
            [params setObject:self.stories forKey:@"menuCategories"];
            [params setObject:self.dataManager.currentCategory forKey:@"category"];
            
            [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameItemList
                                   forModuleTag:self.dataManager.moduleTag
                                         params:params];
        } else {
            AthleticsStory *story = [self.stories objectAtIndex:indexPath.row];
            NSString *urlString = story.link;
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }        
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == self.stories.count) {
        return ATHLETICS_LOADMORE_ROW_HEIGHT;
	} else {
        if (showingMenuCategories) {
            return ATHLETICS_MENUCATEGORY_ROW_HEIGHT;
        } else {
            return ATHLETICS_NEWS_ROW_HEIGHT;
        }        
	}
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
//    [_navTabbar hideSearchBarAnimated:YES];
}


@end
