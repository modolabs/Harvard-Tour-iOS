#import "TourWelcomeBackViewController.h"
#import "TourHomeViewController.h"
#import "TourWalkingPathViewController.h"
#import "TourDataManager.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "TourModule.h"

@implementation TourWelcomeBackViewController

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
    // TourModule's module tag in the config and app delegate is "home".
    TourModule *module = 
    (TourModule *)[KGO_SHARED_APP_DELEGATE() moduleForTag:@"home"];
    [module setUpNavigationBar:self.navigationController.navigationBar];
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

- (IBAction)startOver {
    UIViewController *vc = [[[TourHomeViewController alloc] initWithNibName:@"TourHomeViewController" bundle:nil] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)resumeTour {
    TourWalkingPathViewController *walkingPathVC = [[[TourWalkingPathViewController alloc] initWithNibName:@"TourWalkingPathViewController" bundle:nil] autorelease];
    walkingPathVC.initialStop = [[TourDataManager sharedManager] getInitialStop];
    walkingPathVC.currentStop = [[TourDataManager sharedManager] getCurrentStop];
    [self.navigationController pushViewController:walkingPathVC animated:YES];
}
@end
