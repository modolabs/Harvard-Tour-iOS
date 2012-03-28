#import "CalendarDayViewController.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "CalendarModel.h"
#import "CalendarDetailViewController.h"
#import "UIKit+KGOAdditions.h"
#import "Foundation+KGOAdditions.h"

@interface CalendarDayViewController (Private)

- (void)requestEventsForCurrentCalendar:(NSDate *)date;
- (void)loadTableViewWithStyle:(UITableViewStyle)style;

@end


// TODO: flesh out placeholder functions
bool isOverOneMonth(NSTimeInterval interval) {
    return interval > 31 * 24 * 60 * 60;
}

bool isOverOneDay(NSTimeInterval interval) {
    return interval > 24 * 60 * 60;
}

bool isOverOneHour(NSTimeInterval interval) {
    return interval > 60 * 60;
}


@implementation CalendarDayViewController

@synthesize federatedSearchTerms, dataManager, moduleTag, eventsLoaded, currentCalendar = _currentCalendar;
@synthesize currentSections = _currentSections, currentEventsBySection = _currentEventsBySection,
groupTitles = _groupTitles;
@synthesize federatedSearchResults, browseMode = _browseMode;
@synthesize datePager = _datePager, tabstrip = _tabstrip, loadingView = _loadingView, footerView = _footerView;
@synthesize suppressSectionTitles = _suppressSectionTitles;

- (void)dealloc
{
    self.dataManager = nil;
    [self clearCalendars];
    [self clearEvents];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (void)clearEvents
{
    self.currentSections = nil;
    self.currentEventsBySection = nil;
}

- (void)clearCalendars
{
    [_currentCalendars release];
    _currentCalendars = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentGroupIndex = NSNotFound;
    
    if (self.browseMode != KGOCalendarBrowseModeLimit) {
        [[NSBundle mainBundle] loadNibNamed:@"KGODatePager" owner:self options:nil];
        _datePager.contentsController = self;
        _datePager.delegate = self;
        [_datePager setDate:[NSDate date]];
        [self.view addSubview:_datePager];
    }
    
    if (self.browseMode != KGOCalendarBrowseModeCategories) {
        _tabstrip.delegate = self;
        _tabstrip.showsSearchButton = YES;
        
        if (_datePager) {
            CGRect frame = _datePager.frame;
            frame.origin.y = CGRectGetMaxY(_tabstrip.frame);
            _datePager.frame = frame;
        }
        
        [self.dataManager requestGroups]; // response to this will populate the tabstrip
        
    } else {
        _tabstrip.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dataManager.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self hideLoading]; // table height will be reset if we have data before the vc appears
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.datePager = nil;
    self.loadingView = nil;
    self.tabstrip = nil;
    self.footerView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - CalendarDataManager

- (void)groupsDidChange:(NSArray *)groups
{
    self.groupTitles = [NSMutableArray array];
    
    for (KGOCalendarGroup *aGroup in groups) {
        [self.groupTitles addObject:aGroup.title];
    }
    
    if (self.groupTitles.count == 1) {
        // if there's only one group, expand the calendars in this group
        [self.dataManager requestCalendarsForGroup:[groups objectAtIndex:0]];
        
    } else {
        [self setupTabstripButtons];
    }
}

- (void)showLoading
{
    if (!_appending) {
        self.tableView.hidden = YES;
        [_loadingView startAnimating];
    }
    if (self.footerView) {
        [self.footerView startLoading];
        self.tableView.tableFooterView = self.footerView;
    }
}

- (void)hideLoading
{
    if (!_appending) {
        self.tableView.hidden = NO;
        [_loadingView stopAnimating];
    }
    if (self.footerView) {
        [self.footerView stopLoading];
        self.tableView.tableFooterView = nil;
        CGSize contentSize = self.tableView.contentSize;
        self.tableView.tableFooterView = self.footerView;
        self.tableView.contentSize = contentSize;
    }
}

- (void)groupDataDidChange:(KGOCalendarGroup *)group
{
    [self clearCalendars];
    [self clearEvents];
    
    if (group.calendars.count) {
        UITableViewStyle style;

        if (group.calendars.count > 1) {
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES];
            _currentCalendars = [[group.calendars sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]] retain];
            
            if (self.groupTitles.count == 1) {
                style = UITableViewStylePlain;
                _datePager.hidden = NO;
                
                [self setupTabstripButtons];
                
            } else {
                style = UITableViewStyleGrouped;
                _datePager.hidden = YES;
            }

        } else {
            style = UITableViewStylePlain;
            _datePager.hidden = NO;
        }
        
        [self loadTableViewWithStyle:style];
        [self hideLoading];

        if (group.calendars.count == 1) {
            // only one calendar so just pick it
            self.currentCalendar = [group.calendars anyObject];
        } else if (self.groupTitles.count > 1) {
            // multiple groups and multiple calendars -- show list of calendars in table view
            self.currentCalendar = nil;
        } else {
            // multiple calendars in this group -- select the first
            self.currentCalendar = [_currentCalendars objectAtIndex:0];
        }

    } else {
        [self.dataManager requestCalendarsForGroup:group];
    }
}

