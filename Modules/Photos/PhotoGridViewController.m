#import "PhotoGridViewController.h"
#import "UIKit+KGOAdditions.h"
#import "KGOAppDelegate+ModuleAdditions.h"

@implementation PhotoGridViewController

@synthesize dataManager = _dataManager, album = _album, photos = _photos;

- (void)layoutPhotos:(NSArray *)photos
{
    NSMutableArray *views = [NSMutableArray array];
    for (NSInteger i = 0; i < photos.count; i++) {
        Photo *aPhoto = [self.photos objectAtIndex:i];
        CGRect frame = CGRectMake(0, 0, 72, 72);
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
    //_iconGrid.icons = views;
    //[_iconGrid setNeedsLayout];
    [_iconGrid addIcons:views];
}

- (void)updateSubtitleLabel
{
    if (self.album.lastUpdate) {
        NSString *cdot = [NSString stringWithUTF8String:"\u00B7"];
        _subtitleLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",
                               self.album.type, cdot,
                               [self.album albumSize], cdot, [self.album lastUpdateString]];
    }
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
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                aPhoto, @"photo", self.photos, @"photos", nil];
        [KGO_SHARED_APP_DELEGATE() showPage:LocalPathPageNameDetail
                               forModuleTag:self.dataManager.moduleTag
                                     params:params];
    };
}

- (void)photoDataManager:(PhotoDataManager *)manager didReceivePhotos:(NSArray *)photos
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES];
    self.photos = [self.album.photos sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    [self layoutPhotos:photos];
    
    if (self.photos.count >= [self.album.totalItems integerValue]) {
        _loadingFooter.hidden = YES;
    }
    
    [self updateSubtitleLabel];
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
    
    self.title = NSLocalizedString(@"PHOTOS_ALBUM_VIEW_TITLE", @"Album");
    
    _titleLabel.text = self.album.title;
    
    [self updateSubtitleLabel];
    
    _iconGrid.delegate = self;
    _iconGrid.padding = GridPaddingMake(7, 7, 7, 7);
    _iconGrid.spacing = GridSpacingMake(6, 6);
    
    _loadingStatusLabel.text = NSLocalizedString(@"PHOTOS_LOADING_MORE_PHOTOS", @"Loading more photos");
    
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
        [self.dataManager fetchPhotosForAlbum:self.album.identifier];
    }
}

@end
