#import "CalendarDetailViewController.h"
#import "KGOContactInfo.h"
#import "KGORequestManager.h"
#import "Foundation+KGOAdditions.h"
#import "UIKit+KGOAdditions.h"
#import "CalendarDataManager.h"
#import "KGOShareButtonController.h"
#import "MITMailComposeController.h"
#import "KGOModule.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "MapModule.h"
#import "KGOEvent.h"

#define CELL_TITLE_TAG 31415
#define DESCRIPTION_WEBVIEW_TAG 5
#define CELL_SUBTITLE_TAG 271
#define CELL_LABELS_HORIZONTAL_PADDING 10
#define CELL_LABELS_VERTICAL_PADDING 10
#define CELL_ACCESSORY_PADDING 27
#define CELL_GROUPED_PADDING 10

@implementation CalendarDetailViewController

@synthesize sections = _sections, eventsBySection, indexPath = _indexPath,
dataManager, searchResult, event = _event, headerView = _headerView, tableView = _tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"CALENDAR_EVENT_DETAIL_PAGE_TITLE", @"Event Detail");

    _descriptionSectionId = NSNotFound;
    _descriptionHeight = 0;
    
    _shareController = [(KGOShareButtonController *)[KGOShareButtonController alloc] initWithContentsController:self];
    _shareController.shareTypes = KGOShareControllerShareTypeEmail | KGOShareControllerShareTypeFacebook | KGOShareControllerShareTypeTwitter;
    
    KGODetailPager *pager = [[[KGODetailPager alloc] initWithPagerController:self delegate:self] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:pager] autorelease];
    if (self.indexPath) {
        [pager selectPageAtSection:self.indexPath.section row:self.indexPath.row];
    }
    else if(self.searchResult){
        [self pager:pager showContentForPage:searchResult];
    }
    
    // hide separator lines below the bottom cell for plain table views
    self.tableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
    
    self.dataManager.delegate = self;
}

#pragma mark -

- (void)setEvent:(KGOEvent *)event
{
    [_event release];
    _event = [event retain];
    
    DLog(@"%@ %@ %@ %@", [_event description], _event.title, _event.location, _event.userInfo);
    
    if (_event) {
        [self eventDetailsDidChange:_event];
        
        // TODO: see if there is a way to tell we don't need to update this event
        if (!_event.summary.length) {
            [self.dataManager requestDetailsForEvent:_event];
        }
    }
}

- (void)eventDetailsDidChange:(KGOEvent *)event
{
    NSMutableArray *mutableSections = [NSMutableArray array];
    NSArray *basicInfo = [self sectionForBasicInfo];
    if (basicInfo.count) {
        [mutableSections addObject:basicInfo];
    }
    
    NSArray *attendeeInfo = [self sectionForAttendeeInfo];
    if (attendeeInfo.count) {
        [mutableSections addObject:attendeeInfo];
    }
    
    NSArray *contactInfo = [self sectionForContactInfo];
    if (contactInfo.count) {
        [mutableSections addObject:contactInfo];
    }
    
    NSArray *extendedInfo = [self sectionForExtendedInfo];
    if (extendedInfo.count) {
        _descriptionSectionId = mutableSections.count;
        [mutableSections addObject:extendedInfo];
    }
    NSArray *sections = [self sectionsForFields];
    if (sections.count) {
        [mutableSections addObjectsFromArray:sections];
    }
    
    [_detailSections release];
    _detailSections = [mutableSections copy];
    
    [self.tableView reloadData];
    self.tableView.tableHeaderView = [self viewForTableHeader];
}


- (NSArray *)sectionForBasicInfo
{
    NSArray *basicInfo = nil;
    if (_event.location || _event.coordinate.latitude || _event.coordinate.longitude) {
        NSMutableDictionary *locationDict = [NSMutableDictionary dictionary];
        
        if (_event.briefLocation) {
            [locationDict setObject:_event.briefLocation forKey:@"title"];
            if (_event.location) {
                [locationDict setObject:_event.location forKey:@"subtitle"];
            }
            
        } else if (_event.location) {
            [locationDict setObject:_event.location forKey:@"title"];
        } else { // if we got this far there has to be a lat/lon
            [locationDict setObject:@"View on Map" forKey:@"title"];
        }
        
        if (_event.coordinate.latitude || _event.coordinate.longitude) {
            [locationDict setObject:KGOAccessoryTypeMap forKey: @"accessory"];
        }
        
        basicInfo = [NSArray arrayWithObject:locationDict];
    }
    DLog(@"%@", basicInfo);
    return basicInfo;
}

