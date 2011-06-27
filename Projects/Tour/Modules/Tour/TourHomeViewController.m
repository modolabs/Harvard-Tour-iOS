#import "TourHomeViewController.h"
#import "TourOverviewController.h"
#import "TourDataManager.h"
#import "UIKit+KGOAdditions.h"
#import "KGOAppDelegate+ModuleAdditions.h"
#import "TourModule.h"

@implementation TourHomeViewController
@synthesize scrollView;


#pragma mark Actions

- (IBAction)startTour:(id)sender {
    [_tourOverviewController release];
    _tourOverviewController = [[TourOverviewController alloc] initWithNibName:@"TourOverviewController" bundle:nil];
    _tourOverviewController.selectedStop = [[TourDataManager sharedManager] getFirstStop];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:_tourOverviewController animated:YES];
}

#pragma mark NSObject

#pragma mark NSObject
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
                title:(NSString *)title {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Don't need to do anything with the nav bar title, unlike other 
        // children of HTMLTemplateBasedViewController.
    }
    return self;        
}


- (void)dealloc {
    [scrollView release];
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[TourDataManager sharedManager] markAllStopsUnvisited];
    self.view.backgroundColor = 
    [UIColor colorWithPatternImage:
     [UIImage imageWithPathName:@"modules/tour/welcome-background.jpg"]];
    
    TourModule *module = 
    (TourModule *)[KGO_SHARED_APP_DELEGATE() moduleForTag:@"home"];
    [module setUpNavigationBar:self.navigationController.navigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark HTMLTemplateBasedViewController
// The template file under resources/modules/tour.
- (NSString *)templateFilename {
    return @"home_template.html";
}

// Keys: Stubs to replace in the template. Values: Strings to replace them.
- (NSDictionary *)replacementsForStubs {
    NSDictionary *replacementsDict = nil;
    NSArray *welcomeTextArray = 
    [[TourDataManager sharedManager] retrieveWelcomeText];
    if ((welcomeTextArray.count > 2) && 
        [[welcomeTextArray objectAtIndex:1] isKindOfClass:[NSArray class]]) {
        
        replacementsDict = 
        [NSDictionary dictionaryWithObjectsAndKeys:
         [welcomeTextArray objectAtIndex:0], @"__WELCOME_TEXT",
         [[super class] htmlForTopicSection:[welcomeTextArray objectAtIndex:1]], 
         @"__TOPICS__",
         [welcomeTextArray objectAtIndex:2], @"__DISCLAIMER__",
         nil];
    }
    return replacementsDict;
}

- (void)setUpWebViewLayout {
    [super setUpWebViewLayout];

    // resize the scrollview and webView from the defaults in the Nib file
    self.scrollView.contentSize = 
    CGSizeMake(self.scrollView.frame.size.width, 
               self.scrollView.frame.size.height + 200);
    
    self.webView.frame = CGRectMake(self.webView.frame.origin.x, 
                                    self.webView.frame.origin.y, 
                                    self.view.frame.size.width, 
                                    self.webView.frame.size.height+100);
    // this is critical to ensure there is no conflict between UIWebView and 
    // UIScrollView scrolling
    self.webView.userInteractionEnabled = NO;     
    self.webView.backgroundColor = [UIColor clearColor];
}

@end
