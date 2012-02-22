#import "AthleticsScheduleDetailViewController.h"
#import "Foundation+KGOAdditions.h"
@implementation AthleticsScheduleDetailViewController
@synthesize currentSchedule;


- (id)init {
    self = [super init];
    if (self) {
        _scheduleTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 460) 
                                                      style:UITableViewStyleGrouped];
        _scheduleTable.dataSource = self;
        _scheduleTable.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [_scheduleTable release];
    self.currentSchedule = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -UIViewController lifesycle

- (void)viewDidLoad {
    self.navigationItem.title = @"Schedule";
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ATHLETICS_SCHEDULE_BACK_BUTTON", @"Headlines") 
                                                                              style:UIBarButtonItemStylePlain 
                                                                             target:nil 
                                                                             action:nil] autorelease];
    [self addTableView:_scheduleTable];
    
}
#pragma mark -TableView Cell
- (UITableViewCell *)tableView:(UITableView *)tableView nonLinkCellForIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    static NSString *topicIdentifier = @"nonLinkIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:topicIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                      reuseIdentifier:topicIdentifier];
    }
    AthleticsSchedule *schedule = self.currentSchedule;
    cell.textLabel.text = schedule.title;
    cell.textLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertySportListTitle];
    double unixtime = [schedule.start doubleValue];
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:unixtime];
    NSString *detailString = [NSString stringWithFormat:@"%@\n%@",[startDate weekDateTimeString],schedule.location];
    cell.detailTextLabel.text = detailString;
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertySportListSubtitle];
    return [cell autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView topicCellForIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    static NSString *topicIdentifier = @"topicIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:topicIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                      reuseIdentifier:topicIdentifier];
    }
    AthleticsSchedule *schedule = self.currentSchedule;
    cell.textLabel.text = schedule.title;
    cell.textLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertySportListTitle];
    double unixtime = [schedule.start doubleValue];
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:unixtime];
    NSString *detailString = [NSString stringWithFormat:@"%@",[startDate weekDateTimeString]];
    cell.detailTextLabel.text = detailString;
    cell.detailTextLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertySportListSubtitle];
    return [cell autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView linkCellForIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    static NSString *topicIdentifier = @"linkIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:topicIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                      reuseIdentifier:topicIdentifier];
    }
    AthleticsSchedule *schedule = self.currentSchedule;
    cell.textLabel.text = schedule.location;
    cell.textLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertySportListTitle];
    cell.detailTextLabel.text = schedule.link;
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertySportListSubtitle];
    return [cell autorelease];
}

#pragma mark -TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.currentSchedule) {
        if (self.currentSchedule.link.length > 0) {
            return 2;
        } else {
            return 1;
        }
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentSchedule.link.length > 0) {
        if (0 == indexPath.row) {
            return [self tableView:tableView topicCellForIndexPath:indexPath];
        } else {
            return [self tableView:tableView linkCellForIndexPath:indexPath];
        }
    } else {
        return [self tableView:tableView nonLinkCellForIndexPath:indexPath];
    }
}

#pragma mark -UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *link = self.currentSchedule.link;
    if (link.length > 0 && 1 == indexPath.row) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}


@end
