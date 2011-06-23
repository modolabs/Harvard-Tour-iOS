#import "TourWelcomeBackViewController.h"
#import "TourHomeViewController.h"
#import "TourWalkingPathViewController.h"
#import "TourDataManager.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "TourModule.h"

@implementation TourWelcomeBackViewController

@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        TourModule *module = 
        (TourModule *)[KGO_SHARED_APP_DELEGATE() moduleForTag:@"home"];        
        [module setUpNavBarTitle:@"Harvard Yard Tour" navItem:self.navigationItem];        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [self.webView dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)setupWebViewLayout {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
    NSArray *welcomeTextArray = 
    [[TourDataManager sharedManager] retrieveWelcomeText];
    if ((welcomeTextArray.count > 1) && 
        [[welcomeTextArray objectAtIndex:1] isKindOfClass:[NSArray class]]) {
        
        NSString *htmlString = 
        [TourModule 
         htmlForPageTemplateFileName:@"welcome_template.html" 
         welcomeText:[welcomeTextArray objectAtIndex:0] 
         topicDictionaries:[welcomeTextArray objectAtIndex:1]];
        [self.webView 
         loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] resourceURL]];
    }
    [pool release];
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
    
    [self setupWebViewLayout];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    //[self.navigationController setNavigationBarHidden:YES];
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
