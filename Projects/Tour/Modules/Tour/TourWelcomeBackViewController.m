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

    NSURL *baseURL = 
    [NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath] isDirectory:YES];
    baseURL = [baseURL URLByAppendingPathComponent:@"modules/tour"];
    NSURL *fileURL = 
    [NSURL URLWithString:@"welcome_template.html" relativeToURL:baseURL];
    NSError *error = nil;    
    NSString *htmlString = 
    [NSString 
     stringWithContentsOfURL:fileURL 
     encoding:NSUTF8StringEncoding error:&error];
    
//    NSString * htmlInfoAboutStops = @"<p><font size=\"2\" type=\"helvetica\" />Each stop on the tour includes information on one or more of the following topics:</font></p>";    
//    htmlString = [htmlString stringByAppendingString:htmlInfoAboutStops];
    
    NSArray * welcomeTextArray =  [[TourDataManager sharedManager] retrieveWelcomeText];
    
    NSString *welcomeText = [welcomeTextArray objectAtIndex:0]; // first string (welcome)s
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
            
            // end of <dl> and also </body> and </html>
            dlString = [dlString stringByAppendingString:@"</dl></body></html>"];
            htmlString = [htmlString stringByAppendingString:dlString];
        }
    }
    
    // close <font> and <html> tags
    htmlString = [htmlString stringByAppendingString:@"</font></html>"];
    
    [self.webView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] resourceURL]];
    
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
