#import "PhotoDetailViewController.h"
#import "MITThumbnailView.h"
#import "Photo.h"
#import "PhotoAlbum.h"
#import "UIKit+KGOAdditions.h"
#import "KGOSearchModel.h"

@implementation PhotoDetailViewController

@synthesize imageView, titleView, titleLabel, subtitleLabel, shareButton, photo = _photo, photos;
@synthesize shareController = _shareController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)resizeLabels
{
    CGFloat width = CGRectGetWidth(self.titleView.frame);
    CGFloat spacing = 4;
    CGSize subSize = [self.subtitleLabel.text sizeWithFont:self.subtitleLabel.font
                                         constrainedToSize:CGSizeMake(width, self.subtitleLabel.font.lineHeight * 5)
                                             lineBreakMode:UILineBreakModeWordWrap];
    CGFloat titleMaxHeight = CGRectGetHeight(self.titleView.frame) - subSize.height - spacing;
    CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font
                                        constrainedToSize:CGSizeMake(width, titleMaxHeight)
                                            lineBreakMode:UILineBreakModeWordWrap];
    self.titleLabel.frame = CGRectMake(0, 0, titleSize.width, titleSize.height);
    self.subtitleLabel.frame = CGRectMake(0, titleSize.height + spacing, subSize.width, subSize.height);
}

- (void)displayPhoto:(Photo *)photo
{
    self.imageView.imageURL = photo.imageURL;
    self.imageView.imageData = photo.imageData;
    self.imageView.delegate = photo;
    [self.imageView loadImage];
    
    self.titleLabel.text = photo.title;
    self.subtitleLabel.text = [NSString stringWithFormat:@"%@ (%@)\n%@",
                               photo.album.title, photo.album.type, [photo lastUpdateString]];

    [self resizeLabels];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"PHOTOS_DETAIL_PAGE_TITLE", @"Photo");
    [self.shareButton setBackgroundImage:[UIImage imageWithPathName:@"common/share"] forState:UIControlStateNormal];

    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;

    self.titleLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertyPageTitle];
    self.titleLabel.textColor = [[KGOTheme sharedTheme] textColorForThemedProperty:KGOThemePropertyPageTitle];
    
    self.subtitleLabel.font = [[KGOTheme sharedTheme] fontForThemedProperty:KGOThemePropertySmallPrint];
    self.subtitleLabel.textColor = [[KGOTheme sharedTheme] textColorForThemedProperty:KGOThemePropertySmallPrint];
    
    KGODetailPager *pager = [[[KGODetailPager alloc] initWithPagerController:self delegate:self] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:pager] autorelease];
    
    NSInteger currentIndex = [self.photos indexOfObject:self.photo];
    if (currentIndex != NSNotFound) {
        [pager selectPageAtSection:0 row:currentIndex];
    } else {
        NSLog(@"warning: did not find current photo in photos array");
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.imageView = nil;
    self.titleView = nil;
    self.titleLabel = nil;
    self.subtitleLabel = nil;
    self.shareButton = nil;
    self.shareController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat buttonWidth = CGRectGetWidth(self.shareButton.frame);
    CGFloat buttonHeight = CGRectGetHeight(self.shareButton.frame);
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        CGFloat screenHeight = CGRectGetHeight(self.view.bounds); // this returns the current height
        CGFloat screenWidth = CGRectGetWidth(self.view.bounds);
        CGFloat width = floorf(screenWidth * 0.75);
        CGFloat vPadding = 9;
        CGFloat hPadding = 7;
        self.imageView.frame = CGRectMake(0, 0, width, screenHeight);
        self.titleView.frame = CGRectMake(width + hPadding, vPadding,
                                          screenWidth - width - hPadding * 2,
                                          screenHeight - buttonHeight - vPadding * 3);
        self.shareButton.frame = CGRectMake(screenWidth - buttonWidth - hPadding,
                                            screenHeight - buttonHeight - vPadding,
                                            buttonWidth, buttonHeight);
    } else {
        CGFloat screenWidth = CGRectGetWidth(self.view.frame); // this always returns the portrait width
        CGFloat screenHeight = CGRectGetHeight(self.view.frame);
        CGFloat height = floorf(screenWidth * 0.8);
        CGFloat vPadding = 7;
        CGFloat hPadding = 9;
        self.imageView.frame = CGRectMake(0, 0, screenWidth, height);
        self.shareButton.frame = CGRectMake(screenWidth - buttonWidth - hPadding, height + vPadding,
                                            buttonWidth, buttonHeight);
        self.titleView.frame = CGRectMake(hPadding, height + vPadding,
                                          screenWidth - buttonWidth - hPadding * 3,
                                          screenHeight - height - hPadding * 2);
    }
    [self resizeLabels];
}

#pragma mark - KGODatePager

// pager controller
- (NSInteger)pager:(KGODetailPager *)pager numberOfPagesInSection:(NSInteger)section
{
    return self.photos.count;
}

- (id<KGOSearchResult>)pager:(KGODetailPager *)pager contentForPageAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.photos objectAtIndex:indexPath.row];
}

// pager delegate
- (void)pager:(KGODetailPager*)pager showContentForPage:(id<KGOSearchResult>)content
{
    if ([content isKindOfClass:[Photo class]]) {
        self.photo = (Photo *)content;
        [self displayPhoto:self.photo];
    }
}

#pragma mark -

- (IBAction)shareButtonPressed:(id)sender
{
    if (!self.shareController) {
        self.shareController = [[[KGOShareButtonController alloc] initWithContentsController:self] autorelease];
        self.shareController.shareTypes = KGOShareControllerShareTypeEmail | KGOShareControllerShareTypeFacebook | KGOShareControllerShareTypeTwitter;
        
        self.shareController.actionSheetTitle = NSLocalizedString(@"Share Photo", nil);
        self.shareController.shareTitle = self.photo.title;
        self.shareController.shareURL = self.photo.imageURL;
    }
    
    [self.shareController shareInView:self.view];
}

- (void)dealloc
{
    self.shareController = nil;
    self.imageView.delegate = nil;
    self.imageView = nil;
    self.photo = nil;
    self.titleLabel = nil;
    self.subtitleLabel = nil;
    self.shareButton = nil;
    [super dealloc];
}

@end