- (void)loadTableViewWithStyle:(UITableViewStyle)style
{
    CGRect frame = self.view.frame;
    if (!_datePager.hidden && [_datePager isDescendantOfView:self.view]) {
        frame.origin.y += _datePager.frame.size.height;
        frame.size.height -= _datePager.frame.size.height;
    }
    if (!_tabstrip.hidden && [_tabstrip isDescendantOfView:self.view]) {
        frame.origin.y += _tabstrip.frame.size.height;
        frame.size.height -= _tabstrip.frame.size.height;
    }
    self.tableView = [self addTableViewWithFrame:frame style:style];

    if (self.federatedSearchTerms || self.federatedSearchResults) {
        [_tabstrip showSearchBarAnimated:NO];
        [_tabstrip.searchController setActive:NO animated:NO];
        _tabstrip.searchController.searchBar.text = self.federatedSearchTerms;
        
        if (self.federatedSearchResults) {
            [_tabstrip.searchController setSearchResults:self.federatedSearchResults
                                            forModuleTag:self.dataManager.moduleTag];
        }
    }
    
    if (self.browseMode == KGOCalendarBrowseModeLimit) {
        [[NSBundle mainBundle] loadNibNamed:@"OverScrollFooterView" owner:self options:nil];
        CGSize contentSize = self.tableView.contentSize;
        self.tableView.tableFooterView = self.loadingView;
        self.tableView.contentSize = contentSize;
    }
}

- (void)eventsDidChange:(NSArray *)events calendar:(KGOCalendar *)calendar didReceiveResult:(BOOL)receivedResult
{
    if (_currentCalendar != calendar) {
        return;
    }
    
    if (!_appending) {
        [self clearEvents];
    }
    
    if (!self.currentSections) {
        self.currentSections = [NSMutableArray array];;
    }

    if (!self.currentEventsBySection) {
        self.currentEventsBySection = [NSMutableDictionary dictionary];
    }

    if (events.count) {
        // TODO: make sure this set of events is what we last requested
        KGOEvent *firstEvent = [events objectAtIndex:0];
        KGOEvent *lastEvent = [events lastObject];
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        NSTimeInterval interval = [lastEvent.startDate timeIntervalSinceDate:firstEvent.startDate];
        if (isOverOneMonth(interval)) {
            [formatter setDateFormat:@"MMMM"];

        } else if (isOverOneDay(interval)) {
            [formatter setDateFormat:@"EEE MMMM d"];

        } else if (isOverOneHour(interval)) {
            [formatter setDateFormat:@"h a"];
        
        } else {
            [formatter setDateFormat:@"h a"]; // default to hourly format
        }
        
        for (KGOEvent *event in events) {
            NSString *title = nil;
            if ([event.allDay boolValue]) {
                title = NSLocalizedString(@"CALENDAR_ALL_DAY_SECTION_HEADER", @"All day");
            } else {
                title = [formatter stringFromDate:event.startDate];
            }
            NSMutableArray *eventsForCurrentSection = [self.currentEventsBySection objectForKey:title];
            if (!eventsForCurrentSection) {
                eventsForCurrentSection = [NSMutableArray array];
                [self.currentEventsBySection setObject:eventsForCurrentSection forKey:title];
                [self.currentSections addObject:title];
            }
            if (![[eventsForCurrentSection mappedArrayUsingBlock:^id(id element) {
                return [element identifier];
            }] containsObject:event.identifier]) {
                [eventsForCurrentSection addObject:event];
            }
        }
    }

    if (receivedResult) {
        self.eventsLoaded = YES;
    }
    
    if (!self.tableView) {
        [self loadTableViewWithStyle:UITableViewStylePlain];
    } else if (_appending) {
        NSInteger sections = [self.tableView numberOfSections];
        if (sections && self.currentSections.count == sections) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sections-1] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            [self reloadDataForTableView:self.tableView];
        }
        _appending = NO;
    } else {
        [self reloadDataForTableView:self.tableView];
    }
    
    [self hideLoading];
}


