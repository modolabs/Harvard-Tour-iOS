#import "TourWalkingPathViewController.h"
#import "TourStopDetailsViewController.h"
#import "TourMapController.h"
#import "TourDataManager.h"

@interface TourWalkingPathViewController (Private)
- (void)deallocViews;
- (void)refreshUI;
- (void)loadMapControllerForCurrentStop;
- (void)loadStopDetailsControllerForCurrentStop;

- (CGRect)frameForContent;
- (CGRect)frameForPreviousContent;
- (CGRect)frameForNextContent;
@end

@implementation TourWalkingPathViewController
@synthesize contentView;
@synthesize currentContent;
@synthesize titleButton;
@synthesize previousBarItem;
@synthesize nextBarItem;
@synthesize initialStop;
@synthesize currentStop;
@synthesize tourStopMode;

@synthesize tourMapController;
@synthesize tourStopDetailsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [self deallocViews];
    self.currentStop = nil;
    self.initialStop = nil;
    self.tourMapController = nil;
    self.tourStopDetailsController = nil;
    self.contentView = nil;
    self.currentContent = nil;
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
    [self refreshUI];
    [self loadMapControllerForCurrentStop];
    self.tourMapController.view.frame = [self frameForContent];
    [self.contentView addSubview:self.tourMapController.view];
    self.currentContent = self.tourMapController.view;
    // Do any additional setup after loading the view from its nib.
}

- (void)deallocViews {
    self.previousBarItem = nil;
    self.nextBarItem = nil;
    self.titleButton = nil;
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

- (void)refreshUI {
    NSString *titleText;
    if (self.tourStopMode == TourStopModeApproach) {
        titleText = [NSString stringWithFormat:@"Walk to %@", self.currentStop.title];
        self.nextBarItem.enabled = YES;
        self.previousBarItem.enabled = (self.currentStop != self.initialStop);
    }
    else if(self.tourStopMode == TourStopModeLenses) {
        titleText = self.currentStop.title;
        self.previousBarItem.enabled = YES;
        TourStop *lastStop = [[TourDataManager sharedManager] lastTourStopForFirstTourStop:self.initialStop];
        self.nextBarItem.enabled = (self.currentStop != lastStop);
    }
    [self.titleButton setTitle:titleText forState:UIControlStateNormal];
}

- (IBAction)previous {
    UIView *previousView;
    if (self.tourStopMode == TourStopModeLenses) {
        self.tourStopMode = TourStopModeApproach;
        [self loadMapControllerForCurrentStop];
        previousView = self.tourMapController.view;
    }
    else if(self.tourStopMode == TourStopModeApproach) {
        self.tourStopMode = TourStopModeLenses;
        self.currentStop = [[TourDataManager sharedManager] previousStopForTourStop:self.currentStop];
        [self loadStopDetailsControllerForCurrentStop];
        previousView = self.tourStopDetailsController.view;
    }
    previousView.frame = [self frameForPreviousContent];
    [self.contentView addSubview:previousView];
    
    [UIView animateWithDuration:0.75 animations:^(void) {
        previousView.frame = [self frameForContent];
        self.currentContent.frame = [self frameForNextContent];
    } completion:^(BOOL finished) {
        [self.currentContent removeFromSuperview];
        self.currentContent = previousView;
        [self refreshUI];
    }];
}

- (IBAction)next {
    UIView *nextView;
    if (self.tourStopMode == TourStopModeApproach) {
        self.tourStopMode = TourStopModeLenses;
        [self loadStopDetailsControllerForCurrentStop];
        nextView = self.tourStopDetailsController.view;
    }
    else if(self.tourStopMode == TourStopModeLenses) {
        self.tourStopMode = TourStopModeApproach;
        self.currentStop = [[TourDataManager sharedManager] nextStopForTourStop:self.currentStop];
        [self loadMapControllerForCurrentStop];
        nextView = self.tourMapController.view;
    }
    nextView.frame = [self frameForNextContent];
    [self.contentView addSubview:nextView];
    [UIView animateWithDuration:0.75 animations:^(void) {
        nextView.frame = [self frameForContent];
        self.currentContent.frame = [self frameForPreviousContent];
    } completion:^(BOOL finished) {
        [self.currentContent removeFromSuperview];
        self.currentContent = nextView;
        [self refreshUI];
    }];
}

- (void)loadMapControllerForCurrentStop {
    self.tourMapController = [[[TourMapController alloc] initWithNibName:@"TourMapController" bundle:nil] autorelease];
    self.tourMapController.upcomingStop = self.currentStop;
    self.tourMapController.selectedStop = self.currentStop;
    self.tourMapController.mapInitialFocusMode = MapInitialFocusModeUpcomingStop;
}

- (void)loadStopDetailsControllerForCurrentStop {
    self.tourStopDetailsController = [[[TourStopDetailsViewController alloc] initWithNibName:@"TourStopDetailsViewController" bundle:nil] autorelease];
}

- (CGRect)frameForContent {
    return self.contentView.bounds;
}

- (CGRect)frameForNextContent {
    CGRect nextContentFrame = self.contentView.bounds;
    nextContentFrame.origin.x += self.contentView.bounds.size.width;
    return nextContentFrame;
}

- (CGRect)frameForPreviousContent {
    CGRect previousContentFrame = self.contentView.bounds;
    previousContentFrame.origin.x -= self.contentView.bounds.size.width;
    return previousContentFrame;
}

@end