- (NSArray *)sectionForAttendeeInfo
{
    NSArray *attendeeInfo = nil;
    if (_event.attendees.count) {
        NSString *attendeeString = [NSString stringWithFormat:
                                    NSLocalizedString(@"CALENDAR_%d_OTHERS_ATTENDING", @"%d others attending"),
                                    _event.attendees.count];
        attendeeInfo = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 attendeeString, @"title",
                                                 KGOAccessoryTypeChevron, @"accessory",
                                                 nil]];
    }
    return attendeeInfo;
}

- (NSArray *)sectionForContactInfo
{
    NSMutableArray *contactInfo = [NSMutableArray array];
    if (_event.organizers) {
        for (KGOEventParticipant *organizer in _event.organizers) {
            for (KGOEventContactInfo *aContact in organizer.contactInfo) {
                NSString *type;
                NSString *accessory;
                NSString *url = nil;
                
                if ([aContact.type isEqualToString:@"phone"]) {
                    type = NSLocalizedString(@"CALENDAR_ORGANIZER_PHONE", @"Organizer phone");
                    accessory = KGOAccessoryTypePhone;
                    url = [NSString stringWithFormat:@"tel:%@", aContact.value];
                    
                } else if ([aContact.type isEqualToString:@"email"]) {
                    type = NSLocalizedString(@"CALENDAR_ORGANIZER_EMAIL", @"Organizer email");
                    accessory = KGOAccessoryTypeEmail;
                    
                } else if ([aContact.type isEqualToString:@"url"]) {
                    type = NSLocalizedString(@"CALENDAR_EVENT_WEBSITE", @"Event website");
                    accessory = KGOAccessoryTypeExternal;
                    url = aContact.value;
                    
                } else {
                    type = NSLocalizedString(@"CALENDAR_CONTACT_INFO", @"Contact");
                    accessory = KGOAccessoryTypeNone;
                }
                
                NSDictionary *cellInfo = nil;
                if (url) {
                    cellInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                type, @"title", aContact.value, @"subtitle", accessory, @"accessory", url, @"url", nil];
                } else {
                    cellInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                type, @"title", aContact.value, @"subtitle", accessory, @"accessory", nil];
                }
                
                
                [contactInfo addObject:cellInfo];
            }
        }
        
    }
    return contactInfo;
}

