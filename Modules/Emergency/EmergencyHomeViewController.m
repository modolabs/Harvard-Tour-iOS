#import "EmergencyHomeViewController.h"
#import "EmergencyDataManager.h"
#import "KGOHTMLTemplate.h"
#import "UIKit+KGOAdditions.h"
#import "KGOAppDelegate+ModuleAdditions.h"


@interface EmergencyHomeViewController (Private)

- (void)emergencyNoticeRetrieved:(NSNotification *)notification;
- (void)emergencyContactsRetrieved:(NSNotification *)notification;
- (NSArray *)noticeViewsWithtableView:(UITableView *)tableView;

@end

@implementation EmergencyHomeViewController
@synthesize contentDivHeight = _contentDivHeight;
@synthesize module = _module;
@synthesize notice = _notice;
@synthesize infoWebView = _infoWebView;

@synthesize primaryContacts = _primaryContacts;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        loadingStatus = EmergencyStatusLoading;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(emergencyNoticeRetrieved:)
                                                     name:EmergencyNoticeRetrievedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(emergencyContactsRetrieved:)
                                                     name:EmergencyContactsRetrievedNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    self.module = nil;
    self.infoWebView.delegate = nil;
    self.notice = nil;
    self.primaryContacts = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.notice = nil;
    EmergencyDataManager *manager = [EmergencyDataManager managerForTag:_module.tag];
    
    if(_module.noticeFeedExists) {
        [manager fetchLatestEmergencyNotice];
    }
    
    if(_module.contactsFeedExists) {
        // load cached contacts
        self.primaryContacts = [manager primaryContacts];
        _hasMoreContact = [manager hasSecondaryContacts];
        
        // make server request if needed
        [manager fetchContacts];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = 0;
    if (_module.noticeFeedExists) {
        sections++;
    }
    if(_module.contactsFeedExists) {
        sections++;
    }
    return sections;
}

- (NSInteger)sectionIndexForNotice {
    return _module.noticeFeedExists ? 0 : -1;
}

- (NSInteger)sectionIndexForContacts {
    if (!_module.contactsFeedExists) {
        return -1;
    }
    
    return _module.noticeFeedExists ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == [self sectionIndexForNotice]) {
        return 1;
    } else if(section == [self sectionIndexForContacts]) {
        NSInteger contactRows = self.primaryContacts.count;
        if(_hasMoreContact) {
            contactRows++;
        }
        return contactRows;
    }
    return 0;
}

- (NSArray *)tableView:(UITableView *)tableView viewsForCellAtIndexPath:(NSIndexPath *)indexPath {  
    if(indexPath.section == [self sectionIndexForNotice]) {
        return [self noticeViewsWithtableView:tableView];
    }
    return nil;
}

- (CellManipulator)tableView:(UITableView *)tableView manipulatorForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *title = nil;
    NSString *detailText = nil;
    NSString *accessoryTag = nil;
    
    if(indexPath.section == [self sectionIndexForContacts]) {
        if (indexPath.row < self.primaryContacts.count) {
            EmergencyContact *contact = [self.primaryContacts objectAtIndex:indexPath.row];
            title = contact.title;
            detailText = contact.subtitle;
            accessoryTag = KGOAccessoryTypePhone;

        } else if(indexPath.row == self.primaryContacts.count) {
            title = NSLocalizedString(@"EMERGENCY_MORE_CONTACTS", @"More contacts");
            accessoryTag = KGOAccessoryTypeChevron;
        }
    }
    
    return [[^(UITableViewCell *cell) {
        cell.textLabel.text = title;
        cell.detailTextLabel.text = detailText;
        if(accessoryTag) {
            cell.accessoryView = [[KGOTheme sharedTheme] accessoryViewForType:accessoryTag];
        } else {
            cell.accessoryView = nil;
        }
    } copy] autorelease];
}

