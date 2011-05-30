#import "TourStopDetailsViewController.h"
#import "KGOTabbedControl.h"
#import "UIKit+KGOAdditions.h"
#import "TourDataManager.h"

@interface TourStopDetailsViewController (Private)

- (void)deallocViews;
- (void)setupLenseTabs;

@end

@implementation TourStopDetailsViewController
@synthesize tabControl;
@synthesize tourStop;

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
    self.tourStop = nil;
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
    [[TourDataManager sharedManager] populateTourStopDetails:self.tourStop];
    [self setupLenseTabs];
    
    //[self.tabControl setMinimumWidth:mininumTabWidth forTabAtIndex:3];
    // Do any additional setup after loading the view from its nib.
}

- (void)deallocViews {
    self.tabControl = nil;
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

- (void)setupLenseTabs {
    self.tabControl.tabPadding = 1.0;
    self.tabControl.tabSpacing = 0.0;
    NSInteger totalTabs = 5;
    CGFloat mininumTabWidth = self.tabControl.frame.size.width / totalTabs;
    
    [self.tabControl insertTabWithImage:[UIImage imageWithPathName:@"modules/map/map-button-location"] atIndex:0 animated:NO];
    [self.tabControl insertTabWithImage:[UIImage imageWithPathName:@"modules/map/map-button-location"] atIndex:0 animated:NO];
    [self.tabControl insertTabWithImage:[UIImage imageWithPathName:@"modules/map/map-button-location"] atIndex:0 animated:NO];
    [self.tabControl insertTabWithImage:[UIImage imageWithPathName:@"modules/map/map-button-location"] atIndex:0 animated:NO];
    
    [self.tabControl setMinimumWidth:mininumTabWidth forTabAtIndex:0];
    [self.tabControl setMinimumWidth:mininumTabWidth forTabAtIndex:1];
    [self.tabControl setMinimumWidth:mininumTabWidth forTabAtIndex:2];
    [self.tabControl setMinimumWidth:mininumTabWidth forTabAtIndex:3];
}
@end
