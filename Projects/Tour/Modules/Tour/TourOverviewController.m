#import "KGOToolbar.h"
#import "UIKit+KGOAdditions.h"
#import "TourOverviewController.h"
#import "TourMapController.h"
#import "TourDataManager.h"
#import "TourWalkingPathViewController.h"
#import "TourLense.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "TourModule.h"

#define CellThumbnailViewTag 1
#define CellLegendViewTag 2
#define CellStopTitleTag 3
#define CellStopSubtitleTag 4

@interface TourOverviewController (Private)
- (void)showMapAnimated:(BOOL)animated;
- (void)showListAnimated:(BOOL)animated;
- (void)deallocViews;
- (UIToolbar *)mapToolbar;

- (void)startTourAtStop:(TourStop *)stop;
- (void)startTour;
- (void)continueTourAtStop:(TourStop *)stop;
- (void)continueTour;

- (void)previousStop;
- (void)nextStop;

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
@synthesize delegate;

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
    self.delegate = nil;
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

    NSString *title = @"";
    if (self.mode == TourOverviewModeStart) {
        title = @"Pick a Starting Point";
    } else if(self.mode == TourOverviewModeContinue) {
        title = @"Tour Overview";
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(continueTour)] autorelease];
    }
    TourModule *module = 
    (TourModule *)[KGO_SHARED_APP_DELEGATE() moduleForTag:@"home"];
    [module setUpNavBarTitle:title navItem:self.navigationItem];
    
    UISegmentedControl *mapList = 
    [[[UISegmentedControl alloc] 
      initWithItems:[NSArray arrayWithObjects:@"map", @"list", nil]]
     autorelease];
    [mapList addTarget:self action:@selector(mapListToggled:) forControlEvents:UIControlEventValueChanged];
    mapList.segmentedControlStyle = UISegmentedControlStyleBar;
    mapList.selectedSegmentIndex = 0;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:mapList] autorelease];
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
        self.stopsTableView.frame = _contentView.bounds;
        NSTimeInterval duration = animated ? 0.75 : -1;
        [UIView transitionFromView:self.mapContainerView
                            toView:_stopsTableView
                          duration:duration 
                           options:UIViewAnimationOptionTransitionFlipFromLeft 
                        completion:NULL];
    }
}

- (UIToolbar *)mapToolbar {
    UIToolbar *toolbar = [[[KGOToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 44)] autorelease];
    toolbar.barStyle = UIBarStyleDefault;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    if(self.mode == TourOverviewModeStart) {
        UIButton *startButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
        [startButtonView setImage:[UIImage imageWithPathName:@"modules/tour/toolbar-next.png"] forState:UIControlStateNormal];
        startButtonView.frame = CGRectMake(0, 0, 44, 44);        
        UIBarButtonItem *startButton = [[[UIBarButtonItem alloc] initWithCustomView:startButtonView] autorelease];
        [startButtonView addTarget:self action:@selector(startTour) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarItem *leftMargin = 
        [[[UIBarButtonItem alloc] 
          initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
          target:nil action:nil]
         autorelease];
        
        toolbar.items = [NSArray arrayWithObjects:leftMargin, startButton, nil];
    } else if(self.mode == TourOverviewModeContinue) {
        UIButton *previousButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
        [previousButtonView setImage:[UIImage imageWithPathName:@"modules/tour/toolbar-previous.png"] forState:UIControlStateNormal];
        [previousButtonView addTarget:self action:@selector(previousStop) forControlEvents:UIControlEventTouchUpInside];
        previousButtonView.frame = CGRectMake(0, 0, 44, 44);            
        UIBarItem *previousButton = [[[UIBarButtonItem alloc] initWithCustomView:previousButtonView] autorelease];
        
        UIBarItem *middleSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        
        UIButton *nextButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextButtonView setImage:[UIImage imageWithPathName:@"modules/tour/toolbar-next.png"] forState:UIControlStateNormal];
        [nextButtonView addTarget:self action:@selector(nextStop) forControlEvents:UIControlEventTouchUpInside];
        nextButtonView.frame = CGRectMake(0, 0, 44, 44);  
        UIBarItem *nextButton = [[[UIBarButtonItem alloc] initWithCustomView:nextButtonView] autorelease];
        
        toolbar.items = [NSArray arrayWithObjects:previousButton, middleSpace, nextButton, nil];
    }
    return toolbar;
}