- (KGOCalendar *)currentCalendar
{
    return _currentCalendar;
}

- (void)setCurrentCalendar:(KGOCalendar *)currentCalendar
{
    [_currentCalendar release];
    _currentCalendar = [currentCalendar retain];
    
    [self requestEventsForCurrentCalendar:[NSDate date]];
}

- (void)requestEventsForCurrentCalendar:(NSDate *)date
{
    if (_currentCalendar) {
        if (!_appending) {
            self.eventsLoaded = NO;
        }
        [self showLoading];
        switch (self.browseMode) {
            case KGOCalendarBrowseModeDay:
            {
                [self.dataManager requestEventsForCalendar:_currentCalendar time:date];
                break;
            }
            case KGOCalendarBrowseModeLimit:
            {
                NSInteger limit = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 25 : 10;
                [self.dataManager requestEventsForCalendar:_currentCalendar start:date limit:limit];
                break;
            }
            case KGOCalendarBrowseModeCategories:
            default:
                break;
        }
    }
}

#pragma mark - Scrolling tabstrip

- (void)tabstrip:(KGOScrollingTabstrip *)tabstrip clickedButtonAtIndex:(NSUInteger)index
{
    if (index != _currentGroupIndex) {
        [self removeTableView:self.tableView];
        [self showLoading];

        _currentGroupIndex = index;

        if (self.groupTitles.count > 1) {
            [self.dataManager selectGroupAtIndex:_currentGroupIndex];
            KGOCalendarGroup *group = [self.dataManager currentGroup];
            [self groupDataDidChange:group];

        } else if (_currentGroupIndex >= 0 && _currentGroupIndex < _currentCalendars.count) {
            self.currentCalendar = [_currentCalendars objectAtIndex:_currentGroupIndex];
        }
    }
}

- (void)setupTabstripButtons
{
    NSUInteger selectedButtonIndex = [_tabstrip indexOfSelectedButton];

    [_tabstrip removeAllRegularButtons];
    if (self.groupTitles.count == 1) {
        for (KGOCalendar *aCalendar in _currentCalendars) {
            [_tabstrip addButtonWithTitle:aCalendar.title];
        }
    
    } else {
        for (NSString *buttonTitle in self.groupTitles) {
            [_tabstrip addButtonWithTitle:buttonTitle];
        }
    }
    [_tabstrip setNeedsLayout];
    
    if (selectedButtonIndex < [_tabstrip numberOfButtons]) {
        [_tabstrip selectButtonAtIndex:selectedButtonIndex];
    } else if ([_tabstrip numberOfButtons]) {
        [_tabstrip selectButtonAtIndex:0];
    }
}

#pragma mark - Date pager

- (void)pager:(KGODatePager *)pager didSelectDate:(NSDate *)date
{
    [self requestEventsForCurrentCalendar:date];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger num = 1;
    if (self.browseMode != KGOCalendarBrowseModeCategories) {
        if (self.currentSections.count) {
            num = self.currentSections.count;
        } else {
            num = 1; // error message
        }
    }
    return num;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num = 0;
    if (self.browseMode == KGOCalendarBrowseModeCategories) {
        num = _currentCalendars.count;
    } else {
        if (self.currentSections.count) {
            NSArray *eventsForSection = [self.currentEventsBySection objectForKey:[self.currentSections objectAtIndex:section]];
            num = eventsForSection.count;
        } else if (self.eventsLoaded) {
            num = 1; // error message
        }
    }

    return num;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (!self.suppressSectionTitles && self.currentSections.count >= 1) { // only true for Day and Limit modes
        return [self.currentSections objectAtIndex:section];
    }
    
    return nil;
}

