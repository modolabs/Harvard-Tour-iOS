#import "KGOToolbar.h"
#import "KGOSegmentedControl.h"
#import "UIKit+KGOAdditions.h"
#import "AnalyticsWrapper.h"
#import "TourOverviewController.h"
#import "TourMapController.h"
#import "TourDataManager.h"
#import "TourWalkingPathViewController.h"
#import "TourLense.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "TourModule.h"

#define CellThumbnailViewTag 1
#define CellStopTitleTag 3
#define CellStopSubtitleTag 4
#define CellStopStatusImageTag 5

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
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
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
        self.navigationItem.leftBarButtonItem =
        [TourModule 
         customToolbarButtonWithImageNamed:@"modules/tour/navbar-back" 
         pressedImageNamed:@"modules/tour/navbar-back-pressed" 
         target:self action:@selector(backButtonTapped:)];        
    } else if(self.mode == TourOverviewModeContinue) {
        title = @"Tour Overview";
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(continueTour)] autorelease];
    }
    TourModule *module = 
    (TourModule *)[KGO_SHARED_APP_DELEGATE() moduleForTag:@"home"];
    [module setUpNavBarTitle:title navItem:self.navigationItem];
    
    KGOSegmentedControl *mapListControl = [[[KGOSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 76, 30)] autorelease];
    mapListControl.tabFont = [UIFont boldSystemFontOfSize:12];
    mapListControl.tabPadding = 4;
    [mapListControl insertSegmentWithTitle:@"map" atIndex:0 animated:NO];
    [mapListControl insertSegmentWithTitle:@"list" atIndex:1 animated:NO];


    mapListControl.selectedSegmentIndex = 0;
    mapListControl.delegate = self;
    
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:mapListControl] autorelease];
    
    [pool release];
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

- (void)tabbedControl:(KGOTabbedControl *)contol didSwitchToTabAtIndex:(NSInteger)index {
    if(index == 0) {
        [self showMapAnimated:YES];
    } else if(index == 1) {
        [self showListAnimated:YES];
    }
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
        
        UIButton *labelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        labelButton.frame = CGRectMake(0, 0, 64, 44);
        [labelButton setTitle:@"Start Here" forState:UIControlStateNormal];
        [labelButton setTitle:@"Start Here" forState:UIControlStateHighlighted];
        labelButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        labelButton.titleLabel.shadowColor = 
        [UIColor colorWithWhite:0.0f alpha:0.6f];
        labelButton.titleLabel.shadowOffset = CGSizeMake(0, 1.0f);
        [labelButton addTarget:self action:@selector(startTour) 
              forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *labelButtonItem = 
        [[[UIBarButtonItem alloc] initWithCustomView:labelButton] autorelease];
        
        UIBarItem *leftMargin = 
        [[[UIBarButtonItem alloc] 
          initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
          target:nil action:nil]
         autorelease];
        
        toolbar.items = [NSArray arrayWithObjects:leftMargin, labelButtonItem, 
                         startButton, nil];
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
    
    if(self.mode == TourOverviewModeContinue) {
        UIImageView *statusImageView = (UIImageView *)[cell viewWithTag:CellStopStatusImageTag];
        if (stop == self.selectedStop) {
            statusImageView.image = [UIImage imageWithPathName:@"modules/tour/map-pin-current"];
        } else if([stop.visited boolValue]) {
            statusImageView.image = [UIImage imageWithPathName:@"modules/tour/map-pin-past"];
        } else {
            statusImageView.image = nil;
        }
    }
    
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
    [[AnalyticsWrapper sharedWrapper] trackEvent:@"Select Starting Point" action:@"Start Tour" label:stop.title];
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