- (NSArray *)sectionForExtendedInfo
{
    NSArray *extendedInfo = nil;
    if (_event.summary) {
        if (!_descriptionView) {
            CGFloat margin = [self.tableView marginWidth]; // will be zero for plain style tableview
            CGRect frame = CGRectMake(0, 0,
                                      CGRectGetWidth(self.tableView.bounds) - 2 * margin,
                                      self.tableView.rowHeight); // placeholder height
            _descriptionView = [[UIWebView alloc] initWithFrame:frame];
            _descriptionView.delegate = self;
            _descriptionView.tag = DESCRIPTION_WEBVIEW_TAG; // set this so we can remove it from the cell that has it
        }
        
        KGOHTMLTemplate *template = [KGOHTMLTemplate templateWithPathName:@"common/webview.html"];
        NSMutableDictionary *values = [NSMutableDictionary dictionary];
        [values setValue:_event.summary forKey:@"BODY"];
        [_descriptionView loadTemplate:template values:values];
        extendedInfo = [NSArray arrayWithObject:_descriptionView];
    }
    return extendedInfo;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *output = [webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"];
    _descriptionHeight = [output floatValue];
    if (_descriptionHeight && _descriptionHeight != CGRectGetHeight(_descriptionView.frame)) {
        CGRect frame = _descriptionView.frame;
        frame.size.height = _descriptionHeight;
        _descriptionView.frame = frame;
        
        NSIndexSet *sections = [NSIndexSet indexSetWithIndex:_descriptionSectionId];
        [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (NSArray *)sectionsForFields
{
    NSMutableArray *sections = [NSMutableArray array];
    NSMutableArray *currentSection = nil;
    NSString *currentSectionName = @"";
    
    if (_event.fields) {
        for (NSDictionary *field in [_event fieldsArray]) {
            NSString *label = [field nonemptyStringForKey:@"title"];
            NSString *value = [field nonemptyStringForKey:@"value"];
            NSString *type = [field nonemptyStringForKey:@"type"];
            
            NSString *accessory = nil;
            NSString *url = nil;
            if ([type isEqualToString:@"phone"]) {
                if (!label) {
                    label = NSLocalizedString(@"CALENDAR_ORGANIZER_PHONE", @"Organizer phone");
                }
                accessory = KGOAccessoryTypePhone;
                url = [NSString stringWithFormat:@"tel:%@", value];
                
            } else if ([type isEqualToString:@"email"]) {
                if (!label) {
                    label = NSLocalizedString(@"CALENDAR_ORGANIZER_EMAIL", @"Organizer email");
                }
                accessory = KGOAccessoryTypeEmail;
                
            } else if ([type isEqualToString:@"url"]) {
                accessory = KGOAccessoryTypeExternal;
                url = [field nonemptyStringForKey:@"value"];
            }
            
            NSDictionary *cellInfo = nil;
            if (label) {
                cellInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                            label, @"title", value, @"subtitle", accessory, @"accessory", url, @"url", nil];
            } else {
                cellInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                            value, @"title", accessory, @"accessory", url, @"url", nil];
            }
            
            NSString *sectionName = [field stringForKey:@"section"];
            if (![sectionName isEqualToString:currentSectionName]) {
                if ([currentSection count]) {
                    // new section, store previous section and start over
                    [sections addObject:currentSection];
                    currentSection = nil;
                }
                currentSectionName = sectionName;
            }
            if (!currentSection) {
                currentSection = [NSMutableArray array];
            }
            
            [currentSection addObject:cellInfo];
        }
        
        // Add last section if there is anything in it
        if ([currentSection count]) {
            [sections addObject:currentSection];
        }
    }
    return sections;
}

- (NSString *)dateDescriptionForEvent:(KGOEvent *)event
{
    NSString *dateString = [self.dataManager mediumDateStringFromDate:_event.startDate];
    NSString *timeString = nil;
    if (_event.allDay) {
        NSString *endDateString = [self.dataManager mediumDateStringFromDate:_event.endDate];
        if ([endDateString isEqualToString:dateString]) {
            timeString = [NSString stringWithFormat:@"%@\n%@", dateString, NSLocalizedString(@"CALENDAR_ALL_DAY_SUBTITLE", @"All day")];
        } else {
            timeString = [NSString stringWithFormat:@"%@ - %@", dateString, endDateString];
            
        }
    } else {
        if (_event.endDate) {
            timeString = [NSString stringWithFormat:@"%@\n%@-%@",
                          dateString,
                          [self.dataManager shortTimeStringFromDate:_event.startDate],
                          [self.dataManager shortTimeStringFromDate:_event.endDate]];
        } else {
            timeString = [NSString stringWithFormat:@"%@\n%@",
                          dateString,
                          [self.dataManager shortTimeStringFromDate:_event.startDate]];
        }
    }
    return timeString;
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionData = [_detailSections objectAtIndex:section];
    return sectionData.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _detailSections.count;
}

- (CGFloat)cellLabelWidthWithAccessory:(BOOL)hasAccessory {
    CGFloat cellWidth = self.tableView.frame.size.width;
    cellWidth = cellWidth - 2 * CELL_LABELS_HORIZONTAL_PADDING;
    if (hasAccessory) {
        cellWidth = cellWidth - CELL_ACCESSORY_PADDING;
    }
    
    if (self.tableView.style == UITableViewStyleGrouped) {
        cellWidth = cellWidth - 2 * CELL_GROUPED_PADDING;
    }
    return cellWidth;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    NSString *cellIdentifier = nil;
    NSArray *sectionData = [_detailSections objectAtIndex:indexPath.section];
    id cellData = [sectionData objectAtIndex:indexPath.row];
    if ([cellData isKindOfClass:[NSDictionary class]]) {
        if ([cellData objectForKey:@"subtitle"]) {
            style = UITableViewCellStyleSubtitle;
        }
        cellIdentifier = [NSString stringWithFormat:@"%d", style];
        
    } else {
        cellIdentifier = [NSString stringWithFormat:@"%d.%d", indexPath.section, indexPath.row];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:cellIdentifier] autorelease];
        
        UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        titleLabel.tag = CELL_TITLE_TAG;
        titleLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyNavListTitle];
        titleLabel.textColor = [[KGOTheme sharedTheme] textColorForThemedProperty:KGOThemePropertyNavListTitle];
        titleLabel.numberOfLines = 0;
        titleLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:titleLabel];
        
        UILabel *subtitleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        subtitleLabel.tag = CELL_SUBTITLE_TAG;
        subtitleLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyNavListSubtitle];
        subtitleLabel.textColor = [[KGOTheme sharedTheme] textColorForThemedProperty:KGOThemePropertyNavListSubtitle];
        subtitleLabel.numberOfLines = 0;
        subtitleLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:subtitleLabel];
        
    } else {
        cell.imageView.image = nil;
        UIView *view = [cell viewWithTag:DESCRIPTION_WEBVIEW_TAG];
        [view removeFromSuperview];
    }

    if ([cellData isKindOfClass:[NSDictionary class]]) {  
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:CELL_TITLE_TAG];
        UILabel *subtitleLabel = (UILabel *)[cell viewWithTag:CELL_SUBTITLE_TAG];
        titleLabel.text = [cellData objectForKey:@"title"];
        subtitleLabel.text = [cellData objectForKey:@"subtitle"];
        if ([cellData objectForKey:@"image"]) {
            cell.imageView.image = [cellData objectForKey:@"image"];
        }
        
        NSString *accessory = [cellData objectForKey:@"accessory"];
        cell.accessoryView = [[KGOTheme sharedTheme] accessoryViewForType:accessory];
        BOOL hasAccessory = accessory && ![accessory isEqualToString:KGOAccessoryTypeNone];
        if (hasAccessory) {
            [cell applyBackgroundThemeColorForIndexPath:indexPath tableView:tableView];
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        // size title and subtitle views.
        CGFloat contentViewWidth = [self cellLabelWidthWithAccessory:hasAccessory];
        CGSize titleSize = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(contentViewWidth, 1000)];
        CGSize subtitleSize = [subtitleLabel.text sizeWithFont:subtitleLabel.font constrainedToSize:CGSizeMake(contentViewWidth, 1000)];
        titleLabel.frame = CGRectMake(CELL_LABELS_HORIZONTAL_PADDING, CELL_LABELS_VERTICAL_PADDING, 
                                      contentViewWidth, titleSize.height);
        subtitleLabel.frame = CGRectMake(CELL_LABELS_HORIZONTAL_PADDING, titleSize.height + CELL_LABELS_VERTICAL_PADDING, 
                                         contentViewWidth, subtitleSize.height);

    } else {
        if ([cellData isKindOfClass:[UIWebView class]]) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:cellData];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cellData = [[_detailSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if ([cellData isKindOfClass:[UIWebView class]]) {
        return _descriptionHeight;
    }
    
    // calculate height
    NSString *accessory = [cellData objectForKey:@"accessory"];
    BOOL hasAccessory = accessory && ![accessory isEqualToString:KGOAccessoryTypeNone];
    
    CGFloat contentViewWidth = [self cellLabelWidthWithAccessory:hasAccessory];
    UIFont *titleFont = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyNavListTitle];
    NSString *title = [cellData objectForKey:@"title"];
    CGSize titleSize = [title sizeWithFont:titleFont constrainedToSize:CGSizeMake(contentViewWidth, 1000)];
    
    UIFont *subtitleFont = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyNavListSubtitle];
    NSString *subtitle = [cellData objectForKey:@"subtitle"];
    CGSize subtitleSize = [subtitle sizeWithFont:subtitleFont constrainedToSize:CGSizeMake(contentViewWidth, 1000)];
    
    return titleSize.height + subtitleSize.height + 2 * CELL_LABELS_VERTICAL_PADDING;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cellData = [[_detailSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([cellData isKindOfClass:[NSDictionary class]]) {
        NSString *accessory = [cellData objectForKey:@"accessory"];
        NSURL *url = nil;
        NSString *urlString = [cellData objectForKey:@"url"];
        if (urlString) {
            url = [NSURL URLWithString:urlString];
        }
        
        if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        } else if ([accessory isEqualToString:KGOAccessoryTypeEmail]) {
            [self presentMailControllerWithEmail:[cellData objectForKey:@"subtitle"]
                                         subject:nil
                                            body:nil
                                        delegate:self];
            
        } else if ([accessory isEqualToString:KGOAccessoryTypeMap]) {
            NSArray *annotations = [NSArray arrayWithObject:_event];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:annotations, @"annotations", nil];
            // TODO: redo this when we have cross-module linking
            for (KGOModule *aModule in [KGO_SHARED_APP_DELEGATE() modules]) {
                if ([aModule isKindOfClass:[MapModule class]]) {
                    [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameHome forModuleTag:aModule.tag params:params];
                    return;
                }
            }
        }
    }
}

