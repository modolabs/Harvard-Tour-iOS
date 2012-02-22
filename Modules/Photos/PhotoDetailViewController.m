#import "PhotoDetailViewController.h"
#import "MITThumbnailView.h"
#import "Photo.h"
#import "PhotoAlbum.h"
#import "UIKit+KGOAdditions.h"

@implementation PhotoDetailViewController

@synthesize imageView, titleView, titleLabel, subtitleLabel, pagerView,
prevThumbView, nextThumbView, prevButton, nextButton, pagerLabel, shareButton,
photo, photos;

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

- (void)displayPhoto
{
    self.imageView.imageURL = self.photo.imageURL;
    self.imageView.imageData = self.photo.imageData;
    self.imageView.delegate = self.photo;
    [self.imageView loadImage];
    
    self.titleLabel.text = self.photo.title;
    NSString *cdot = [NSString stringWithUTF8String:"\u00B7"];
    self.subtitleLabel.text = [NSString stringWithFormat:@"%@ %@ %@",
                               self.photo.album.type, cdot, [self.photo lastUpdateString]];

    NSInteger currentIndex = [self.photos indexOfObject:self.photo];
    if (currentIndex != NSNotFound) {
        self.pagerLabel.text = [NSString stringWithFormat:
                                NSLocalizedString(@"PHOTOS_%1$d_OF_%2$d", @"Photo %d of %d"),
                                (currentIndex + 1),
                                [self.photo.album.totalItems integerValue]];
        
        if (currentIndex > 0) {
            Photo *prevPhoto = [self.photos objectAtIndex:currentIndex - 1];
            self.prevThumbView.imageURL = prevPhoto.imageURL;
            self.prevThumbView.imageData = prevPhoto.imageData;
            [self.prevThumbView loadImage];
        }
        
        if (currentIndex < self.photos.count - 1) {
            Photo *nextPhoto = [self.photos objectAtIndex:currentIndex + 1];
            self.nextThumbView.imageURL = nextPhoto.imageURL;
            self.nextThumbView.imageData = nextPhoto.imageData;
            [self.nextThumbView loadImage];
        }
    } else {
        NSLog(@"warning: did not find current photo in photos array");
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"PHOTOS_DETAIL_PAGE_TITLE", @"Photo");
    [self.shareButton setBackgroundImage:[UIImage imageWithPathName:@"common/share"] forState:UIControlStateNormal];

    [self displayPhoto];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.imageView = nil;
    self.titleView = nil;
    self.titleLabel = nil;
    self.subtitleLabel = nil;
    self.prevThumbView = nil;
    self.nextThumbView = nil;
    self.prevButton = nil;
    self.nextButton = nil;
    self.pagerLabel = nil;
    self.shareButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        CGFloat screenHeight = CGRectGetHeight(self.view.bounds); // this returns the current height
        CGFloat screenWidth = CGRectGetWidth(self.view.bounds);
        CGFloat width = screenHeight;
        CGFloat vPadding = 9;
        CGFloat hPadding = 7;
        self.imageView.frame = CGRectMake(0, 0, width, screenHeight);
        self.titleView.frame = CGRectMake(width + hPadding, vPadding,
                                          CGRectGetWidth(self.titleView.frame),
                                          CGRectGetHeight(self.titleView.frame));
        self.pagerView.frame = CGRectMake(width + hPadding,
                                          vPadding + CGRectGetHeight(self.titleView.frame) + vPadding,
                                          CGRectGetWidth(self.pagerView.frame),
                                          CGRectGetHeight(self.pagerView.frame));
        CGFloat buttonWidth = CGRectGetWidth(self.shareButton.frame);
        self.shareButton.frame = CGRectMake(screenWidth - buttonWidth - hPadding, vPadding,
                                            buttonWidth, CGRectGetHeight(self.shareButton.frame));
        
    } else {
        CGFloat screenWidth = CGRectGetWidth(self.view.frame); // this always returns the portrait width
        CGFloat height = floorf(screenWidth * 0.8);
        CGFloat vPadding = 7;
        CGFloat hPadding = 9;
        self.imageView.frame = CGRectMake(0, 0, screenWidth, height);
        self.titleView.frame = CGRectMake(hPadding, height + vPadding,
                                          CGRectGetWidth(self.titleView.frame),
                                          CGRectGetHeight(self.titleView.frame));
        self.pagerView.frame = CGRectMake(hPadding,
                                          height + vPadding + CGRectGetHeight(self.titleView.frame) + vPadding,
                                          CGRectGetWidth(self.pagerView.frame),
                                          CGRectGetHeight(self.pagerView.frame));
        CGFloat buttonWidth = CGRectGetWidth(self.shareButton.frame);
        self.shareButton.frame = CGRectMake(screenWidth - buttonWidth - hPadding, height + vPadding,
                                            buttonWidth, CGRectGetHeight(self.shareButton.frame));
    }
}

- (IBAction)prevButtonPressed:(id)sender
{
    NSInteger currentIndex = [self.photos indexOfObject:self.photo];
    if (currentIndex != NSNotFound && currentIndex > 0) {
        currentIndex--;
        self.photo = [self.photos objectAtIndex:currentIndex];
        [self displayPhoto];
    }

    if (currentIndex < self.photos.count - 1) {
        self.nextButton.enabled = YES;
    }

    if (currentIndex <= 0) {
        self.prevButton.enabled = NO;
    }
}

- (IBAction)nextButtonPressed:(id)sender
{
    NSInteger currentIndex = [self.photos indexOfObject:self.photo];
    if (currentIndex != NSNotFound && currentIndex < self.photos.count - 1) {
        currentIndex++;
        self.photo = [self.photos objectAtIndex:currentIndex];
        [self displayPhoto];
    }
    
    if (currentIndex >= self.photos.count - 1) {
        self.nextButton.enabled = NO;
    }
    
    if (currentIndex > 0) {
        self.prevButton.enabled = YES;
    }
}

- (IBAction)shareButtonPressed:(id)sender
{
    
}

@end
