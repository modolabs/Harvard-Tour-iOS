#import "TourOverviewController.h"
#import "TourMapController.h"
#import "TourDataManager.h"
#import "TourWalkingPathViewController.h"

#define CellThumbnailViewTag 1

@interface TourOverviewController (Private)
- (void)showMapAnimated:(BOOL)animated;
- (void)showListAnimated:(BOOL)animated;
- (void)deallocViews;
- (UIToolbar *)mapToolbar;

- (void)startTour;
@end

@implementation TourOverviewController
@synthesize selectedStop;
@synthesize tourStops;
@synthesize mode;
@synthesize tourMapController;
@synthesize contentView = _contentView;
@synthesize stopsTableView = _stopsTableView;
@synthesize stopCell;
@synthesize mapContainerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tourMapController = [[[TourMapController alloc] initWithNibName:@"TourMapController" bundle:nil] autorelease];
        self.tourMapController.showMapTip = YES;
    }
    return self;
}

- (void)dealloc
{
    [self deallocViews];
    [super dealloc];
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
    self.mapContainerView = [[[UIView alloc] initWithFrame:self.contentView.bounds] autorelease];
    self.mapContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIToolbar *mapToolbar = [self mapToolbar];
    self.tourMapController.view.frame = CGRectMake(0, 0, 
        self.contentView.frame.size.width, self.contentView.frame.size.height - mapToolbar.frame.size.height);
    mapToolbar.frame = CGRectMake(0, self.contentView.frame.size.height - mapToolbar.frame.size.height,
                            self.contentView.frame.size.width, mapToolbar.frame.size.height);
    [self.mapContainerView addSubview:self.tourMapController.view];
    [self.mapContainerView addSubview:mapToolbar];
    
    self.stopsTableView.rowHeight = 50;
    if(!self.tourStops) {
        self.tourStops = [[TourDataManager sharedManager] getAllTourStops];
    }
    self.tourMapController.selectedStop = self.selectedStop;
    [self showMapAnimated:NO];
}

- (void)deallocViews {
    self.mapContainerView = nil;
    self.contentView = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self deallocViews];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)mapListToggled:(id)sender {
    UISegmentedControl *mapListToggle = sender;
    if(mapListToggle.selectedSegmentIndex == 0) {
        [self showMapAnimated:YES];
    } else if(mapListToggle.selectedSegmentIndex == 1) {
        [self showListAnimated:YES];
    }
}

- (void)showMapAnimated:(BOOL)animated {
    if([self.mapContainerView superview] != _contentView) {
        self.mapContainerView.frame = _contentView.bounds;
        NSTimeInterval duration = animated ? 0.75 : -1;
        [UIView transitionFromView:_stopsTableView 
            toView:self.mapContainerView duration:duration 
            options:UIViewAnimationOptionTransitionFlipFromRight 
            completion:NULL];
    }
}

- (void)showListAnimated:(BOOL)animated {
    if([self.stopsTableView superview] != _contentView) {
        NSTimeInterval duration = animated ? 0.75 : -1;
        [UIView transitionFromView:self.mapContainerView
                            toView:_stopsTableView
                          duration:duration 
                           options:UIViewAnimationOptionTransitionFlipFromLeft 
                        completion:NULL];
    }
}

- (UIToolbar *)mapToolbar {
    UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 44)] autorelease];
    toolbar.barStyle = UIBarStyleDefault;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if(self.mode == TourOverviewModeStart) {
        UIBarItem *startButton = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStyleBordered target:self action:@selector(startTour)];
        UIBarItem *leftMargin = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        toolbar.items = [NSArray arrayWithObjects:leftMargin, startButton, nil];
    } else if(self.mode == TourOverviewModeContinue) {
        UIBarItem *previousButton = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:nil action:nil];
        UIBarItem *middleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:nil action:nil];
        toolbar.items = [NSArray arrayWithObjects:previousButton, middleSpace, nextButton, nil];
    }
    return toolbar;
}

# pragma TableView dataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tourStopCellIdentifier = @"TourStepCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tourStopCellIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"TourStopCell" owner:self options:nil];
        cell = self.stopCell;
        self.stopCell = nil;
    }
    
    UIImageView *thumbnailView = (UIImageView *)[cell viewWithTag:CellThumbnailViewTag];
    TourStop *stop = [self.tourStops objectAtIndex:indexPath.row];
    thumbnailView.image = [(TourMediaItem *)stop.thumbnail image];
    return cell;    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tourStops.count;
}

# pragma user actions

- (void)startTour {
    TourWalkingPathViewController *walkingPathViewController = [[TourWalkingPathViewController alloc] initWithNibName:@"TourWalkingPathViewController" bundle:nil];
    walkingPathViewController.initialStop = self.selectedStop;
    walkingPathViewController.currentStop = self.selectedStop;
    
    //slide transition;
    CGRect newViewFinalFrame = self.view.frame;
    CGRect newViewInitialFrame = self.view.frame;
    newViewInitialFrame.origin.x = self.view.frame.origin.x + self.view.frame.size.width;
    CGRect oldViewFinalFrame = self.view.frame;
    oldViewFinalFrame.origin.x = self.view.frame.origin.x - self.view.frame.size.width;
    walkingPathViewController.view.frame = newViewInitialFrame;
    [[self.view superview] addSubview:walkingPathViewController.view];
    
    [UIView animateWithDuration:0.25 animations:^(void) {
        walkingPathViewController.view.frame = newViewFinalFrame;
        self.view.frame = oldViewFinalFrame;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview]; 
    }];
}
@end