- (KGOTableCellStyle)tableView:(UITableView *)tableView styleForCellAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == [self sectionIndexForContacts]) {
        if (indexPath.row < self.primaryContacts.count) {
            return KGOTableCellStyleSubtitle;          
        } 
    }
    return KGOTableCellStyleDefault;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    if (indexPath.section == [self sectionIndexForContacts]) {
        if (indexPath.row < self.primaryContacts.count) {
            EmergencyContact *contact = [self.primaryContacts objectAtIndex:indexPath.row];
            NSURL *externURL = [NSURL URLWithString:contact.url];
            if ([[UIApplication sharedApplication] canOpenURL:externURL]) {
                [[UIApplication sharedApplication] openURL:externURL];
            }
            
        } else if (indexPath.row == self.primaryContacts.count) {
            [KGO_SHARED_APP_DELEGATE() showPage:EmergencyContactsPathPageName forModuleTag:_module.tag params:nil];
        }
    }
    
}

- (NSArray *)noticeViewsWithtableView:(UITableView *)tableView {
    CGFloat height = 1000.0f;
    if (_contentDivHeight) {
        height = [self.contentDivHeight floatValue] + 20.0;
    }
    CGFloat hPadding = 2;
    CGRect frame = CGRectMake(hPadding, 4,
                              tableView.frame.size.width - ([tableView marginWidth] + hPadding) * 2,
                              height);

    self.infoWebView = [[[UIWebView alloc] initWithFrame:frame] autorelease];
    self.infoWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.infoWebView.backgroundColor = [UIColor clearColor];
    self.infoWebView.opaque = NO;
    self.infoWebView.delegate = self;

    KGOHTMLTemplate *template = [KGOHTMLTemplate templateWithPathName:@"common/webview.html"];
    NSString *contentText = nil;
    
    switch (loadingStatus) {
        case EmergencyStatusLoading:
            contentText = NSLocalizedString(@"COMMON_INDETERMINATE_LOADING", @"Loading...");
            break;
        case EmergencyStatusFailed:
            contentText = NSLocalizedString(@"EMERGENCY_STATUS_LOAD_FAILED", @"Failed to load.");
            break;
        case EmergencyStatusLoaded:
            if (_notice) {
                NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                [dateFormatter setDateFormat:@"MMM d, y"];
                NSString *pubDate = [dateFormatter stringFromDate:_notice.pubDate];

                // TODO: make sure no strings are nil
                contentText = [NSString stringWithFormat:
                               @"<h2 class=\"compact\">%@</h2>"
                               "<p class=\"date\">%@</p>"
                               "<div class=\"body\">%@</div>", _notice.title, pubDate, _notice.html];
            } else {
                contentText = [NSString stringWithFormat:@"<h2 class=\"compact\">%@</h2>",
                               NSLocalizedString(@"EMERGENCY_NO_EMERGENCY_MESSAGE", @"No emergency")];
            }
            break;
        default:
            break;
    }

    NSString *bodyText = [NSString stringWithFormat:@"<div id=\"content\">%@</div>", contentText];
    NSDictionary *values = [NSDictionary dictionaryWithObject:bodyText forKey:@"BODY"];
    [self.infoWebView loadTemplate:template values:values];

    return [NSArray arrayWithObject:self.infoWebView];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.contentDivHeight) {
        // height already known so just exit
        return;
    }
    NSString *output = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"content\").offsetHeight;"];
    self.contentDivHeight = [NSNumber numberWithInt:[output intValue]];
    if (self.contentDivHeight) {
        [self reloadDataForTableView:self.tableView];
    }
}

- (void)emergencyNoticeRetrieved:(NSNotification *)notification {
    id object = [notification object];
    EmergencyDataManager *manager = [EmergencyDataManager managerForTag:_module.tag];
    if (object == manager) {    
        enum EmergencyNoticeStatus status = [[[notification userInfo] objectForKey:@"EmergencyStatus"] intValue];
        loadingStatus = EmergencyStatusLoaded;
        
        if (status == NoCurrentEmergencyNotice) {
            self.notice = nil;
        } else if (status == EmergencyNoticeActive) {
            // reset content values
            self.notice = [[EmergencyDataManager managerForTag:_module.tag] latestEmergency];
        }
        self.contentDivHeight = nil;
        
        [self reloadDataForTableView:self.tableView];
    }
}

- (void)emergencyContactsRetrieved:(NSNotification *)notification {
    id object = [notification object];
    EmergencyDataManager *manager = [EmergencyDataManager managerForTag:_module.tag];
    if (object == manager) {
        self.primaryContacts = [manager primaryContacts];
        _hasMoreContact = [manager hasSecondaryContacts];    
        [self reloadDataForTableView:self.tableView];
    }
}

@end
