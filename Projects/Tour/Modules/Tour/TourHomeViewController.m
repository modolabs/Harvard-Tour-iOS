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

- (void) setupWebViewLayout {
    
    NSString * htmlString;
    
    // optional CSS
    NSString * htmlHead = @"<html><head><style type=\"text/css\">img.middle {vertical-align:middle;}</style></head>";
    
    //font for WelcomeText in HTML
    NSString * htmlWelcomeString = @"<body><font size=\"2\" type=\"helvetica\">";
    
    htmlString = [htmlHead stringByAppendingString:htmlWelcomeString];
    
    NSArray *welcomeTextArray = [[TourDataManager sharedManager] retrieveWelcomeText];
    
    welcomeText = [welcomeTextArray objectAtIndex:0]; // first string (welcome)s
    htmlString = [htmlString stringByAppendingString:welcomeText];
    htmlString = [htmlString stringByAppendingString:@"</font>"];
    
    if ([welcomeTextArray count] > 1) {
        
        if ([[welcomeTextArray objectAtIndex:1] isKindOfClass:[NSArray class]]) {
            NSArray * topics = [welcomeTextArray objectAtIndex:1];
            
            NSString * dlString = @"<dl>";
            for (int count=0; count < [topics count]; count++) {
                NSDictionary * topicDict = [topics objectAtIndex:count];
                
                NSString * topicId = [topicDict objectForKey:@"id"];
                NSString * topicText = [topicDict objectForKey:@"name"];
                NSString * topicTextDetails = [topicDict objectForKey:@"description"];
                
                // <Image> [Lens-Name]: [Lens-Description] in HTML
                NSString * formatString = [NSString stringWithFormat:@"<dt><img class=\"middle\" src=\"modules/tour/lens-%@.png\" alt=\"topicText\" width=\"34\" height=\"34\" /><b>%@:</b><font size=\"2\" >%@</font></dt>", topicId, topicText, topicTextDetails];
                
                dlString = [dlString stringByAppendingString:formatString];
                
            }
            
            // end of <dl> and also font for Disclaimer Text
            dlString = [dlString stringByAppendingString:@"</dl><font size=\"2\" type=\"helvetica\">"];
            htmlString = [htmlString stringByAppendingString:dlString];
        }
    }
    
    if ([welcomeTextArray count] > 2) {
        
        // Disclaimer Text in HTML
        if ([[welcomeTextArray objectAtIndex:2] isKindOfClass:[NSString class]])
            welcomeDisclaimerText = [welcomeTextArray objectAtIndex:2];
        
        htmlString = [htmlString stringByAppendingString:welcomeDisclaimerText];
    }
    
    // close <font> and <html> tags
    htmlString = [htmlString stringByAppendingString:@"</font></html>"];
   
    // resize the scrollview and webView from the defaults in the Nib file
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 100);
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
