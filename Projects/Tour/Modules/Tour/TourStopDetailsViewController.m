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
- (void)displayContentForTabIndex:(NSInteger)tabIndex;
- (void)displayLenseContent:(TourLense *)lense;

@end

@implementation TourStopDetailsViewController
@synthesize tabControl;
@synthesize tourStop;

@synthesize scrollView;
@synthesize lenseContentView;
@synthesize webView;
@synthesize html;
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
    self.tabControl.selectedTabIndex = 0;
    [self displayContentForTabIndex:0];
    self.tabControl.delegate = self;
    
    //[self.tabControl setMinimumWidth:mininumTabWidth forTabAtIndex:3];
    // Do any additional setup after loading the view from its nib.
}

- (void)deallocViews {
    self.tabControl.delegate = nil;
    self.tabControl = nil;
    self.lenseContentView = nil;
    self.scrollView = nil;
    self.webView.delegate = nil;
    self.webView = nil;
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
    for (NSInteger tabIndex = 0; tabIndex < [[self.tourStop orderedLenses] count]; tabIndex++) {
        [self.tabControl insertTabWithImage:[UIImage imageWithPathName:@"modules/map/map-button-location"] atIndex:0 animated:NO];
    }
    
    for (NSInteger tabIndex = 0; tabIndex < [[self.tourStop orderedLenses] count]; tabIndex++) {
        [self.tabControl setMinimumWidth:mininumTabWidth forTabAtIndex:tabIndex];
    }
}

- (void)tabbedControl:(KGOTabbedControl *)control didSwitchToTabAtIndex:(NSInteger)index {
    [self displayContentForTabIndex:index];
}

- (void)displayContentForTabIndex:(NSInteger)tabIndex {
    TourLense *lense = [[self.tourStop orderedLenses] objectAtIndex:tabIndex];
    [self displayLenseContent:lense];
}

- (void)displayLenseContent:(TourLense *)aLense; {
    CGFloat lenseContentHeight = 0;
    // remove old content
    self.webView.delegate = nil;
    self.webView = nil;
    self.html = @"";
    for(UIView *subview in self.lenseContentView.subviews) {
        [subview removeFromSuperview];
    }
    
    for (TourLenseItem *lenseItem in [aLense orderedItems]) {
        if([lenseItem isKindOfClass:[TourLenseHtmlItem class]]) {
            TourLenseHtmlItem *lenseHtmlItem = (TourLenseHtmlItem *)lenseItem;
            self.html = [self.html stringByAppendingString:lenseHtmlItem.html];
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
    
    if([self.html length]) {
        CGFloat dummyInitialHeight = 200;
        CGRect webviewFrame = CGRectMake(0, lenseContentHeight, self.lenseContentView.frame.size.width, dummyInitialHeight);
        lenseContentHeight += dummyInitialHeight;
        self.webView = [[[UIWebView alloc] initWithFrame:webviewFrame] autorelease];
        self.webView.delegate = self;
        [self.webView loadHTMLString:self.html baseURL:nil];
        [self.lenseContentView addSubview:self.webView]; 
    }
    
    
    CGRect contentViewFrame = self.lenseContentView.frame;
    contentViewFrame.size.height = lenseContentHeight;
    self.lenseContentView.frame = contentViewFrame;
    self.scrollView.contentSize = CGSizeMake(
        self.scrollView.frame.size.width,
        self.lenseContentView.frame.origin.y + lenseContentHeight);
}

#pragma mark UIWebView delegate
- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    if(aWebView.superview) {
        CGSize size = [aWebView sizeThatFits:CGSizeZero];
        CGRect frame = aWebView.frame;
        CGFloat addedHeight = size.height - frame.size.height;
        frame.size.height = size.height;
        aWebView.frame = frame;
    
        // change scrollview height by how much the webview height changed
        CGSize contentSize = self.scrollView.contentSize;
        contentSize.height = contentSize.height + addedHeight;
        self.scrollView.contentSize = contentSize;
        
        // change lense content view height
        CGRect contentFrame = self.lenseContentView.frame;
        contentFrame.size.height = contentFrame.size.height + addedHeight;
        self.lenseContentView.frame = contentFrame;
    }
}

@end
