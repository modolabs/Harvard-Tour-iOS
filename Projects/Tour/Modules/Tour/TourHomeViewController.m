#import "TourHomeViewController.h"
#import "TourOverviewController.h"
#import "TourDataManager.h"
#import "UIKit+KGOAdditions.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "TourModule.h"

@implementation TourHomeViewController
@synthesize scrollView;
@synthesize webView;

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

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithPathName:@"modules/tour/welcome-background.jpg"]];
    
    // TourModule's module tag in the config and app delegate is "home".    
    TourModule *module = 
    (TourModule *)[KGO_SHARED_APP_DELEGATE() moduleForTag:@"home"];
    [module setUpNavigationBar:self.navigationController.navigationBar];
    
    [self setupWebViewLayout];
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

- (void)setupWebViewLayout {
    NSString *htmlString = @"";
    
    NSArray *welcomeTextArray = 
    [[TourDataManager sharedManager] retrieveWelcomeText];
    
    if ((welcomeTextArray.count > 1) && 
        [[welcomeTextArray objectAtIndex:1] isKindOfClass:[NSArray class]]) {
        htmlString = [TourModule 
                      htmlForPageTemplateFileName:@"home_template.html" 
                      welcomeText:[welcomeTextArray objectAtIndex:0] 
                      topicDictionaries:[welcomeTextArray objectAtIndex:1]];
    }
    
    if ([welcomeTextArray count] > 2) {        
        // Disclaimer Text in HTML
        if ([[welcomeTextArray objectAtIndex:2] isKindOfClass:[NSString class]]) {
            welcomeDisclaimerText = [welcomeTextArray objectAtIndex:2];
            htmlString = 
            [htmlString 
             stringByReplacingOccurrencesOfString:@"__DISCLAIMER__" 
             withString:welcomeDisclaimerText];
        }
    }
   
    // resize the scrollview and webView from the defaults in the Nib file
    self.scrollView.contentSize = 
    CGSizeMake(self.scrollView.frame.size.width, 
               self.scrollView.frame.size.height + 200);
    self.webView.frame = CGRectMake(self.webView.frame.origin.x, 
                                    self.webView.frame.origin.y, 
                                    self.view.frame.size.width, 
                                    self.webView.frame.size.height+100);

    // this is critical to ensure there is no conflict between UIWebView and UIScrollView scrolling
    self.webView.userInteractionEnabled = NO; 
    
    self.webView.backgroundColor = [UIColor clearColor];
    [self.webView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] resourceURL]];
}
@end