#pragma mark - KGODetailPager

- (void)pager:(KGODetailPager *)pager showContentForPage:(id<KGOSearchResult>)content
{
    if ([content isKindOfClass:[KGOEvent class]]) {
        self.event = (KGOEvent *)content;
    }
}

- (id<KGOSearchResult>)pager:(KGODetailPager *)pager contentForPageAtIndexPath:(NSIndexPath *)anIndexPath
{
    NSString *sectionName = [self.sections objectAtIndex:anIndexPath.section];
    NSArray *events = [self.eventsBySection objectForKey:sectionName];
    return [events objectAtIndex:anIndexPath.row];
}

- (NSInteger)pager:(KGODetailPager *)pager numberOfPagesInSection:(NSInteger)section
{
    NSString *sectionName = [self.sections objectAtIndex:section];
    return [[self.eventsBySection objectForKey:sectionName] count];
}

- (NSInteger)numberOfSections:(KGODetailPager *)pager
{
    return self.sections.count;
}

#pragma mark - Table Header

- (UIView *)viewForTableHeader
{
    if (!self.headerView) {
        [[NSBundle mainBundle] loadNibNamed:@"KGODetailPageHeaderView" owner:self options:nil];
        self.headerView.delegate = self;
        self.headerView.showsBookmarkButton = NO;
        self.headerView.showsShareButton = YES;
        [self.headerView addButtonWithImage:[UIImage imageWithPathName:@"modules/calendar/calendar"]
                               pressedImage:[UIImage imageWithPathName:@"modules/calendar/calendar_pressed"]
                                     target:self
                                     action:@selector(calendarButtonPressed:)];
    }
    self.headerView.detailItem = self.event;
    self.headerView.subtitle = [self dateDescriptionForEvent:_event];
    return self.headerView;
}