- (KGOTableCellStyle)tableView:(UITableView *)tableView styleForCellAtIndexPath:(NSIndexPath *)indexPath {
    if (self.browseMode == KGOCalendarBrowseModeCategories) {
        return KGOTableCellStyleDefault;
    }
    return KGOTableCellStyleSubtitle;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.browseMode == KGOCalendarBrowseModeCategories) {
        KGOCalendar *category = [_currentCalendars objectAtIndex:indexPath.row];
        NSString *title = category.title;
        [cell applyBackgroundThemeColorForIndexPath:indexPath tableView:tableView];
        cell.textLabel.text = title;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else if (self.currentSections.count) {
        NSArray *eventsForSection = [self.currentEventsBySection objectForKey:[self.currentSections objectAtIndex:indexPath.section]];
        KGOEvent *event = [eventsForSection objectAtIndex:indexPath.row];
        NSString *title = title = event.title;
        NSString *subtitle = nil;
        if ([event.allDay boolValue]) {
            subtitle = [NSString stringWithFormat:@"%@ %@",
                        [self.dataManager shortDateStringFromDate:event.startDate],
                        NSLocalizedString(@"CALENDAR_ALL_DAY_SUBTITLE", @"All day")];
        } else {
            subtitle = [self.dataManager dateTimeStringForEvent:event multiline:NO];
        }
        cell.textLabel.text = title;
        cell.detailTextLabel.text = subtitle;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else if (self.eventsLoaded) {
        cell.textLabel.text = NSLocalizedString(@"CALENDAR_NO_EVENTS_FOUND", @"No events found");
        cell.detailTextLabel.text = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.browseMode == KGOCalendarBrowseModeCategories) {
        KGOCalendar *calendar = [_currentCalendars objectAtIndex:indexPath.row];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:calendar, @"calendar", nil];
        [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameCategoryList forModuleTag:self.moduleTag params:params];
        
    } else if (self.currentSections.count) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.currentEventsBySection, @"eventsBySection",
                                self.currentSections, @"sections",
                                indexPath, @"currentIndexPath",
                                nil];
                               
        [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameDetail forModuleTag:self.moduleTag params:params];
    }
}

- (BOOL)tabstripShouldShowSearchDisplayController:(KGOScrollingTabstrip *)tabstrip
{
    return YES;
}

- (UIViewController *)viewControllerForTabstrip:(KGOScrollingTabstrip *)tabstrip
{
    return self;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.browseMode == KGOCalendarBrowseModeLimit) {
        // this difference is the height of the gap between the bottom of the content
        // and the bottom of the screen.
        CGFloat overScroll = scrollView.contentOffset.y - (scrollView.contentSize.height - CGRectGetHeight(scrollView.frame));
        if (overScroll > self.tableView.rowHeight) {
            NSString *section = [self.currentSections lastObject];
            if (section) {
                KGOEvent *event = [[self.currentEventsBySection objectForKey:section] lastObject];
                _appending = YES;
                [self requestEventsForCurrentCalendar:event.startDate];
            }
        }
    }
}

#pragma mark KGOSearchDisplayDelegate

- (BOOL)searchControllerShouldShowSuggestions:(KGOSearchDisplayController *)controller {
    return NO;
}

- (NSArray *)searchControllerValidModules:(KGOSearchDisplayController *)controller {
    return [NSArray arrayWithObject:self.moduleTag];
}

- (NSString *)searchControllerModuleTag:(KGOSearchDisplayController *)controller {
    return self.moduleTag;
}

- (void)resultsHolder:(id<KGOSearchResultsHolder>)resultsHolder didSelectResult:(id<KGOSearchResult>)aResult{

    NSString *justALookupKey = @"Section";
    NSArray *sections = [NSArray arrayWithObject:justALookupKey];
    NSDictionary *eventsBySection = [NSDictionary dictionaryWithObject:[resultsHolder results]
                                                                forKey:justALookupKey];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            eventsBySection, @"eventsBySection",
                            sections, @"sections",
                            aResult, @"searchResult",
                            nil];
    
    [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameDetail forModuleTag:self.moduleTag params:params];

}


- (void)searchController:(KGOSearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    self.federatedSearchTerms = nil;
    self.federatedSearchResults = nil;
    [_tabstrip hideSearchBarAnimated:YES];
    [self setupTabstripButtons];
    [_tabstrip selectButtonAtIndex:_currentGroupIndex];
}


@end
