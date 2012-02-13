//
//  AthleticsScheduleListViewController.m
//  Universitas
//
//  Created by Liu Mingxing on 12/30/11.
//  Copyright (c) 2011 Symbio Inc. All rights reserved.
//

#import "AthleticsScheduleListViewController.h"
#import "AthleticsModel.h"
#import "Foundation+KGOAdditions.h"
#import "KGOAppDelegate+ModuleAdditions.h"
@implementation AthleticsScheduleListViewController
@synthesize schedules;
@synthesize dataManager;
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
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _scheduleListView.separatorColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [self addTableView:_scheduleListView];
    self.dataManager.delegate = self;
    self.navigationItem.title = @"Schedule";
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ATHLETICS_SCHEDULE_BACK_BUTTON", @"Headlines") 
                                                                              style:UIBarButtonItemStylePlain 
                                                                             target:nil 
                                                                             action:nil] autorelease];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    self.schedules = nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark -UITableViewCell
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
    cell.detailTextLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertySportListSubtitle];
    cell.detailTextLabel.numberOfLines = 2;
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

#pragma mark -UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.schedules.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView scheduleCellAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self scheduleCellDidSelected:indexPath];
}




@end
