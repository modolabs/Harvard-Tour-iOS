#import "AnalyticsWrapper.h"
#import "TourStopDetailsViewController.h"
#import "KGOTabbedControl.h"
#import "UIKit+KGOAdditions.h"
#import "TourDataManager.h"
#import "TourLense.h"
#import "TourLenseItem.h"
#import "TourLensePhotoItem.h"
#import "TourLenseVideoItem.h"
#import "TourLenseSlideShowItem.h"
#import "TourSlide.h"
#import "TourLenseHtmlItem.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HTMLTemplateBasedViewController.h"

#define LenseItemPhotoImageTag 100
#define LenseItemPhotoCaptionTag 101
#define LenseItemVideoViewContainer 200
#define LenseItemVideoCaptionTag 201
#define LenseItemSlideShowScrollViewTag 300
#define LenseItemSlideShowPageControlTag 301

@interface TourStopDetailsViewController (Private)

- (void)deallocViews;
- (void)setupLenseTabs;
- (void)displayContentForTabIndex:(NSInteger)tabIndex;
- (void)displayLenseContent:(TourLense *)lense;
- (void)loadSlideAtIndex:(NSInteger)slideIndex;
- (void)pageChanged;

@end

@implementation TourStopDetailsViewController
@synthesize tabControl;
@synthesize tourStop;

