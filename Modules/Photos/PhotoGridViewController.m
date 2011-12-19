#import "PhotoGridViewController.h"
#import "UIKit+KGOAdditions.h"

@implementation PhotoGridViewController

@synthesize dataManager, album, photos;

- (void)layoutGridView
{
    NSMutableArray *views = [NSMutableArray array];
    for (NSInteger i = 0; i < self.photos.count; i++) {
        Photo *aPhoto = [self.photos objectAtIndex:i];
        CGRect frame = CGRectMake(0, 0, 60, 60);
        MITThumbnailView *thumbView = [[[MITThumbnailView alloc] initWithFrame:frame] autorelease];
        thumbView.userInteractionEnabled = NO;
        thumbView.imageURL = aPhoto.thumbURL;
        thumbView.delegate = aPhoto;
        [thumbView loadImage];
        UIControl *control = [[[UIControl alloc] initWithFrame:frame] autorelease];
        control.tag = i;
        [control addSubview:thumbView];
        [control addTarget:self action:@selector(thumbnailTapped:) forControlEvents:UIControlEventTouchUpInside];
        [views addObject:control];
    }
    _iconGrid.icons = views;
}

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

- (void)dealloc
{
    self.album = nil;
    self.photos = nil;
    self.dataManager.delegate = nil;
    self.dataManager = nil;
    [super dealloc];
}

- (void)thumbnailTapped:(id)sender
{
    UIControl *control = (UIControl *)sender;
    if (control.tag < self.photos.count) {
        Photo *aPhoto = [self.photos objectAtIndex:control.tag];
        
    };
}

- (void)photoDataManager:(PhotoDataManager *)manager didReceivePhotos:(NSArray *)photos
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES];
    self.photos = [self.album.photos sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    [self layoutGridView];
    
    if (self.photos.count >= [self.album.totalItems integerValue]) {
        _loadingFooter.hidden = YES;
    }
}

- (void)iconGridFrameDidChange:(IconGrid *)iconGrid
{
    CGFloat expectedHeight = CGRectGetMaxY(iconGrid.frame) + CGRectGetHeight(_loadingFooter.frame);
    if ([(UIScrollView *)self.view contentSize].height != expectedHeight) {
        [(UIScrollView *)self.view setContentSize:CGSizeMake(CGRectGetWidth(self.view.bounds), expectedHeight)];
        _loadingFooter.frame = CGRectMake(0, expectedHeight - CGRectGetHeight(_loadingFooter.frame),
                                          CGRectGetWidth(_loadingFooter.frame), CGRectGetHeight(_loadingFooter.frame));
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titleLabel.text = self.album.title;
    
    NSString *cdot = [NSString stringWithUTF8String:"\u00B7"];
    _subtitleLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",
                           self.album.type, cdot,
                           [self.album albumSize], cdot, [self.album lastUpdateString]];
    
    _iconGrid.delegate = self;
    _iconGrid.padding = GridPaddingMake(16, 16, 16, 16);
    _iconGrid.spacing = GridSpacingMake(16, 16);
    
    _loadingStatusLabel.text = NSLocalizedString(@"Loading more photos", nil);
    
    self.dataManager.delegate = self;
    [self.dataManager fetchPhotosForAlbum:self.album.identifier];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return IS_IPAD_OR_PORTRAIT(interfaceOrientation);
}

#pragma mark - scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // fetch videos if the loading indicator is visible
    if (_loadingFooter.hidden) {
        return;
    }

    CGFloat loadingY = CGRectGetMinY(_loadingFooter.frame);
    if (scrollView.contentOffset.y + CGRectGetHeight(self.view.frame) > loadingY) {
        NSLog(@"asdfgasgawregr");
        [self.dataManager fetchPhotosForAlbum:self.album.identifier];
    }
}

@end