#pragma mark - TableView dataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tourStopCellIdentifier = @"TourStepCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tourStopCellIdentifier];
    if(cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"TourStopCell" owner:self options:nil];
        cell = self.stopCell;
        self.stopCell = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    UIImageView *thumbnailView = (UIImageView *)[cell viewWithTag:CellThumbnailViewTag];
    TourStop *stop = [self.tourStops objectAtIndex:indexPath.row];
    thumbnailView.image = [(TourMediaItem *)stop.thumbnail image];
    UILabel *stopTitleLabel = (UILabel *)[cell viewWithTag:CellStopTitleTag];
    stopTitleLabel.text = stop.title;
    UILabel *stopSubtitleLabel = (UILabel *)[cell viewWithTag:CellStopSubtitleTag];
    stopSubtitleLabel.text = stop.subtitle;
    
    UIView *legendView = [cell viewWithTag:CellLegendViewTag];
    [[self class] layoutLensesLegend:legendView forStop:stop withIconSize:10];
    return cell;    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tourStops.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TourStop *stop = [self.tourStops objectAtIndex:indexPath.row];
    if (self.mode == TourOverviewModeStart) {
        [self startTourAtStop:stop];
    } else if (self.mode == TourOverviewModeContinue) {
        [self continueTourAtStop:stop];
    }
}

# pragma mark - class methods used by the map and list controller
+ (void)layoutLensesLegend:(UIView *)legendView forStop:(TourStop *)stop withIconSize:(CGFloat)size {
    [[TourDataManager sharedManager] populateTourStopDetails:stop];
    for(UIView *subviews in legendView.subviews) {
        [subviews removeFromSuperview];
    }
    
    CGFloat rightEdge = legendView.frame.size.width;
    for(TourLense *lense in [[stop orderedLenses] reverseObjectEnumerator]) {
        CGRect iconFrame = CGRectMake(rightEdge-size, 0, size, size);
        UIImageView *iconView = [[[UIImageView alloc] initWithFrame:iconFrame] autorelease];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.image = [UIImage 
                          imageWithPathName:[NSString stringWithFormat:@"modules/tour/lens-%@", lense.lenseType]];
        [legendView addSubview:iconView];
        rightEdge -= size;
    }
}

# pragma mark - user actions
- (void)startTourAtStop:(TourStop *)stop {
    TourWalkingPathViewController *walkingPathViewController = [[TourWalkingPathViewController alloc] initWithNibName:@"TourWalkingPathViewController" bundle:nil];
    walkingPathViewController.initialStop = stop;
    walkingPathViewController.currentStop = stop;
    [self.navigationController pushViewController:walkingPathViewController animated:YES]; 
    [walkingPathViewController release];
}

- (void)startTour {
    [self startTourAtStop:self.tourMapController.selectedStop];
}

- (void)continueTourAtStop:(TourStop *)stop {
    [self.delegate tourOverview:self stopWasSelected:stop];
}

- (void)continueTour {
    [self continueTourAtStop:self.tourMapController.selectedStop];
}

- (void)nextStop {
    TourStop *nextStop = [[TourDataManager sharedManager] nextStopForTourStop:self.tourMapController.selectedStop];
    self.tourMapController.selectedStop = nextStop;
}

- (void)previousStop {
    TourStop *previousStop = [[TourDataManager sharedManager] previousStopForTourStop:self.tourMapController.selectedStop];
    self.tourMapController.selectedStop = previousStop;
}


@end