- (void)calendarButtonPressed:(id)sender
{
    [self presentModalViewController:[self.event eventViewController]
                            animated:YES];
}

- (void)headerViewFrameDidChange:(KGODetailPageHeaderView *)headerView
{
    self.tableView.tableHeaderView = headerView;
}

- (void)headerView:(KGODetailPageHeaderView *)headerView shareButtonPressed:(id)sender
{
    _shareController.actionSheetTitle = @"Share this event";
    _shareController.shareTitle = _event.title;
    _shareController.shareBody = _event.summary;
    
    NSString *urlString = nil;
    for (KGOEventParticipant *organizer in _event.organizers) {
        for (KGOContactInfo *contact in organizer.contactInfo) {
            if ([contact.type isEqualToString:@"url"]) {
                urlString = contact.value;
                break;
            }
        }
        if (urlString)
            break;
    }
    
    if (!urlString) {
        KGOCalendar *calendar = [_event.calendars anyObject];
        NSString *startString = [NSString stringWithFormat:@"%.0f", [_event.startDate timeIntervalSince1970]];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                _event.identifier, @"id",
                                calendar.identifier, @"calendar",
                                calendar.type, @"type",
                                startString, @"time",
                                nil];
        
        urlString = [[NSURL URLWithQueryParameters:params baseURL:[[KGORequestManager sharedManager] serverURL]] absoluteString];
    }
    
    _shareController.shareURL = urlString;
    
    [_shareController shareInView:self.view];
}

#pragma mark -

// MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    _descriptionView.delegate = nil;
    [_descriptionView release];
    [_event release];
	[_shareController release];
    [_detailSections release];
    self.tableView = nil;
    self.dataManager.delegate = nil;
    self.dataManager = nil;
    self.sections = nil;
    self.indexPath = nil;
    self.eventsBySection = nil;
    [super dealloc];
}

@end
