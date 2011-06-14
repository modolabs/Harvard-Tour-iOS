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
    
    [self assignTexts];

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

- (void) assignTexts {
    
    if ((nil == welcomeText) || 
        (nil == topicText1) || (nil == topicTextDetails1) ||
        (nil == topicLabel2) || (nil == topicLabelDetails2) ||
        (nil == topicLabel3) || (nil == topicLabelDetails3) ||
        (nil == topicLabel4) || (nil == topicLabelDetails4)) {
        NSArray * welcomeTextArray =  [[TourDataManager sharedManager] retrieveWelcomeText];
        
        welcomeText = [TourDataManager stripHTMLTagsFromString:
                       [welcomeTextArray objectAtIndex:0]]; // first string
        
        if ([welcomeTextArray count] > 1) {
            
            if ([[welcomeTextArray objectAtIndex:1] isKindOfClass:[NSArray class]]) {
                NSArray * topics = [welcomeTextArray objectAtIndex:1];
                
                for (int count=0; count < [topics count]; count++) {
                    NSDictionary * topicDict = [topics objectAtIndex:count];
                    
                    if (count == 0){
                        topicText1 = [TourDataManager stripHTMLTagsFromString:
                                      [topicDict objectForKey:@"name"]];
                        topicTextDetails1 = 
                        [TourDataManager stripHTMLTagsFromString:
                         [topicDict objectForKey:@"description"]];
                    }
                    
                    else if (count == 1){
                        topicText2 = 
                        [TourDataManager stripHTMLTagsFromString:
                         [topicDict objectForKey:@"name"]];
                        topicTextDetails2 = 
                        [TourDataManager stripHTMLTagsFromString:
                         [topicDict objectForKey:@"description"]];
                    }
                    
                    else if (count == 2){
                        topicText3 = 
                        [TourDataManager stripHTMLTagsFromString:
                         [topicDict objectForKey:@"name"]];
                        topicTextDetails3 = 
                        [TourDataManager stripHTMLTagsFromString:
                         [topicDict objectForKey:@"description"]];
                    }
                    
                    else if (count == 3){
                        topicText4 = 
                        [TourDataManager 
                         stripHTMLTagsFromString:
                         [topicDict objectForKey:@"name"]];
                        topicTextDetails4 = 
                        [TourDataManager 
                         stripHTMLTagsFromString:
                         [topicDict objectForKey:@"description"]];
                    }
                }
                
            }
        }
            
        if ([welcomeTextArray count] > 2) {
            
            if ([[welcomeTextArray objectAtIndex:2] isKindOfClass:[NSString class]])
                welcomeDisclaimerText = 
                [TourDataManager stripHTMLTagsFromString:
                 [welcomeTextArray objectAtIndex:2]];
        }
        
    }
    
    welcomeTextLabel.text = welcomeText;
    welcomeDisclaimerTextLabel.text = welcomeDisclaimerText;
    
    topicLabel1.text = topicText1;
    topicLabel2.text = topicText2;
    topicLabel3.text = topicText3;
    topicLabel4.text = topicText4;
    
    topicLabelDetails1.text = topicTextDetails1;
    topicLabelDetails2.text = topicTextDetails2;
    topicLabelDetails3.text = topicTextDetails3;
    topicLabelDetails4.text = topicTextDetails4;
    
}


@end
