#import "TourHomeViewController.h"
#import "TourOverviewController.h"
#import "TourDataManager.h"
#import "UIKit+KGOAdditions.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "TourModule.h"

@implementation TourHomeViewController
@synthesize scrollView;

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
    self.scrollView = nil;
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
    // Do any additional setup after loading the view from its nib.
    [[TourDataManager sharedManager] markAllStopsUnvisited];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 25);
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithPathName:@"modules/tour/welcome-background.jpg"]];
    
    // TourModule's module tag in the config and app delegate is "home".    
    TourModule *module = 
    (TourModule *)[KGO_SHARED_APP_DELEGATE() moduleForTag:@"home"];
    [module setUpNavigationBar:self.navigationController.navigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.scrollView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)startTour:(id)sender {
    [_tourOverviewController release];
    _tourOverviewController = [[TourOverviewController alloc] initWithNibName:@"TourOverviewController" bundle:nil];
    _tourOverviewController.selectedStop = [[TourDataManager sharedManager] getFirstStop];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:_tourOverviewController animated:YES];
}
@end