@synthesize scrollView;
@synthesize lenseContentView;
@synthesize webView;
@synthesize html;
@synthesize lenseItemPhotoView;
@synthesize lenseItemVideoView;
@synthesize lenseItemSlideShowView;
@synthesize slideShowScrollView;
@synthesize slides;
@synthesize slidesPageControl;
@synthesize displayedPageIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        moviePlayers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.tourStop = nil;
    self.slides = nil;
    [moviePlayers release];
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
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)deallocViews {
    self.tabControl.delegate = nil;
    self.tabControl = nil;
    self.lenseContentView = nil;
    self.scrollView = nil;
    self.webView.delegate = nil;
    self.webView = nil;
    self.slideShowScrollView.delegate = nil;
    self.slideShowScrollView = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self deallocViews];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)stopAllPlayers {
    for (MPMoviePlayerController *player in moviePlayers) {
        [player stop];
    }
}
// Call this before hiding this controller's view.
- (void)cleanUpBeforeDisappearing {
    [self stopAllPlayers];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setupLenseTabs {
    UIView *background = 
    [[UIImageView alloc] 
     initWithImage:[UIImage imageNamed:@"modules/tour/tabs-background.png"]];
    [self.tabControl addSubview:background];
    [self.tabControl sendSubviewToBack:background];
    [background release];    
    
    self.tabControl.tabSpacing = 0.0;
    NSInteger totalTabs = 5;
    CGFloat mininumTabWidth = self.tabControl.frame.size.width / totalTabs;
    NSArray *orderedLenses = [self.tourStop orderedLenses];
    for (NSInteger tabIndex = 0; tabIndex < [orderedLenses count]; tabIndex++) {
        NSString *lenseType = [[orderedLenses objectAtIndex:tabIndex] lenseType];
        UIImage *lenseImage = [UIImage imageWithPathName:[NSString stringWithFormat:@"modules/tour/lens-%@", lenseType]];
        [self.tabControl insertTabWithImage:lenseImage atIndex:tabIndex animated:NO];
    }
    
    for (NSInteger tabIndex = 0; tabIndex < [orderedLenses count]; tabIndex++) {
        [self.tabControl setMinimumWidth:mininumTabWidth forTabAtIndex:tabIndex];
    }
}

- (void)tabbedControl:(KGOTabbedControl *)control didSwitchToTabAtIndex:(NSInteger)index {
    TourLense *lense = [[self.tourStop orderedLenses] objectAtIndex:index];
    [[AnalyticsWrapper sharedWrapper] trackEvent:@"Stop Detail" 
                                          action:[NSString stringWithFormat:@"%@ Tab", lense.lenseType]
                                           label:self.tourStop.title];
    [self displayContentForTabIndex:index];
}

- (void)displayContentForTabIndex:(NSInteger)tabIndex {
    TourLense *lense = [[self.tourStop orderedLenses] objectAtIndex:tabIndex];
    [self displayLenseContent:lense];
}

- (void)displayLenseContent:(TourLense *)aLense {
    CGFloat lenseContentHeight = 0;
    // remove old content
    self.webView.delegate = nil;
    self.webView = nil;
    self.html = @"";
    NSString *htmlBodyContents = @"";
    
    [self stopAllPlayers];
    [moviePlayers removeAllObjects];
    for(UIView *subview in self.lenseContentView.subviews) {
        [subview removeFromSuperview];
    }
    
    // Set tab content background.
    UIView *tabBodyBackground = 
    [[UIImageView alloc] 
     initWithImage:[UIImage imageNamed:@"common/tab-body"]];
    [self.lenseContentView addSubview:tabBodyBackground];
    [self.lenseContentView sendSubviewToBack:tabBodyBackground];
    [tabBodyBackground release]; 
    
    for (TourLenseItem *lenseItem in [aLense orderedItems]) {
        if([lenseItem isKindOfClass:[TourLenseHtmlItem class]]) {
            TourLenseHtmlItem *lenseHtmlItem = (TourLenseHtmlItem *)lenseItem;
            htmlBodyContents = 
            [htmlBodyContents stringByAppendingString:lenseHtmlItem.html];
        }
        else if([lenseItem isKindOfClass:[TourLensePhotoItem class]]) {
            TourLensePhotoItem *lensePhotoItem = (TourLensePhotoItem *)lenseItem;
            [[NSBundle mainBundle] loadNibNamed:@"TourLensePhotoView" owner:self options:nil];
            UIView *photoView = self.lenseItemPhotoView;
            self.lenseItemPhotoView = nil;

            
            UIImageView *imageView = (UIImageView *)[photoView viewWithTag:LenseItemPhotoImageTag];
            imageView.image = [lensePhotoItem.photo image];
            UILabel *captionLabel = (UILabel *)[photoView viewWithTag:LenseItemPhotoCaptionTag];
            captionLabel.text = lensePhotoItem.title;
            CGSize captionSize = [lensePhotoItem.title sizeWithFont:captionLabel.font constrainedToSize:captionLabel.frame.size lineBreakMode:captionLabel.lineBreakMode];
            CGFloat deltaHeight = captionSize.height - captionLabel.frame.size.height;
            
            CGRect photoViewFrame = photoView.frame;
            photoViewFrame.origin.y = lenseContentHeight;
            photoViewFrame.size.height += deltaHeight;
            photoView.frame = photoViewFrame;
            lenseContentHeight += photoView.frame.size.height;
            
            [self.lenseContentView addSubview:photoView];
        }
        else if([lenseItem isKindOfClass:[TourLenseVideoItem class]]) {
            TourLenseVideoItem *lenseVideoItem = (TourLenseVideoItem *)lenseItem;
            [[NSBundle mainBundle] loadNibNamed:@"TourLenseVideoView" owner:self options:nil];
            UIView *videoView = self.lenseItemVideoView;
            self.lenseItemVideoView = nil;

            
            UIView *videoContainerView = [videoView viewWithTag:LenseItemVideoViewContainer];
            NSURL *videoURL = [NSURL fileURLWithPath:[lenseVideoItem.video mediaFilePath]];
            MPMoviePlayerController *player = [[[MPMoviePlayerController alloc] initWithContentURL:videoURL] autorelease];
            player.shouldAutoplay = NO;
            [moviePlayers addObject:player];
            [player.view setFrame:videoContainerView.bounds];
            [player.view setAutoresizingMask:videoContainerView.autoresizingMask];
            [videoContainerView addSubview:player.view];
                               
            UILabel *captionLabel = (UILabel *)[videoView viewWithTag:LenseItemVideoCaptionTag];
            captionLabel.text = lenseVideoItem.title;
            CGSize captionSize = [lenseVideoItem.title sizeWithFont:captionLabel.font constrainedToSize:captionLabel.frame.size lineBreakMode:captionLabel.lineBreakMode];
            CGFloat deltaHeight = captionSize.height - captionLabel.frame.size.height;
            
            CGRect videoViewFrame = videoView.frame;
            videoViewFrame.origin.y = lenseContentHeight;
            videoViewFrame.size.height += deltaHeight;
            videoView.frame = videoViewFrame;
            lenseContentHeight += videoView.frame.size.height;
            
            [self.lenseContentView addSubview:videoView];
        }
        else if([lenseItem isKindOfClass:[TourLenseSlideShowItem class]]) {
            TourLenseSlideShowItem *lenseSlideShowItem = (TourLenseSlideShowItem *)lenseItem;
            [[NSBundle mainBundle] loadNibNamed:@"TourLenseSlideShowView" owner:self options:nil];
            UIView *slideShowView = self.lenseItemSlideShowView;
            self.lenseItemSlideShowView = nil;
            self.slideShowScrollView = (UIScrollView *)[slideShowView viewWithTag:LenseItemSlideShowScrollViewTag];
            self.slideShowScrollView.decelerationRate = 0;
            self.slideShowScrollView.bounces = NO;
            self.slideShowScrollView.delegate = self;
            self.slides = [lenseSlideShowItem orderedSlides];
            [self.lenseContentView addSubview:slideShowView];
            lenseContentHeight += slideShowView.frame.size.height;
            
            self.slidesPageControl = (UIPageControl *)[slideShowView viewWithTag:LenseItemSlideShowPageControlTag];
            self.slidesPageControl.numberOfPages = self.slides.count;
            [self.slidesPageControl addTarget:self action:@selector(pageChanged) forControlEvents:UIControlEventValueChanged];
            [self loadSlideAtIndex:0];
        }
    }
    
    if ([htmlBodyContents length]) {
        // Load the body contents into the template.
        self.html = 
        [HTMLTemplateBasedViewController 
         htmlForPageTemplateFileName:@"stop_detail_template.html"
         replacementsForStubs:
         [NSDictionary 
          dictionaryWithObject:htmlBodyContents forKey:@"__CONTENTS__"]];
        
        CGFloat dummyInitialHeight = 200;
        CGRect webviewFrame = CGRectMake(0, lenseContentHeight, self.lenseContentView.frame.size.width, dummyInitialHeight);
        lenseContentHeight += dummyInitialHeight;
        self.webView = [[[UIWebView alloc] initWithFrame:webviewFrame] autorelease];
        self.webView.delegate = self;
        [self.webView 
         loadHTMLString:self.html 
         baseURL:[[NSBundle mainBundle] resourceURL]];
        [self.lenseContentView addSubview:self.webView]; 
    }
    
    
    CGRect contentViewFrame = self.lenseContentView.frame;
    contentViewFrame.size.height = lenseContentHeight;
    self.lenseContentView.frame = contentViewFrame;
    self.scrollView.contentSize = CGSizeMake(
        self.scrollView.frame.size.width,
        self.lenseContentView.frame.origin.y + lenseContentHeight);
}

- (void)loadSlideView:(TourSlide *)slide atOffset:(CGFloat)offset {
    [[NSBundle mainBundle] loadNibNamed:@"TourLensePhotoView" owner:self options:nil];
    UIView *slideView = self.lenseItemPhotoView;
    self.lenseItemPhotoView = nil;
    
    UIImageView *imageView = (UIImageView *)[slideView viewWithTag:LenseItemPhotoImageTag];
    imageView.image = [slide.photo image];
    UILabel *captionLabel = (UILabel *)[slideView viewWithTag:LenseItemPhotoCaptionTag];
    captionLabel.text = slide.title;
    
    CGRect slideViewFrame = slideView.frame;
    slideViewFrame.origin.x = offset;
    slideView.frame = slideViewFrame;
    [self.slideShowScrollView addSubview:slideView];
}

- (void)pageChanged {
    int deltaPage = self.slidesPageControl.currentPage - self.displayedPageIndex;
    int pageOffset = (self.displayedPageIndex == 0) ? deltaPage : deltaPage + 1;
    CGFloat newOffset = self.slideShowScrollView.frame.size.width * pageOffset;
    [self.slideShowScrollView scrollRectToVisible:CGRectMake(newOffset, 0, self.slideShowScrollView.frame.size.width, self.slideShowScrollView.frame.size.height) animated:YES];
}

- (void)loadSlideAtIndex:(NSInteger)slideIndex {
    // remove all old subviews
    for(UIView *subview in [self.slideShowScrollView subviews]) {
        [subview removeFromSuperview];
    }
    
    CGFloat scrollViewWidth = self.slideShowScrollView.frame.size.width;
    CGFloat currentSlideHorizontalOffset = 0;
    if (slideIndex > 0) {
        [self loadSlideView:[self.slides objectAtIndex:(slideIndex-1)] atOffset:currentSlideHorizontalOffset];
        currentSlideHorizontalOffset += scrollViewWidth;
    }
    
    [self loadSlideView:[self.slides objectAtIndex:slideIndex] atOffset:currentSlideHorizontalOffset];
    self.slideShowScrollView.contentOffset = CGPointMake(currentSlideHorizontalOffset, 0);
    currentSlideHorizontalOffset += scrollViewWidth;
    
    if (slideIndex + 1 < self.slides.count) {
        [self loadSlideView:[self.slides objectAtIndex:(slideIndex+1)] atOffset:currentSlideHorizontalOffset];
        currentSlideHorizontalOffset += scrollViewWidth;
    }
    
    self.slideShowScrollView.contentSize = CGSizeMake(currentSlideHorizontalOffset, self.slideShowScrollView.frame.size.height);
    self.slidesPageControl.currentPage = slideIndex;
    self.displayedPageIndex = slideIndex;
}

#pragma UIScrollView delegate methods
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self loadSlideAtIndex:self.slidesPageControl.currentPage];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    CGFloat pageWidth = self.slideShowScrollView.frame.size.width;
    int page = floor((self.slideShowScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1; 
    
    int deltaPage;
    if(self.slidesPageControl.currentPage == 0) {
        deltaPage = page;
    } else {
        deltaPage = page - 1;
    }
    [self loadSlideAtIndex:self.slidesPageControl.currentPage + deltaPage];
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
