#import "TourStopDetailsViewController.h"
#import "KGOTabbedControl.h"
#import "UIKit+KGOAdditions.h"
#import "TourDataManager.h"
#import "TourLense.h"
#import "TourLenseItem.h"
#import "TourLensePhotoItem.h"
#import "TourLenseHtmlItem.h"

#define LenseItemPhotoImageTag 100
#define LenseItemPhotoCaptionTag 101

@interface TourStopDetailsViewController (Private)

- (void)deallocViews;
- (void)setupLenseTabs;
- (void)displayLenseContent;

@end

@implementation TourStopDetailsViewController
@synthesize tabControl;
@synthesize tourStop;

@synthesize scollView;
@synthesize lenseContentView;
@synthesize lenseItemPhotoView;

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
    [self displayLenseContent];
    
    //[self.tabControl setMinimumWidth:mininumTabWidth forTabAtIndex:3];
    // Do any additional setup after loading the view from its nib.
}

- (void)deallocViews {
    self.tabControl = nil;
    self.lenseContentView = nil;
    self.scollView = nil;
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

- (void)displayLenseContent {
    CGFloat lenseContentHeight = 0;
    // remove old content
    for(UIView *subview in self.lenseContentView.subviews) {
        [subview removeFromSuperview];
    }
    
    TourLense *aLense = [self.tourStop.lenses anyObject];
    for (TourLenseItem *lenseItem in [aLense orderedItems]) {
        if([lenseItem isKindOfClass:[TourLenseHtmlItem class]]) {
            TourLenseHtmlItem *lenseHtmlItem = (TourLenseHtmlItem *)lenseItem;
            CGRect webviewFrame = CGRectMake(0, lenseContentHeight, self.lenseContentView.frame.size.width, 250);
            lenseContentHeight += 250;
            UIWebView *webView = [[[UIWebView alloc] initWithFrame:webviewFrame] autorelease];
            [webView loadHTMLString:lenseHtmlItem.html baseURL:nil];
            [self.lenseContentView addSubview:webView];
        }
        else if([lenseItem isKindOfClass:[TourLensePhotoItem class]]) {
            TourLensePhotoItem *lensePhotoItem = (TourLensePhotoItem *)lenseItem;
            [[NSBundle mainBundle] loadNibNamed:@"TourLensePhotoView" owner:self options:nil];
            UIView *photoView = self.lenseItemPhotoView;
            CGRect photoViewFrame = photoView.frame;
            photoViewFrame.origin.y = lenseContentHeight;
            photoView.frame = photoViewFrame;
            lenseContentHeight += photoView.frame.size.height;
            
            UIImageView *imageView = (UIImageView *)[photoView viewWithTag:LenseItemPhotoImageTag];
            imageView.image = [lensePhotoItem.photo image];
            UILabel *captionLabel = (UILabel *)[photoView viewWithTag:LenseItemPhotoCaptionTag];
            captionLabel.text = lensePhotoItem.title;
            
            [self.lenseContentView addSubview:photoView];
            self.lenseItemPhotoView = nil;
        }
    }
    
    CGRect contentViewFrame = self.lenseContentView.frame;
    contentViewFrame.size.height = lenseContentHeight;
    self.lenseContentView.frame = contentViewFrame;
    self.scollView.contentSize = CGSizeMake(
        self.scollView.frame.size.width,
        self.lenseContentView.frame.origin.y + lenseContentHeight);
}
@end
